#!/bin/bash

# Local Docker Build Script
# Based on .github/workflows/docker-hub.yml

set -e

# Default values
IMAGE_NAME="alaugks/apache-php"
TAG="local"
ENABLE_XDEBUG="0"

# Parse named parameters
while [[ $# -gt 0 ]]; do
    case $1 in
        --tag)
            TAG="$2"
            shift 2
            ;;
        --with-xdebug)
            ENABLE_XDEBUG="1"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --tag TAG          Set image tag (default: local)"
            echo "  --with-xdebug      Enable XDebug build"
            echo "  --help, -h         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0"
            echo "  $0 --tag 8.2.29"
            echo "  $0 --tag 8.2.29 --with-xdebug"
            echo "  $0 --with-xdebug"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Building Docker image..."
echo "Image: ${IMAGE_NAME}:${TAG}"
echo "XDebug enabled: ${ENABLE_XDEBUG}"
echo ""

# Build without XDebug
if [ "${ENABLE_XDEBUG}" = "0" ]; then
    docker build \
        --build-arg ENABLE_XDEBUG=0 \
        -t "${IMAGE_NAME}:${TAG}" \
        -f Dockerfile \
        .

    echo ""
    echo "✓ Build completed successfully!"
    echo "Image: ${IMAGE_NAME}:${TAG}"
else
    # Build with XDebug
    docker build \
        --build-arg ENABLE_XDEBUG=1 \
        -t "${IMAGE_NAME}:${TAG}-xdebug" \
        -f Dockerfile \
        .

    echo ""
    echo "✓ Build completed successfully!"
    echo "Image: ${IMAGE_NAME}:${TAG}-xdebug"
fi

echo ""
echo "Usage examples:"
echo "  docker run -p 8080:80 -v \$(pwd):/var/www/app --rm ${IMAGE_NAME}:${TAG}"
if [ "${ENABLE_XDEBUG}" = "1" ]; then
    echo "  docker run -p 8080:80 -v \$(pwd):/var/www/app --rm ${IMAGE_NAME}:${TAG}-xdebug"
fi
