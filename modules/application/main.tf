resource "aws_ecr_repository" "vaultpay" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"
  force_delete         = var.force_delete_ecr

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project_name}-repository"
    Project = var.project_name
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket        = "vaultpay-app-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.force_delete_s3

  tags = {
    Name    = "${var.project_name}-app-bucket"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name    = "${var.project_name}-ec2-role"
    Project = var.project_name
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name    = "${var.project_name}-ec2-profile"
    Project = var.project_name
  }
}

resource "aws_iam_policy_attachment" "SSM" {
  name       = "${var.project_name}-SSM-policy"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ECR_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy" "inline_policy_1" {
  name = "${var.project_name}-inline-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = var.db_master_secret_arn

      },
      {
        Action   = "s3:PutObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.app_bucket.arn}/reports/*"
      }
    ]
  })

}

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow inbound connections through port 80 to the vaultpay alb"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project_name}-alb-sg"
    Project = var.project_name
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

resource "aws_lb" "vaultpay_alb" {
  name               = "${var.project_name}-application-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name    = "${var.project_name}-application-alb"
    Project = var.project_name
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.project_name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    interval            = 30
    unhealthy_threshold = 3
    healthy_threshold   = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project_name}-alb-tg"
    Project = var.project_name
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.vaultpay_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  tags = {
    Name    = "${var.project_name}-alb-listener"
    Project = var.project_name
  }
}

resource "aws_launch_template" "main" {
  name_prefix            = "${var.project_name}-app-"
  instance_type          = "t4g.small"
  vpc_security_group_ids = [var.app_sg_id]
  image_id               = data.aws_ssm_parameter.al2023_arn.value

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region           = data.aws_region.current.region
    ecr_registry         = split("/", aws_ecr_repository.vaultpay.repository_url)[0]
    ecr_repository_url   = aws_ecr_repository.vaultpay.repository_url
    image_tag            = var.image_tag
    db_master_secret_arn = var.db_master_secret_arn
    db_host              = split(":", var.db_endpoint)[0]
    db_port              = var.db_port
    db_name              = var.db_name
    artifact_bucket_name = aws_s3_bucket.app_bucket.id
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project_name}-app"
      Project = var.project_name
    }
  }

  tags = {
    Name    = "${var.project_name}-app-lt"
    Project = var.project_name
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.project_name}-app-asg"
  vpc_zone_identifier       = var.app_private_subnet_ids
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.alb_tg.arn]

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}