# 1. Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# 3. Create Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-rt"
    Environment = var.environment
  }
}

# 4. Create Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name        = "${var.environment}-subnet"
    Environment = var.environment
  }
}

# 5. Associate Route Table with Subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# 6. Create Security Group
resource "aws_security_group" "main" {
  name        = "${var.environment}-sg"
  description = "Allow SSH, HTTP, HTTPS and FastAPI traffic"
  vpc_id      = aws_vpc.main.id

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-sg"
    Environment = var.environment
  }
}

# 7. Create Network Interface
resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.main.id
  private_ips     = [var.private_ip]
  security_groups = [aws_security_group.main.id]

  tags = {
    Name        = "${var.environment}-ni"
    Environment = var.environment
  }
}

# 8. Assign Elastic IP
resource "aws_eip" "main" {
  domain            = "vpc"
  network_interface = aws_network_interface.main.id
  depends_on        = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.environment}-eip"
    Environment = var.environment
  }
}

# 9. Create EC2 Instance
resource "aws_instance" "main" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = var.key_name
  subnet_id         = aws_subnet.main.id

  vpc_security_group_ids = [aws_security_group.main.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              sudo apt-get update -y
              sudo apt-get upgrade -y

              # Install Docker
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              # Install Python and Pip
              sudo apt-get install -y python3 python3-pip

              # Install FastAPI and Uvicorn
              pip3 install fastapi uvicorn

              # Create FastAPI app
              mkdir -p /app
              cat > /app/main.py <<'APPEOF'
              from fastapi import FastAPI

              app = FastAPI()

              @app.get("/")
              def read_root():
                  return {"message": "Hello from ${var.environment} environment!"}

              @app.get("/health")
              def health_check():
                  return {"status": "healthy", "environment": "${var.environment}"}
              APPEOF

              # Run FastAPI app
              cd /app
              uvicorn main:app --host 0.0.0.0 --port 8000 &
              EOF

  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
  }
}