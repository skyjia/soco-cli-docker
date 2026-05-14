#!/bin/bash
set -e

# Handle LOG_LEVEL environment variable
if [ -n "$LOG_LEVEL" ]; then
    export SOCO_LOG_ARGS="--log $LOG_LEVEL"
fi

# Handle SPKR environment variable (default speaker)
# Allows omitting speaker name in sonos commands
if [ -n "$SPKR" ]; then
    export SPKR="$SPKR"
fi

# Handle config directory mapping
if [ -d "/config/.soco-cli" ] && [ "$(ls -A /config/.soco-cli 2>/dev/null)" ]; then
    export HOME="/config"
elif [ -d "/config" ]; then
    if [ ! -L "/home/sonos/.soco-cli" ]; then
        ln -sf /config /home/sonos/.soco-cli 2>/dev/null || true
    fi
fi

# Ensure macros.txt exists (for HTTP API server)
MACROS_FILE="${HOME}/macros.txt"
if [ ! -f "$MACROS_FILE" ]; then
    touch "$MACROS_FILE"
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
        echo "Environment Variables:"
        echo "  SPKR        Default speaker name (e.g., 'Living Room')"
        echo "  LOG_LEVEL   Log level (NONE, CRITICAL, ERROR, WARN, INFO, DEBUG)"
        echo ""
        echo "Commands:"
        echo "  discover [options]     Discover Sonos devices on network"
        echo "  http-api-server [opts] Start HTTP API server (default port 8000)"
        echo "  <speaker> <action>     Control Sonos speaker (sonos CLI)"
        echo "  -i                     Interactive mode"
        echo ""
        echo "Examples:"
        echo "  # Discover devices"
        echo "  docker run --rm --network host skyjia/soco-cli:latest discover"
        echo ""
        echo "  # HTTP API server"
        echo "  docker run -d --network host skyjia/soco-cli:latest http-api-server -p 8000"
        echo ""
        echo "  # Speaker control"
        echo "  docker run --rm --network host skyjia/soco-cli:latest \"Living Room\" play"
        echo ""
        echo "  # Using SPKR environment variable"
        echo "  docker run --rm --network host -e SPKR=\"Living Room\" skyjia/soco-cli:latest play"
        echo ""
        echo "For full sonos CLI help, run: docker run --rm --network host skyjia/soco-cli:latest -- --help"
        exit 0
        ;;
    "")
        # No arguments - show help
        exec sonos --help
        ;;
    *)
        # Default to sonos CLI for speaker control
        exec sonos "$@"
        ;;
esac