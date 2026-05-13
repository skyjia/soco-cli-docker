# soco-cli Docker Image

[中文文档](README-CN.md)

Docker image for [soco-cli](https://github.com/avantrec/soco-cli), providing a convenient environment for managing Sonos devices.

## Features

- Pre-installed latest soco-cli
- CLI mode: execute Sonos control commands directly
- Interactive mode: enter interactive command-line interface
- HTTP API mode: start HTTP API server (default port 8000)
- Non-root user execution for security
- Persistent config directory and music library

## Quick Start

### Build Image

```bash
docker build -t soco-cli:latest .
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
docker run --rm --network host soco-cli:latest --help

# List all devices
docker run --rm --network host soco-cli:latest list

# Play music
docker run --rm --network host soco-cli:latest "Living Room" play

# Set volume
docker run --rm --network host soco-cli:latest "Living Room" volume 50
```

### Interactive Mode

```bash
docker run -it --rm --network host soco-cli:latest -i
```

### HTTP API Mode

```bash
# Start HTTP API server (port 8000)
docker run -d --network host soco-cli:latest http-api-server -p 8000

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

## FAQ

### Cannot discover Sonos devices

Ensure the container uses host network mode and the host machine is on the same LAN as Sonos devices.

### Configuration not saved

Check if `/config` directory is correctly mounted with write permissions.

### HTTP API inaccessible

Verify the port is not occupied and firewall allows access.

## Related Links

- [soco-cli GitHub](https://github.com/avantrec/soco-cli)
- [soco-cli Documentation](https://github.com/avantrec/soco-cli#readme)

## License

This project is licensed under the [MIT License](LICENSE).