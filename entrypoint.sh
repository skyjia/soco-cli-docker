#!/bin/bash
set -e

# Handle LOG_LEVEL environment variable
if [ -n "$LOG_LEVEL" ]; then
    # Pass log level to soco-cli via --log flag for commands that support it
    export SOCO_LOG_ARGS="--log $LOG_LEVEL"
fi

# Handle config directory mapping
# If /config/.soco-cli is mounted, use it as the config directory
if [ -d "/config/.soco-cli" ] && [ "$(ls -A /config/.soco-cli 2>/dev/null)" ]; then
    export HOME="/config"
elif [ -d "/config" ]; then
    # If /config is mounted but empty, link it to user's config
    if [ ! -L "/home/sonos/.soco-cli" ]; then
        ln -sf /config /home/sonos/.soco-cli 2>/dev/null || true
    fi
fi

# Execute sonos command with all arguments
exec sonos "$@"