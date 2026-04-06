// lambda-consumer.js

exports.handler = async (event) => {
    try {
      console.log("📥 Raw event:", JSON.stringify(event, null, 2));
  
      for (const record of event.records) {
        for (const message of event.records[record]) {
          const decodedValue = Buffer.from(message.value, "base64").toString("utf-8");
  
          const data = JSON.parse(decodedValue);
  
          console.log("✅ Processed message:", data);
  
          // 👉 Your business logic here
          // Example:
          // - Save to DB
          // - Send to another service
          // - Trigger alerts
        }
      }
  
      return {
        statusCode: 200,
      };
    } catch (error) {
      console.error("❌ Error processing Kafka event:", error);
  
      throw error; // Important for retry behavior
    }
  };
