# Multi-Cloud AI-Powered Honeypot System with Centralised Threat Detection
This project deploys Cowrie honeypot systems across AWS, Azure, and GCP, all integrated into a centralized ELK stack hosted on GCP for unified log analysis. The goal is to enhance security monitoring by integrating a lightweight machine learning model that processes cowrie.json logs to:

Detect login attempts automatically

Identify the source country of each attempt

Enable automated detection and basic threat response

The ML model will be trained on parsed Cowrie logs and deployed directly on the GCP ELK VM, enabling real-time AI-driven security insights without relying on complex infrastructure.

#Setup GCP instance using the terraform tool - 

#Setup AWS instance using the terraform tool - 

#Setup Azure VM using the terraform tool - 

#Setup ELK-Stack VM using the terraform tool - 
