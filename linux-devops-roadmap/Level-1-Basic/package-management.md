# Package Management: install git, nginx, java

Examples:
- Debian/Ubuntu:
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git nginx openjdk-17-jdk

- RHEL/CentOS/Amazon Linux:
  sudo yum update -y
  sudo yum install -y git nginx
  # Amazon Linux Corretto (java)
  sudo yum install -y java-17-amazon-corretto
