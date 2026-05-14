#!/bin/bash
set -e

# Handle LOG_LEVEL environment variable
if [ -n "$LOG_LEVEL" ]; then
    export SOCO_LOG_ARGS="--log $LOG_LEVEL"
fi

# Handle config directory mapping
if [ -d "/config/.soco-cli" ] && [ "$(ls -A /config/.soco-cli 2>/dev/null)" ]; then
    export HOME="/config"
elif [ -d "/config" ]; then
    if [ ! -L "/home/sonos/.soco-cli" ]; then
        ln -sf /config /home/sonos/.soco-cli 2>/dev/null || true
    fi
fi

# Smart routing based on first argument
CMD="${1:-}"

case "$CMD" in
    discover)
        # Run sonos-discover for device discovery
        shift
        exec sonos-discover "$@"
        ;;
    http-api|http-api-server|api-server)
        # Run sonos-http-api-server for HTTP API mode
        shift
        exec sonos-http-api-server "$@"
        ;;
    --help|-h)
        # Show combined help
        echo "soco-cli Docker Image - Sonos Control Tools"
        echo ""
        echo "Usage: docker run --rm --network host skyjia/soco-cli:latest <command> [args]"
        echo ""
        echo "Commands:"
        echo "  discover [options]     Discover Sonos devices on network"
        echo "  http-api-server [opts] Start HTTP API server (default port 8000)"
        echo "  <speaker> <action>     Control Sonos speaker (sonos CLI)"
        echo "  -i                     Interactive mode"
        echo ""
        echo "Examples:"
        echo "  docker run --rm --network host skyjia/soco-cli:latest discover"
        echo "  docker run --d --network host skyjia/soco-cli:latest http-api-server -p 8000"
        echo "  docker run --rm --network host skyjia/soco-cli:latest \"Living Room\" volume 50"
        echo ""
        echo "For full sonos CLI help, run: docker run --rm --network host skyjia/soco-cli:latest sonos --help"
        exit 0
        ;;
    sonos|--actions|--commands|zones|info|sysinfo|state|groups|volume|play|pause|stop|next|previous|"")
        # Run sonos CLI (default)
        exec sonos "$@"
        ;;
    *)
        # Default to sonos CLI for speaker control
        exec sonos "$@"
        ;;
esac