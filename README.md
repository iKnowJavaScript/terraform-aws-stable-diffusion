# Stable Diffusion AWS Deployment

This project sets up an AWS infrastructure to deploy a Stable Diffusion model using AWS Lambda, EC2, S3, and API Gateway. The Lambda function triggers an EC2 instance to run the Stable Diffusion model and store the generated images in an S3 bucket.

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Python 3.8 installed

## Project Structure

```
.DS_Store
.gitignore
infra/
	api-gateway.tf
	ec2.tf
	inputs.tf
	kms.tf
	lambda.tf
	main.tf
	s3.tf
lambda/
	lambda_function.py
LICENSE
README.md
```

## Setup Instructions

### Step 1: Create Lambda Zip Package

From the root folder, run the following command to create a zip package for the Lambda function:

```sh
zip -r ./lambda.zip ./lambda
```

### Step 2: Initialize and Apply Terraform Configuration

1. Navigate to the 

infra

 directory:

    ```sh
    cd infra
    ```

2. Initialize Terraform:

    ```sh
    terraform init
    ```

3. Apply the Terraform configuration:

    ```sh
    terraform apply
    ```

    Confirm the apply action when prompted.

## Lambda Function

The Lambda function is defined in 

lambda_function.py

. It triggers an EC2 instance to run the Stable Diffusion model and stores the generated image in an S3 bucket.

## Terraform Configuration

The Terraform configuration is located in the 

infra
 Includes:

## API Gateway

The API Gateway is configured to invoke the Lambda function via an HTTP POST request. The configuration is defined in 



## IAM Roles and Policies

The necessary IAM roles and policies are defined in the Terraform configuration to allow the Lambda function and EC2 instance to perform their required actions.

## S3 Bucket

An S3 bucket is created to store the generated images. The configuration is defined in 


## EC2 Instance

An EC2 instance is configured to run the Stable Diffusion model. The configuration is defined in 


## License

This project is licensed under the MIT License. See the 

LICENSE

 file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## Contact

For any questions or support, please open an issue in the repository.


Feel free to check repo https://github.com/iKnowJavaScript/stable-diffusion-docker.git for commands and how the model works