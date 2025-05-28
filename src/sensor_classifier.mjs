import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";

const dynamoClient = new DynamoDBClient();
const docClient = DynamoDBDocumentClient.from(dynamoClient);
const snsClient = new SNSClient();

const TABLE_NAME = process.env.TABLE_NAME;
const SNS_TOPIC_ARN = process.env.SNS_TOPIC_ARN;

function steinhartHart(R) {
  const a = 1.4e-3,
    b = 2.37e-4,
    c = 9.9e-8;

  if (R < 1 || R > 20000) {
    return null;
  }

  const T_inv = a + b * Math.log(R) + c * Math.pow(Math.log(R), 3);
  const T_K = 1 / T_inv;
  return T_K - 273.15;
}

export const handler = async (event) => {
  try {
    const { sensor_id, value } = event;

    if (!sensor_id || value === undefined) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          error: "Brak wymaganych pól: sensor_id i value",
        }),
      };
    }

    const temperature = steinhartHart(value);

    if (temperature === null) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "VALUE_OUT_OF_RANGE" }),
      };
    }

    let status;
    if (temperature < 20) {
      status = "TEMPERATURE_TOO_LOW";
    } else if (temperature <= 100) {
      status = "OK";
    } else if (temperature <= 250) {
      status = "TEMPERATURE_TOO_HIGH";
    } else {
      status = "TEMPERATURE_CRITICAL";
      await sendSnsNotification(sensor_id, temperature);
      await markSensorAsBroken(sensor_id);
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        sensor_id,
        temperature: temperature.toFixed(2),
        status,
      }),
    };
  } catch (error) {
    console.error("Błąd przetwarzania żądania:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};

async function sendSnsNotification(sensor_id, temperature) {
  const message = `Sensor ${sensor_id} wykrył krytyczną temperaturę: ${temperature.toFixed(
    2
  )}°C`;

  const params = {
    TopicArn: SNS_TOPIC_ARN,
    Message: message,
    Subject: "ALERT: Temperature Critical",
  };

  await snsClient.send(new PublishCommand(params));
}

async function markSensorAsBroken(sensor_id) {
  const params = {
    TableName: TABLE_NAME,
    Item: {
      sensor_id,
      broken: true,
      timestamp: new Date().toISOString(),
    },
  };

  await docClient.send(new PutCommand(params));
}
