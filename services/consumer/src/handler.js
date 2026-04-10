const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const { marshall } = require("@aws-sdk/util-dynamodb");

const dynamo = new DynamoDBClient({});
const TABLE_NAME = process.env.DYNAMODB_TABLE;

exports.handler = async (event) => {
  try {
    console.log("📥 Raw event:", JSON.stringify(event, null, 2));

    for (const record of Object.keys(event.records)) {
      for (const message of event.records[record]) {
        const data = JSON.parse(Buffer.from(message.value, "base64").toString("utf-8"));

        await dynamo.send(new PutItemCommand({
          TableName: TABLE_NAME,
          Item: marshall({
            messageId: `${record}-${message.offset}`,
            topic: record,
            partition: message.partition,
            offset: message.offset,
            timestamp: message.timestamp,
            payload: data,
          }),
        }));

        console.log("✅ Saved to DynamoDB:", data);
      }
    }

    return { statusCode: 200 };
  } catch (error) {
    console.error("❌ Error processing Kafka event:", error);
    throw error;
  }
};
