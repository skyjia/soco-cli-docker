#!/bin/bash
set -e

# Build base command with optional flags
SONOS_OPTS=""

# Handle LOG_LEVEL environment variable - maps to --log parameter
if [ -n "$LOG_LEVEL" ]; then
    SONOS_OPTS="--log $LOG_LEVEL"
fi

# Handle USE_LOCAL_CACHE environment variable - maps to -l flag
if [ "$USE_LOCAL_CACHE" = "TRUE" ] || [ "$USE_LOCAL_CACHE" = "true" ]; then
    SONOS_OPTS="$SONOS_OPTS -l"
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
        # Pass LOG_LEVEL via --log if set
        shift
        HTTP_OPTS=""
        if [ -n "$LOG_LEVEL" ]; then
            HTTP_OPTS="--log $LOG_LEVEL"
        fi
        if [ "$USE_LOCAL_CACHE" = "TRUE" ] || [ "$USE_LOCAL_CACHE" = "true" ]; then
            HTTP_OPTS="$HTTP_OPTS -l"
        fi
        if [ -n "$SUBNETS" ]; then
            HTTP_OPTS="$HTTP_OPTS --subnets $SUBNETS"
        fi
        exec sonos-http-api-server $HTTP_OPTS "$@"
        ;;
    --)
        # Pass remaining args directly to sonos (bypass routing)
        shift
        if [ -n "$SONOS_OPTS" ]; then
            exec sonos $SONOS_OPTS "$@"
        else
            exec sonos "$@"
        fi
        ;;
    --help|-h)
        # Show combined help
        echo "soco-cli Docker Image - Sonos Control Tools"
        echo ""
        echo "Usage: docker run --rm --network host skyjia/soco-cli:latest <command> [args]"
        echo ""
        echo "Environment Variables:"
        echo "  SPKR             Default speaker name (e.g., 'Living Room')"
        echo "  LOG_LEVEL         Log level (NONE, CRITICAL, ERROR, WARN, INFO, DEBUG)"
        echo "  USE_LOCAL_CACHE  Set to TRUE to use cached speaker list"
        echo "  SUBNETS           Network subnets for HTTP API server (e.g., '192.168.1.0/24')"
        echo ""
        echo "Commands:"
        echo "  discover [options]       Discover Sonos devices on network"
        echo "  http-api-server [opts]   Start HTTP API server (default port 8000)"
        echo "  <speaker> <action>       Control Sonos speaker (sonos CLI)"
        echo "  -i                       Interactive mode"
        echo "  -- <args>                Pass args directly to sonos CLI"
        echo ""
        echo "Examples:"
        echo "  # Discover devices"
        echo "  docker run --rm --network host skyjia/soco-cli:latest discover"
        echo ""
        echo "  # HTTP API server with subnet"
        echo "  docker run -d --network host -e SUBNETS='192.168.1.0/24' skyjia/soco-cli:latest http-api-server -p 8000"
        echo ""
        echo "  # Speaker control with logging"
        echo "  docker run --rm --network host -e LOG_LEVEL=DEBUG skyjia/soco-cli:latest \"Living Room\" play"
        echo ""
        echo "  # Using SPKR environment variable"
        echo "  docker run --rm --network host -e SPKR=\"Living Room\" skyjia/soco-cli:latest play"
        echo ""
        echo "  # Using cached discovery"
        echo "  docker run --rm --network host -e USE_LOCAL_CACHE=TRUE skyjia/soco-cli:latest play"
        echo ""
        echo "For full sonos CLI help, run: docker run --rm --network host skyjia/soco-cli:latest -- --help"
        exit 0
        ;;
    "")
        # No arguments - show sonos help
        if [ -n "$SONOS_OPTS" ]; then
            exec sonos $SONOS_OPTS --help
        else
            exec sonos --help
        fi
        ;;
    *)
        # Default to sonos CLI for speaker control
        if [ -n "$SONOS_OPTS" ]; then
            exec sonos $SONOS_OPTS "$@"
        else
            exec sonos "$@"
        fi
        ;;
esac