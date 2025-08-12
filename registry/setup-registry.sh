#!/bin/bash
# Setup Docker Registry for homelab infrastructure
# General-purpose registry for storing container images

set -e

DOCKER_HOST="${DOCKER_HOST:-10.0.0.35}"
REGISTRY_PORT="${REGISTRY_PORT:-5000}"
REGISTRY_NAME="registry"

echo "=== Docker Registry Setup ==="
echo "Docker Host: $DOCKER_HOST"
echo "Registry Port: $REGISTRY_PORT"
echo ""

# Function to check if registry is already running
check_registry() {
    echo "Checking if registry is already running..."
    if ssh ubuntu@$DOCKER_HOST "docker ps --filter name=$REGISTRY_NAME --filter status=running --quiet" | grep -q .; then
        echo "✅ Registry is already running"
        return 0
    else
        echo "❌ Registry is not running"
        return 1
    fi
}

# Function to start the registry
start_registry() {
    echo "Starting Docker registry on $DOCKER_HOST:$REGISTRY_PORT..."
    
    ssh ubuntu@$DOCKER_HOST << EOF
        # Stop and remove existing registry if it exists (but not running)
        docker stop $REGISTRY_NAME 2>/dev/null || true
        docker rm $REGISTRY_NAME 2>/dev/null || true
        
        # Start new registry with persistent storage
        docker run -d \\
            --name $REGISTRY_NAME \\
            --restart=always \\
            -p $REGISTRY_PORT:5000 \\
            -v registry-data:/var/lib/registry \\
            registry:2
        
        echo "Registry started successfully!"
        
        # Wait a moment for startup
        sleep 2
        
        # Verify it's running
        docker ps --filter name=$REGISTRY_NAME
EOF
}

# Function to test registry connectivity
test_registry() {
    echo "Testing registry connectivity..."
    
    # Test from current location
    if curl -f http://$DOCKER_HOST:$REGISTRY_PORT/v2/ >/dev/null 2>&1; then
        echo "✅ Registry is accessible at http://$DOCKER_HOST:$REGISTRY_PORT"
    else
        echo "❌ Registry is not accessible"
        return 1
    fi
}

# Main execution
main() {
    if check_registry; then
        echo "Registry is already running. Skipping setup."
    else
        echo "Setting up new registry..."
        start_registry
    fi
    
    echo ""
    test_registry
    
    echo ""
    echo "=== Registry Setup Complete ==="
    echo "Registry URL: http://$DOCKER_HOST:$REGISTRY_PORT"
    echo "Registry API: http://$DOCKER_HOST:$REGISTRY_PORT/v2/"
    echo ""
    echo "Usage examples:"
    echo "  docker tag myimage:latest $DOCKER_HOST:$REGISTRY_PORT/myimage:latest"
    echo "  docker push $DOCKER_HOST:$REGISTRY_PORT/myimage:latest"
}

# Run main function
main "$@"