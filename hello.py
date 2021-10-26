import boto3

sns_client = boto3.client('sns')
SNS_ARN = 'arn:aws:sns:us-west-2:545895318545:mytopic'

def welcome(event, context):

    subject = 'Here is your SNS'
    message = 'Here We can get the result'

    sns_client.publish(TargetArn=SNS_ARN, Subject=subject, Message=message)

    # Cloud watch log output
    print('Your Code has run successfully!!')
