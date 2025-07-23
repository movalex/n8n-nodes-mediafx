#!/bin/bash

# Build and test script for n8n-nodes-mediafx

echo "🚀 Building n8n-nodes-mediafx for Docker testing..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build the project first
echo "📦 Building the npm package..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ npm build failed. Please fix the build errors first."
    exit 1
fi

echo "✅ Build successful!"

# Ask user which version to run
echo ""
echo "Which version would you like to test?"
echo "1) Development build (faster, includes dev dependencies)"
echo "2) Production build (slower, production-ready)"
echo "3) Both (development on port 5678, production on port 5679)"

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "🐳 Starting development build..."
        docker-compose up --build n8n-dev
        ;;
    2)
        echo "🐳 Starting production build..."
        docker-compose --profile prod up --build n8n-prod
        ;;
    3)
        echo "🐳 Starting both builds..."
        docker-compose --profile prod up --build
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "🎉 n8n is starting up!"
echo "📱 Access n8n at:"
if [ "$choice" = "1" ] || [ "$choice" = "3" ]; then
    echo "   Development: http://localhost:5678"
fi
if [ "$choice" = "2" ] || [ "$choice" = "3" ]; then
    echo "   Production:  http://localhost:5679"
fi
echo ""
echo "🔐 Default credentials:"
echo "   Username: admin"
echo "   Password: password"
echo ""
echo "📁 Test media files: Place files in ./test-media/ directory"
echo "   They'll be available at /home/node/test-media/ in n8n"
