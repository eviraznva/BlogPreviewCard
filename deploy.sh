#!/bin/bash

# Load environment variables
source ~/.bashrc

# Domain name variable
DOMAIN="blog_preview_card.eviraznva.pl"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
DOCKER_COMPOSE_PATH="./docker-compose.yml"  # Update this path

# Paths to Let's Encrypt certificates
SSL_CERT="/etc/letsencrypt/live/eviraznva.pl-0001/fullchain.pem"
SSL_CERT_KEY="/etc/letsencrypt/live/eviraznva.pl-0001/privkey.pem"

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null
then
    echo ".NET SDK is not installed. Installing .NET SDK..."
    # Set .NET SDK version
    DOTNET_SDK_VERSION="9.0.100-preview.5.24306.11"

    # Download .NET SDK
    wget https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz

    # Create destination directory
    sudo mkdir -p /usr/share/dotnet

    # Extract package to destination directory
    sudo tar -zxf dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz -C /usr/share/dotnet

    # Add path to environment variable PATH
    echo 'export PATH=$PATH:/usr/share/dotnet' >> ~/.bashrc
    source ~/.bashrc

    # Verify installation
    dotnet --version
else
    echo ".NET SDK is already installed."
fi

# Publish the project locally
dotnet publish BlogPreviewCard/BlogPreviewCard.csproj -c Release -o ./publish

# Create Nginx configuration file
echo "Creating Nginx configuration for $DOMAIN"

sudo tee $NGINX_SITES_AVAILABLE/$DOMAIN > /dev/null <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    # Redirect from HTTP to HTTPS
    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    # Paths to Let's Encrypt SSL certificates
    ssl_certificate $SSL_CERT;
    ssl_certificate_key $SSL_CERT_KEY;

    location / {
        proxy_pass http://localhost:5001;  # Update port if needed
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Create symlink in sites-enabled
echo "Enabling site $DOMAIN"
sudo ln -s $NGINX_SITES_AVAILABLE/$DOMAIN $NGINX_SITES_ENABLED/

# Test Nginx configuration
echo "Testing Nginx configuration"
sudo nginx -t

# Restart Nginx
echo "Restarting Nginx"
sudo systemctl restart nginx

# Build Docker images and run Docker Compose
echo "Building Docker images and running Docker Compose"
sudo docker compose -f $DOCKER_COMPOSE_PATH up -d

echo "Deployment completed"
