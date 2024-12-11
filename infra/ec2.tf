resource "aws_instance" "stable_diffusion" {
  ami                    = "ami-002a53be89c7bb5de" # Amazon Linux 2 AMI
  instance_type          = "g4dn.xlarge"
  subnet_id              = local.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh

              # Install CloudWatch Logs agent
              yum install -y awslogs
              systemctl start awslogsd
              systemctl enable awslogsd.service

              # Configure CloudWatch Logs agent
              cat <<EOT > /etc/awslogs/awslogs.conf
              [general]
              state_file = /var/lib/awslogs/agent-state

              [/var/log/messages]
              file = /var/log/messages
              log_group_name = /aws/ec2/stable_diffusion
              log_stream_name = {instance_id}/messages

              [/var/log/docker.log]
              file = /var/log/docker.log
              log_group_name = /aws/ec2/stable_diffusion
              log_stream_name = {instance_id}/docker

              [/var/log/cloud-init.log]
              file = /var/log/cloud-init.log
              log_group_name = /aws/ec2/stable_diffusion
              log_stream_name = {instance_id}/cloud-init
              EOT

              # Restart CloudWatch Logs agent
              systemctl restart awslogsd

              # Install git
              yum install -y git

              # Clone the repository
              git clone https://github.com/iKnowJavaScript/stable-diffusion-docker.git /home/ec2-user/stable-diffusion-docker

              # Change to the repository directory
              cd /home/ec2-user/stable-diffusion-docker

              # Checkout to the specific branch
              git checkout hackathon-poc

              # Run the build script
              ./build.sh build

               # Add the public key to the authorized_keys file
              echo "${aws_key_pair.generated_key.public_key}" > /home/ec2-user/.ssh/authorized_keys
              chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
              chmod 600 /home/ec2-user/.ssh/authorized_keys
              EOF

  tags = {
    Name        = "${local.name}-${local.environment}"
    Type        = "StableDiffusionInstance"
    Environment = local.environment
  }
}

resource "aws_security_group" "ec2_security_group" {
  name        = "${local.name}-ec2-sg-${local.environment}"
  description = "Allow SSH and HTTP"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# logs
resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name              = "/aws/ec2/stable_diffusion"
  retention_in_days = 7
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
