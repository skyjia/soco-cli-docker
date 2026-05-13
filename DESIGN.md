# soco-cli Docker Image Design Document

## Design Principles

1. **Lightweight**: Multi-stage build to minimize image size
2. **Secure**: Non-root user execution, read-only music library mount
3. **Simple**: Default CLI mode, user chooses runtime mode as needed
4. **Persistent**: Config directory mount for data persistence

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Container                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  Runtime Stage                       │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │   │
│  │  │ Python 3.13 │  │  soco-cli   │  │ entrypoint  │  │   │
│  │  │    (slim)   │  │  (latest)   │  │    .sh      │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │   │
│  │           │              │              │           │   │
│  │           ▼              ▼              ▼           │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │           User: sonos (non-root)            │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Volumes                           │   │
│  │  ┌─────────────┐              ┌─────────────┐       │   │
│  │  │   /config   │              │   /music    │       │   │
│  │  │  (rw)       │              │   (ro)      │       │   │
│  │  └─────────────┘              └─────────────┘       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
              ┌─────────────────────┐
              │   Host Network      │
              │ (network_mode: host)│
              └─────────────────────┘
                          │
                          ▼
              ┌─────────────────────┐
              │   Sonos Devices     │
              │   (LAN Discovery)   │
              └─────────────────────┘
```

## Image Layer Structure

### Stage 1: Builder

```
python:3.13-slim
└── pip install soco-cli
```

Responsibility: Install soco-cli and dependencies without retaining build tools.

### Stage 2: Runtime

```
python:3.13-slim
├── Copy Python packages (from Builder)
├── Copy soco-cli binaries (from Builder)
├── Create user sonos
├── Create directory structure
├── Copy entrypoint.sh
└── Set permissions and user
```

Responsibility: Runtime environment, minimal size.

## Directory Structure

```
Container directories:
/home/sonos/           # User home directory
├── .soco-cli/         # soco-cli config (can link to /config)
│   ├── aliases.json   # Interactive mode aliases
│   └── speakers.json  # Device cache
/config/               # Mount point - config persistence
/music/                # Mount point - local music library (read-only)
```

## Network Configuration

### Host Network Mode

Reasons for using `network_mode: host`:

- Sonos device discovery relies on SSDP/UPnP protocol
- Requires direct access to LAN broadcast addresses
- Avoids discovery delays or failures caused by NAT
- Supports UDP multicast for SSDP discovery

### SSDP Discovery Details

soco-cli uses SSDP (Simple Service Discovery Protocol) multicast for device discovery:

| Parameter | Value |
|-----------|-------|
| Multicast address | 239.255.255.250 |
| UDP port | 1900 |
| Outgoing port range | Ephemeral ports (e.g., 32768–60999 on Linux) |

**Discovery flow**:
1. Container sends SSDP multicast request via UDP port 1900
2. Outgoing port is variable (OS-dependent ephemeral range)
3. Sonos devices respond to the outgoing port
4. If firewall blocks incoming UDP on ephemeral range, discovery falls back to slower network scan

**Firewall configuration** (Linux example):
```bash
sudo ufw allow 32768:60999/udp
```

### HTTP API Port

Default 8000, configurable via `-p` parameter:

```bash
sonos http-api-server -p 8000
```

## Runtime Modes

| Mode | Command | Usage |
|------|---------|-------|
| CLI | `sonos <args>` | Single command execution |
| Interactive | `sonos -i` | Interactive management |
| HTTP API | `sonos http-api-server -p <port>` | Service integration |

## Security Design

- **Non-root user**: All operations executed as `sonos` user
- **Read-only music library**: `/music` mounted with `:ro` to prevent accidental modifications
- **Minimal permissions**: Only necessary mount points and environment access

## Build Optimizations

| Optimization | Description |
|--------------|-------------|
| Multi-stage build | Build tools excluded from final image |
| Slim base image | Reduces ~70% size |
| No-cache install | `pip install --no-cache-dir` |

## Verification Tests

```bash
# Build test
docker build -t soco-cli:test .

# CLI functionality
docker run --rm --network host soco-cli:test --help

# Interactive mode
docker run -it --rm --network host soco-cli:test -i

# HTTP API
docker run -d --network host soco-cli:test http-api-server -p 8000
curl http://localhost:8000/ --help

# Non-root verification
docker run --rm --entrypoint "" soco-cli:test whoami
# Output: sonos
```