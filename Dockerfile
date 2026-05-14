# soco-cli Docker Image
# Multi-stage build for minimal image size

# Stage 1: Build stage - install soco-cli
FROM python:3.13-slim AS builder
WORKDIR /app
RUN pip install --no-cache-dir soco-cli

# Stage 2: Runtime stage
FROM python:3.13-slim

# Create non-root user
RUN useradd --create-home --shell /bin/bash sonos

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Create config directory and macros file (for HTTP API server)
RUN mkdir -p /home/sonos/.soco-cli && \
    touch /home/sonos/macros.txt && \
    chown -R sonos:sonos /home/sonos

# Create mount points
RUN mkdir -p /config /music /macros && chown -R sonos:sonos /config /music /macros

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown sonos:sonos /entrypoint.sh

# Environment variables (can be overridden)
ENV LOG_LEVEL=INFO
ENV SPKR=
ENV USE_LOCAL_CACHE=
ENV SUBNETS=

# Set non-root user
USER sonos
WORKDIR /home/sonos

# Mount points for config, music library, and macros
VOLUME ["/config", "/music", "/macros"]

# Entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]