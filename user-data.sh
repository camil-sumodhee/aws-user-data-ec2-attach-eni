#!/bin/bash

# ENI Settings
ENI_ID="eni-9ea340ae"
ENI_IP="10.1.11.100"
ENI_MASK="32"
ENI_GW="10.1.11.1"
ETH_DEVICE_INDEX="2" # The nth network interface of the instance
ETHX="eth"$[$ETH_DEVICE_INDEX-1] # for index=2, will add eth1 to the instance

# Installations below are required for Ubuntu 16.04
# Install pip
curl -O https://bootstrap.pypa.io/get-pip.py || (echo "Error while downloading pip." && exit 1)
python3 get-pip.py --user || (echo "Error while installing pip." && exit 1)
~/.local/bin/pip --version || (echo "Error, pip not installed." && exit 1)

# Install aws cli with pip
~/.local/bin/pip install awscli --upgrade --user || (echo "Error while installing awscli." && exit 1)

# Attach the ENI to the instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
~/.local/bin/aws ec2 attach-network-interface --region $REGION --instance-id $INSTANCE_ID --device-index $ETH_DEVICE_INDEX --network-interface-id $ENI_ID || (echo "Error while attaching the ENI to the instance." && exit 1)

# Configure the network interface ethx as DHCP to catch the ENI IP and config.
# Also configure an additional routing table tab $ETH_DEVICE_INDEX
touch /etc/network/interfaces.d/$ETHX.cfg
echo "auto $ETHX" >> /etc/network/interfaces.d/$ETHX.cfg
echo "iface $ETHX inet dhcp" >> /etc/network/interfaces.d/$ETHX.cfg
echo "  up ip route add default via $ENI_GW dev $ETHX tab $ETH_DEVICE_INDEX" >> /etc/network/interfaces.d/$ETHX.cfg
echo "  up ip rule add from $ENI_IP/$ENI_MASK tab $ETH_DEVICE_INDEX" >> /etc/network/interfaces.d/$ETHX.cfg
echo "  up ip rule add to $ENI_IP/$ENI_MASK tab $ETH_DEVICE_INDEX" >> /etc/network/interfaces.d/$ETHX.cfg
echo "  up ip route flush cache" >> /etc/network/interfaces.d/$ETHX.cfg
