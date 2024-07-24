#!/bin/bash

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root. Use sudo..."
  sudo bash "$0" "$@"
  exit 1
fi

# Install necessary packages and dependencies
apt-get update
apt-get install -y net-tools docker.io nginx jq logrotate

# Create log directory and set permissions
mkdir -p /var/log/devopsfetch
chmod 755 /var/log/devopsfetch

# Create log file and set permissions
touch /var/log/devopsfetch/devopsfetch.log
chmod 644 /var/log/devopsfetch/devopsfetch.log


# Copy the devopsfetch script to the appropriate directory
cp devopsfetch.sh /usr/local/bin/
chmod +x /usr/local/bin/devopsfetch.sh

# Create systemd service file
cat << EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOpsFetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch.sh --monitor
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the systemd service
systemctl daemon-reload
systemctl enable devopsfetch.service
systemctl start devopsfetch.service

# Define source and destination paths
SOURCE="devopsfetch_logrotate.conf"
DESTINATION="/etc/logrotate.d/devopsfetch"

# Check if the source file exists
if [[ -f "$SOURCE" ]]; then
  # Copy the logrotate configuration file to the appropriate directory
  cp "$SOURCE" "$DESTINATION"
  echo "Logrotate configuration file copied to $DESTINATION"
else
  echo "Error: Source file $SOURCE does not exist."
  exit 1
fi

# # Copy the logrotate configuration file to the appropriate directory
# cp devopsfetch_logrotate.conf /etc/logrotate.d/devopsfetch
