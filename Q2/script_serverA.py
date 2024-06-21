import boto3
import datetime

sns_client = boto3.client('sns', region_name='us-east-1')

def publish_message():
    current_time = datetime.datetime.now().strftime('%Y-%m-%d-%H:%M:%S')
    message = f"Hello from server A at {current_time}"
    response = sns_client.publish(
        TopicArn='arn:aws:sns:us-east-1:655073027311:message-topic',
        Message=message
    )
    print("Message Published:", response)

if __name__ == "__main__":
    publish_message()
