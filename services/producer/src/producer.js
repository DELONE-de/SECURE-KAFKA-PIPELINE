const { Kafka } = require("kafkajs");
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");

const REGION = process.env.AWS_REGION || "us-east-1";
const SECRET_NAME = process.env.SECRET_NAME || "producer-secret";
const BROKERS = process.env.MSK_BROKERS ? process.env.MSK_BROKERS.split(",") : [];

async function getSecret() {
  const client = new SecretsManagerClient({ region: REGION });
  const response = await client.send(new GetSecretValueCommand({ SecretId: SECRET_NAME }));
  if (!response.SecretString) throw new Error("SecretString is empty");
  return JSON.parse(response.SecretString);
}

async function run() {
  const { username, password } = await getSecret();
  const kafka = new Kafka({
    clientId: "secure-producer",
    brokers: BROKERS,
    ssl: true,
    sasl: { mechanism: "scram-sha-512", username, password },
  });

  const producer = kafka.producer({ retry: { initialRetryTime: 300, retries: 5 } });
  await producer.connect();
  console.log("✅ Producer connected to MSK");

  setInterval(async () => {
    try {
      const event = { event_type: "user_action", timestamp: new Date().toISOString() };
      await producer.send({ topic: "events", messages: [{ key: "event-key", value: JSON.stringify(event) }] });
      console.log("📤 Event sent:", event);
    } catch (err) {
      console.error("❌ Error sending event:", err);
    }
  }, 5000);
}

run().catch((err) => { console.error("🔥 Fatal error:", err); process.exit(1); });
