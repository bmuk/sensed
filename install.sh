#!/bin/bash

ensure_up_to_date () {
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get dist-upgrade -y
}

# Make sure wheezy is up to date
ensure_up_to_date

# Change to jessie
sudo sed -i 's/wheezy/jessie/' /etc/apt/sources.list
ensure_up_to_date

# Make sure utilities are installed
sudo apt-get install -y --force-yes curl git systemd systemd-sysv

# Get nodejs
curl --silent --location http://deb.nodesource.com/setup_0.12 | sudo bash -
sudo apt-get install -y nodejs

# Create a user which will run sensed
sudo useradd -G i2c sensed
sudo mkdir /home/sensed
sudo chown sensed /home/sensed
sudo chgrp sensed /home/sensed

# Clone this repo and install dependencies
su sensed <<EOF
pushd /home/sensed
git clone https://github.com/bmuk/sensed
cd sensed
cp ./config/config.sample.json config.json
npm install
EOF

# Create systemd service
sudo cat <<EOF > /etc/systemd/system/sensed.service
[Service]
ExecStart=/usr/local/bin/node /home/sensed/sensed/sensed.js
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=sensed
User=sensed
Group=sensed
Environment=NODE_ENV=development

[Install]
WantedBy=multi-user.target
EOF

# Enable and start sensed
sudo systemctl enable sensed
sudo systemctl start sensed

# Let user know the installation is broken (not configured yet)
echo 'Update /home/sensed/sensed/config/config.json to reflect this installation.'
