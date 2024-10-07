#!/bin/bash

# Cloudflare DDNS Update Script
# This script updates Cloudflare DNS records when your public IP changes.
# It's designed to be run periodically (e.g., via cron job) to keep your DNS records up to date.

set -euo pipefail  # Enable strict mode

# Configuration variables
API_TOKEN_FILE="/path/to/api_token.txt"  # Store API token in a separate file with restricted permissions
LOGFILE="/path/to/your/logfile.log"      # Path to the log file
IP_SERVICE="https://ipv4.icanhazip.com"  # Use HTTPS for secure communication

# Read API token from file
API_TOKEN=$(cat "$API_TOKEN_FILE")

# Array of domains to manage
# Format: "ZONE_ID RECORD_ID DOMAIN_NAME"
DOMAINS=(
    "your_zone_id_1 your_record_id_1 your.domain1.com"
    "your_zone_id_2 your_record_id_2 your.domain2.com"
    # Add more domains as needed
)

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Function to securely get the current public IP
get_public_ip() {
    local ip
    ip=$(curl -s -f -4 "$IP_SERVICE")
    if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_message "Error: Invalid IP address obtained: $ip"
        return 1
    fi
    echo "$ip"
}

# Get the current public IP
CURRENT_IP=$(get_public_ip)

# Check if the public IP was obtained successfully
if [ -z "$CURRENT_IP" ]; then
    log_message "Error: Unable to obtain public IP."
    exit 1
fi

# Loop through each domain and update if necessary
for DOMAIN_INFO in "${DOMAINS[@]}"
do
    # Split the domain info into separate variables
    read -r ZONE_ID RECORD_ID DOMAIN_NAME <<< "$DOMAIN_INFO"

    # Get the current IP set in the DNS record
    DNS_IP=$(curl -s -f -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
         -H "Authorization: Bearer $API_TOKEN" \
         -H "Content-Type: application/json" | jq -r '.result.content')

    # Check if the IP has changed
    if [ "$CURRENT_IP" == "$DNS_IP" ]; then
        log_message "$DOMAIN_NAME: IP hasn't changed, no update needed."
        continue
    fi

    # Update the DNS record if the IP has changed
    UPDATE=$(curl -s -f -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
         -H "Authorization: Bearer $API_TOKEN" \
         -H "Content-Type: application/json" \
         --data "{\"type\":\"A\",\"name\":\"$DOMAIN_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":false}")

    # Check if the update was successful
    if jq -e '.success == true' <<< "$UPDATE" > /dev/null; then
        log_message "$DOMAIN_NAME: Update successful. New IP: $CURRENT_IP"
    else
        log_message "$DOMAIN_NAME: Update failed. Response: $UPDATE"
    fi
done
