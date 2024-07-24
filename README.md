# hng-devopsfetch-project
# DevOpsFetch

## Overview
DevOpsFetch is a tool for server information retrieval and monitoring. It collects and displays system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses. It also includes a systemd service to monitor and log these activities continuously.

## Installation

1. Clone the repository or download the script files.
2. Run the installation script:

   ```bash
   ./install_devopsfetch.sh

# Test the devopsfetch.sh Script

      ## Test displaying all active ports and services:
    bash
    ./devopsfetch.sh -p

      ## Test displaying detailed information about a specific port (e.g., port 80):
    bash
    ./devopsfetch.sh -p 80

      ## Test listing all Docker images and containers:
    bash
    ./devopsfetch.sh -d

      ## Test providing detailed information about a specific Docker container (replace container_name with an actual container name):
    bash
    ./devopsfetch.sh -d container_name

      ## Test displaying all Nginx domains and their ports:
    bash
    ./devopsfetch.sh -n

      ## Test providing detailed configuration information for a specific Nginx domain (replace domain_name with an actual domain):
    bash
    ./devopsfetch.sh -n domain_name

      ## Test listing all users and their last login times:
    bash
    ./devopsfetch.sh -u

      ## Test providing detailed information about a specific user (replace username with an actual username):
    bash
    ./devopsfetch.sh -u username

      ## Test displaying activities within a specified time range (replace start and end with actual dates):
    bash
    ./devopsfetch.sh -t "2024-07-01" "2024-07-10"


# Test the Installation Script and Systemd Service
    Run the installation script with sudo:
    bash
    sudo ./install_devopsfetch.sh

    ## Check if the service is running:
        bash
        sudo systemctl status devopsfetch.service
        You should see an output indicating that the service is active and running.

      ### Check the service logs:
          bash
          sudo journalctl -u devopsfetch.service
          Review the logs to ensure the service is running correctly and logging the expected information.