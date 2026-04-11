# ─── VPC ──────────────────────────────────────────────────────────────────────

module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ─── VPC Endpoints ────────────────────────────────────────────────────────────

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

# ─── Security Groups ──────────────────────────────────────────────────────────

module "security_groups" {
  source = "../../modules/security-groups"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  sg_vpc_endpoints_id = module.vpc_endpoints.endpoint_security_group_id
}

# ─── Secrets Manager ──────────────────────────────────────────────────────────

module "secrets" {
  source = "../../modules/secrets-manager"

  project_name      = var.project_name
  environment       = var.environment
  producer_password = var.producer_password
  consumer_password = var.consumer_password
}

# ─── S3 (artifacts) ───────────────────────────────────────────────────────────

module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# ─── DynamoDB ─────────────────────────────────────────────────────────────────

module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
  table_name   = "${var.project_name}-${var.environment}-events"
}

# ─── IAM ──────────────────────────────────────────────────────────────────────

module "iam" {
  source = "../../modules/iam"

  project_name       = var.project_name
  environment        = var.environment
  s3_bucket_arn      = module.s3.bucket_arn
  dynamodb_table_arn = module.dynamodb.table_arn
  secrets_arns       = module.secrets.all_secret_arns
  msk_cluster_arn    = module.msk.msk_cluster_arn
}

# ─── MSK ──────────────────────────────────────────────────────────────────────

module "msk" {
  source = "../../modules/msk"

  project_name          = var.project_name
  environment           = var.environment
  cluster_name          = "${var.project_name}-${var.environment}"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  msk_security_group_id = module.security_groups.msk_security_group_id
  producer_secret_arn   = module.secrets.producer_secret_arn
  consumer_secret_arn   = module.secrets.consumer_secret_arn
  cloudwatch_log_group  = module.cloudwatch.msk_log_group_name
}

# ─── Lambda (consumer) ────────────────────────────────────────────────────────

module "lambda" {
  source = "../../modules/lambda"

  project_name             = var.project_name
  environment              = var.environment
  lambda_function_name     = "${var.project_name}-${var.environment}-consumer"
  lambda_role_arn          = module.iam.lambda_role_arn
  artifact_bucket          = module.s3.bucket_name
  artifact_key             = module.s3.consumer_artifact_key
  private_subnet_ids       = module.vpc.private_subnet_ids
  lambda_security_group_id = module.security_groups.lambda_security_group_id
  msk_cluster_arn          = module.msk.msk_cluster_arn
  dynamodb_table_name      = module.dynamodb.table_name
}

# ─── EC2 (producer) ───────────────────────────────────────────────────────────

module "ec2" {
  source = "../../modules/ec2"

  project_name              = var.project_name
  environment               = var.environment
  instance_type             = var.instance_type
  subnet_id                 = module.vpc.private_subnet_ids[0]
  ec2_security_group_id     = module.security_groups.ec2_security_group_id
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  artifact_bucket           = module.s3.bucket_name
  artifact_key              = module.s3.producer_artifact_key
}

# ─── CloudWatch ───────────────────────────────────────────────────────────────

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name         = var.project_name
  environment          = var.environment
  lambda_function_name = module.lambda.lambda_function_name
  ec2_instance_id      = module.ec2.ec2_instance_id
  msk_cluster_name     = "${var.project_name}-${var.environment}"
  alarm_email          = var.alarm_email
}
