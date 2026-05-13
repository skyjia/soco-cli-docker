# soco-cli Docker Image

[中文文档](README-CN.md)

Docker image for [soco-cli](https://github.com/avantrec/soco-cli), providing a convenient environment for managing Sonos devices.

**GitHub**: [skyjia/soco-cli-docker](https://github.com/skyjia/soco-cli-docker)
**Docker Hub**: [skyjia/soco-cli](https://hub.docker.com/r/skyjia/soco-cli)

## Features

- Pre-installed latest soco-cli
- Lightweight multi-stage build
- Multi-platform support: linux/amd64, linux/arm64
- CLI mode: execute Sonos control commands directly
- Interactive mode: enter interactive command-line interface
- HTTP API mode: start HTTP API server (default port 8000)
- Non-root user execution for security
- Persistent config directory and music library

## Supported Platforms

| Platform | Architecture | Use Case |
|----------|-------------|----------|
| `linux/amd64` | x86_64 | Standard servers, desktops, cloud VMs |
| `linux/arm64` | ARM 64-bit | Apple Silicon Mac, Raspberry Pi 4, ARM cloud instances |

> **Windows Users**: Docker Desktop on Windows uses WSL2 to run Linux containers. This image works on Windows through Docker Desktop without any modifications.

## Image Tags

| Tag | Type | Description |
|-----|------|-------------|
| `latest` | Multi-arch | Auto-detects your architecture (recommended) |
| `vX.Y.Z` | Multi-arch | Version-specific, auto-detects architecture |
| `amd64` | Single-arch | x86_64 architecture only |
| `arm64` | Single-arch | ARM 64-bit architecture only |

```bash
# Auto-detect architecture (recommended)
docker pull skyjia/soco-cli:latest

# Force specific architecture
docker pull skyjia/soco-cli:amd64
docker pull skyjia/soco-cli:arm64
```

## Requirements

- Docker installed on your system
- Sonos devices connected to the same local network
- For Windows: Docker Desktop with WSL2 enabled

## Quick Start

### Pull from Docker Hub

```bash
docker pull skyjia/soco-cli:latest
```

### Build Image (Optional)

```bash
docker build -t skyjia/soco-cli:latest .
```

### Using Docker Compose

```bash
# Set music library path
export MUSIC_PATH=/path/to/your/music

# Start container
docker-compose up -d

# Execute commands
docker-compose exec soco-cli sonos --help
```

## Usage Examples

### CLI Mode

```bash
# Show help
docker run --rm --network host skyjia/soco-cli:latest --help

# List all devices
docker run --rm --network host skyjia/soco-cli:latest list

# Play music
docker run --rm --network host skyjia/soco-cli:latest "Living Room" play

# Set volume
docker run --rm --network host skyjia/soco-cli:latest "Living Room" volume 50
```

### Interactive Mode

```bash
docker run -it --rm --network host skyjia/soco-cli:latest -i
```

### HTTP API Mode

```bash
# Start HTTP API server (port 8000)
docker run -d --network host skyjia/soco-cli:latest http-api-server -p 8000

# Test API
curl http://localhost:8000/Living%20Room/play
curl http://localhost:8000/Living%20Room/volume/50
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_LEVEL` | Log level (NONE, CRITICAL, ERROR, WARN, INFO, DEBUG) | INFO |

## Mount Points

| Path | Description |
|------|-------------|
| `/config` | Config directory, stores soco-cli settings and aliases |
| `/music` | Local music library path (read-only access) |

## Network Configuration

Uses `network_mode: host` for discovering Sonos devices in the local network. This is the simplest configuration with no additional network setup required.

### SSDP Discovery Mechanism

soco-cli uses SSDP multicast for device discovery:
- **Multicast address**: 239.255.255.250
- **UDP port**: 1900
- **Outgoing port**: Variable (ephemeral port range, e.g., 32768–60999 on Linux)

If the firewall blocks incoming UDP traffic on the ephemeral port range, standard discovery will fail and fall back to slower network scan discovery. To ensure fast discovery:

```bash
# Example: Open ephemeral UDP ports on Linux (ufw)
sudo ufw allow 32768:60999/udp
```

## FAQ

### Cannot discover Sonos devices

1. Ensure the container uses `--network host` mode
2. Verify the host machine is on the same LAN as Sonos devices
3. Check firewall settings - allow incoming UDP traffic on ephemeral ports (e.g., 32768–60999)
4. If discovery is slow, consider using cached discovery with `-l` flag

### Configuration not saved

Check if `/config` directory is correctly mounted with write permissions.

### HTTP API inaccessible

Verify the port is not occupied and firewall allows access.

## Related Links

- [soco-cli GitHub](https://github.com/avantrec/soco-cli)
- [soco-cli Documentation](https://github.com/avantrec/soco-cli#readme)
- [Sonos Official Documentation](https://docs.sonos.com/)

## License

This project is licensed under the [MIT License](LICENSE).