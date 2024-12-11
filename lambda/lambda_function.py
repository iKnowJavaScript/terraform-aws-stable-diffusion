import boto3
import json
import os
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    ssm = boto3.client('ssm')
    instance_id = os.environ['EC2_INSTANCE_ID']
    # Parse the body to extract the prompt
    body = json.loads(event['body']) if event['body'] else {}
    logger.info("Parsed body: %s", json.dumps(body))
    prompt = body.get('prompt', 'Andromeda galaxy in a bottle')

    logger.info("Instance ID: %s", instance_id)
    logger.info("Prompt: %s", prompt)

    try:
        response = ssm.send_command(
            InstanceIds=[instance_id],
            DocumentName="AWS-RunShellScript",
            Parameters={
                'commands': [
                    'cd /home/ec2-user/stable-diffusion-docker',
                    './build.sh run --steps 5 "{}"'.format(prompt)
                ]
            }
        )

        command_id = response['Command']['CommandId']
        logger.info("SSM Command ID: %s", command_id)

        # Wait for the command to complete
        waiter = ssm.get_waiter('command_executed')
        waiter.wait(
            CommandId=command_id,
            InstanceId=instance_id,
            WaiterConfig={
                'Delay': 10,
                'MaxAttempts': 30
            }
        )

        # Retrieve the command output
        output = ssm.get_command_invocation(
            CommandId=command_id,
            InstanceId=instance_id
        )

        logger.info("Command output: %s", output['StandardOutputContent'])

        # Extract the image file path from the command output
        output_lines = output['StandardOutputContent'].split('\n')
        image_s3_url = None
        for line in output_lines:
            if line.startswith('Generated image saved to S3 with URL:'):
                image_s3_url = line.split(': ')[1]
                break

        logger.info("Image url: %s", image_s3_url)

        if image_s3_url:
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Image generation completed',
                    'image_url': image_s3_url
                })
            }
        else:
            return {
                'statusCode': 500,
                'body': json.dumps({
                    'message': 'Image generation failed',
                    'error': 'Image file path not found in command output'
                })
            }
    except Exception as e:
        logger.error("Error executing SSM command: %s", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error executing SSM command',
                'error': str(e)
            })
        }
