# Multi-Cloud AI-Powered Honeypot System with Centralised Threat Detection
This project deploys Cowrie honeypot systems across AWS, Azure, and GCP, all integrated into a centralized ELK stack hosted on GCP for unified log analysis. The goal is to enhance security monitoring by integrating a lightweight machine learning model that processes cowrie.json logs to:

      Detect login attempts automatically

      Identify the source country of each attempt

      Enable automated detection and basic threat response

- The ML model will be trained on parsed Cowrie logs and deployed directly on the GCP ELK VM, enabling real-time AI-driven security insights without relying on complex infrastructure.

#Setup GCP instance using the terraform tool:
- Configure GCP credentials (gcloud auth application-default login).

- Create a Terraform file (e.g., main.tf) defining the GCP provider and VM resource.

- Define VM settings (machine type, image, zone, etc.).

- Add metadata_startup_script to auto-install Cowrie.

- Run:
      terraform init
      terraform apply

#Setup AWS instance using the terraform tool:
- Configure AWS credentials (aws configure).

- Create a Terraform file for the AWS provider and EC2 instance.

- Define instance details (AMI ID, instance type, key pair, security group).

- Add user_data to install Cowrie on boot.
- Run:
      terraform init
      terraform apply

#Setup Azure VM using the terraform tool:
- Authenticate with Azure CLI (az login).

- Create a Terraform file for the Azure provider and VM resource.

- Define VM parameters (resource group, location, image, size).

- Include a custom_data script to install Cowrie.
- Run:
      terraform init
      terraform apply

#Setup ELK-Stack VM using the terraform tool:
- Choose GCP to host the centralised ELK VM.

- Define VM resource in Terraform with higher specs (e.g., 4vCPU, 16GB RAM).

- dd metadata_startup_script or user_data to install ELK stack components:

    - Elasticsearch

    - Logstash

    - Kibana

    - Filebeat (optional for log forwarding)

- Expose necessary ports (5601, 9200, 5044) in the firewall rules.
- Run:
      terraform init
      terraform apply
