# Development Dockerfile for testing n8n-nodes-mediafx
FROM n8nio/n8n:latest

# Switch to root to install packages
USER root

# Install system dependencies for media processing
RUN apk add --no-cache \
    ffmpeg \
    imagemagick \
    && rm -rf /var/cache/apk/*

# Switch back to node user
USER node

# Set working directory
WORKDIR /home/node

# Copy package files
COPY package*.json ./
COPY dist/ ./dist/
COPY fonts/ ./fonts/

# Install the node as a local package
RUN npm install --omit=dev

# Create n8n user data directory and install the node
RUN mkdir -p ~/.n8n/nodes && \
    cd ~/.n8n/nodes && \
    npm init -y && \
    npm install /home/node

# Set environment variables for n8n
ENV N8N_CUSTOM_EXTENSIONS="/home/node/.n8n/nodes"

# Expose n8n port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"]
