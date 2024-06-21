import boto3
import os
import datetime

sqs_client = boto3.client('sqs', region_name='us-east-1')
s3_client = boto3.client('s3')
queue_url = 'https://sqs.us-east-1.amazonaws.com/655073027311/message-queue'
bucket_name = 'skj-labs-bucket'

def receive_message():
    response = sqs_client.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=10
    )
    
    messages = response.get('Messages', [])
    if not messages:
        print("No messages available")
        return

    for message in messages:
        body = message['Body']
        receipt_handle = message['ReceiptHandle']
        
        timestamp = body.split(' at ')[-1]
        file_name = f"{timestamp}-message.log"
        file_path = f"/tmp/{file_name}"

        with open(file_path, 'w') as file:
            file.write(body)
        
        s3_client.upload_file(file_path, bucket_name, file_name)
        os.remove(file_path)
        
        sqs_client.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
        print(f"Message received and processed: {body}")

if __name__ == "__main__":
    receive_message()
