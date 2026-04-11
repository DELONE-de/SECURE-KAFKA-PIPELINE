"use strict";

const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;

if (!TABLE_NAME) throw new Error("DYNAMODB_TABLE_NAME env variable is required");

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({}));

function decode(value) {
  return JSON.parse(Buffer.from(value, "base64").toString("utf-8"));
}

function validate(record) {
  const { event_type, user_id, timestamp } = record;
  if (!event_type || !user_id || !timestamp) {
    throw new Error(`Missing required fields: ${JSON.stringify({ event_type, user_id, timestamp })}`);
  }
}

exports.handler = async (event) => {
  const results = { success: 0, failed: 0 };

  for (const [topicPartition, messages] of Object.entries(event.records)) {
    for (const msg of messages) {
      let parsed;
      try {
        parsed = decode(msg.value);
        validate(parsed);

        await dynamo.send(new PutCommand({
          TableName: TABLE_NAME,
          Item: {
            eventId:    parsed.user_id,
            timestamp:  String(parsed.timestamp),
            event_type: parsed.event_type,
            data:       parsed.data ?? {},
            topic:      topicPartition,
            offset:     msg.offset,
          },
        }));

        console.log(JSON.stringify({ status: "ok", user_id: parsed.user_id, timestamp: parsed.timestamp }));
        results.success++;
      } catch (err) {
        console.error(JSON.stringify({
          status:    "failed",
          offset:    msg.offset,
          topic:     topicPartition,
          error:     err.message,
          raw_value: msg.value,
        }));
        results.failed++;
        // continue — do not rethrow, let the rest of the batch process
      }
    }
  }

  console.log(JSON.stringify({ batch_summary: results }));
  return results;
};
