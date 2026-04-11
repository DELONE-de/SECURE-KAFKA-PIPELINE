"use strict";

const { Kafka, logLevel } = require("kafkajs");
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const { v4: uuidv4 } = require("uuid");

const REGION      = process.env.AWS_REGION    || "us-east-1";
const SECRET_NAME = process.env.SECRET_NAME   || "producer-secret";
const BROKERS     = (process.env.KAFKA_BROKERS || "").split(",").filter(Boolean);
const TOPIC       = process.env.KAFKA_TOPIC   || "events";

const ACTIONS = ["click", "scroll", "view", "purchase", "logout"];
const PAGES   = ["home", "product", "cart", "checkout", "profile"];

if (!BROKERS.length) {
  console.error("KAFKA_BROKERS env variable is required");
  process.exit(1);
}

async function getSecret() {
  const client = new SecretsManagerClient({ region: REGION });
  const res = await client.send(new GetSecretValueCommand({ SecretId: SECRET_NAME }));
  if (!res.SecretString) throw new Error("SecretString is empty");
  return JSON.parse(res.SecretString);
}

function randomBetween(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function buildEvent() {
  return {
    event_type: "user_interaction",
    user_id:    uuidv4(),
    timestamp:  Math.floor(Date.now() / 1000),
    data: {
      action: ACTIONS[randomBetween(0, ACTIONS.length - 1)],
      page:   PAGES[randomBetween(0, PAGES.length - 1)],
    },
  };
}

async function run() {
  const { username, password } = await getSecret();

  const kafka = new Kafka({
    clientId: "ec2-producer",
    brokers:  BROKERS,
    ssl:      true,
    sasl:     { mechanism: "scram-sha-512", username, password },
    logLevel: logLevel.WARN,
    retry: {
      initialRetryTime: 300,
      retries:          8,
      factor:           2,        // exponential backoff
      maxRetryTime:     30000,
    },
  });

  const producer = kafka.producer();
  await producer.connect();
  console.log("Producer connected to MSK");

  const sendNext = async () => {
    const event = buildEvent();
    try {
      await producer.send({
        topic:    TOPIC,
        messages: [{ key: event.user_id, value: JSON.stringify(event) }],
      });
      console.log(`Sent event: user_id=${event.user_id} action=${event.data.action}`);
    } catch (err) {
      console.error("Failed to send event:", err.message);
    }
    // schedule next send at a random 2–5s interval
    setTimeout(sendNext, randomBetween(2000, 5000));
  };

  sendNext();

  // graceful shutdown
  const shutdown = async () => {
    console.log("Shutting down producer...");
    await producer.disconnect();
    process.exit(0);
  };
  process.on("SIGTERM", shutdown);
  process.on("SIGINT",  shutdown);
}

run().catch((err) => {
  console.error("Fatal error:", err.message);
  process.exit(1);
});
