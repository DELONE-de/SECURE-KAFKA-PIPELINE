// producer.js

const { Kafka } = require("kafkajs");
const {
  SecretsManagerClient,
  GetSecretValueCommand,
} = require("@aws-sdk/client-secrets-manager");

const REGION = process.env.AWS_REGION || "your-region";
const SECRET_NAME = "producer-secret";

// Replace with your MSK bootstrap brokers
const BROKERS = [
  "b-1.your-msk:9094",
  "b-2.your-msk:9094",
];

async function getSecret() {
  const client = new SecretsManagerClient({ region: REGION });

  const command = new GetSecretValueCommand({
    SecretId: SECRET_NAME,
  });

  const response = await client.send(command);

  if (!response.SecretString) {
    throw new Error("SecretString is empty");
  }

  return JSON.parse(response.SecretString);
}

async function createProducer() {
  const { username, password } = await getSecret();

  const kafka = new Kafka({
    clientId: "secure-producer",
    brokers: BROKERS,
    ssl: true, // TLS
    sasl: {
      mechanism: "scram-sha-512",
      username,
      password,
    },
  });

  return kafka.producer({
    retry: {
      initialRetryTime: 300,
      retries: 5,
    },
  });
}

async function run() {
  const producer = await createProducer();

  await producer.connect();
  console.log("✅ Producer connected to MSK");

  setInterval(async () => {
    try {
      const event = {
        event_type: "user_action",
        timestamp: new Date().toISOString(),
      };

      await producer.send({
        topic: "events",
        messages: [
          {
            key: "event-key",
            value: JSON.stringify(event),
          },
        ],
      });

      console.log("📤 Event sent:", event);
    } catch (err) {
      console.error("❌ Error sending event:", err);
    }
  }, 5000);
}

run().catch((err) => {
  console.error("🔥 Fatal error:", err);
  process.exit(1);
});
