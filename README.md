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
- SPKR environment variable support (omit speaker name)
- Cached discovery support (USE_LOCAL_CACHE)
- Aliases and Macros for custom actions
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

Docker Compose starts HTTP API Server by default (port 8000):

```bash
# Set environment variables (optional)
export MUSIC_PATH=/path/to/your/music
export SPKR="Living Room"
export USE_LOCAL_CACHE=true  # Use cached discovery
export SUBNETS="192.168.1.0/24"  # Network subnet for discovery

# Start HTTP API server
docker-compose up -d

# Test API
curl http://localhost:8000/play

# Run CLI commands (using separate profile)
docker-compose run --rm soco-cli discover
docker-compose run --rm soco-cli "Living Room" play
```

## Usage Examples

This image includes three CLI tools:
- **sonos**: Control Sonos speakers (main command)
- **sonos-discover**: Discover and cache Sonos devices on network
- **sonos-http-api-server**: Run HTTP API server for remote control

### Device Discovery

```bash
# Discover Sonos devices on network
docker run --rm --network host skyjia/soco-cli:latest discover

# Use cached discovery (faster after initial scan)
docker run --rm --network host -e USE_LOCAL_CACHE=true skyjia/soco-cli:latest play
```

### Speaker Control (sonos CLI)

```bash
# Show sonos CLI help
docker run --rm --network host skyjia/soco-cli:latest -- --help

# Show available actions
docker run --rm --network host skyjia/soco-cli:latest -- --actions

# Get speaker info
docker run --rm --network host skyjia/soco-cli:latest "Living Room" info

# Play music
docker run --rm --network host skyjia/soco-cli:latest "Living Room" play

# Set volume
docker run --rm --network host skyjia/soco-cli:latest "Living Room" volume 50

# List favorites
docker run --rm --network host skyjia/soco-cli:latest "Living Room" list_favs

# Play favorite
docker run --rm --network host skyjia/soco-cli:latest "Living Room" play_favourite "My Playlist"

# Command chaining with ':'
docker run --rm --network host skyjia/soco-cli:latest "Living Room" volume 30 : play : wait_start
```

### Using SPKR Environment Variable

Set `SPKR` to omit speaker name in commands:

```bash
# Set default speaker via environment variable
docker run --rm --network host -e SPKR="Living Room" skyjia/soco-cli:latest play
docker run --rm --network host -e SPKR="Living Room" skyjia/soco-cli:latest volume 50
docker run --rm --network host -e SPKR="Living Room" skyjia/soco-cli:latest list_favs
```

### Using LOG_LEVEL for Debugging

```bash
# Enable debug logging
docker run --rm --network host -e LOG_LEVEL=DEBUG skyjia/soco-cli:latest "Living Room" play
```

### Interactive Mode

```bash
docker run -it --rm --network host skyjia/soco-cli:latest -i
```

Interactive mode features:
- Command history
- Auto-completion (Linux/macOS)
- Shell aliases (custom shortcuts)
- Single keystroke mode (`sk` command)
- Push/pop speaker context

### HTTP API Server

```bash
# Start HTTP API server (port 8000)
docker run -d --network host skyjia/soco-cli:latest http-api-server -p 8000

# Start with specific subnet
docker run -d --network host -e SUBNETS="192.168.1.0/24" skyjia/soco-cli:latest http-api-server -p 8000

# Test API (with SPKR set, omit speaker name)
curl http://localhost:8000/play
curl http://localhost:8000/volume/50

# Test API (specify speaker name)
curl http://localhost:8000/Living%20Room/play
curl http://localhost:8000/Living%20Room/volume/50
curl http://localhost:8000/Living%20Room/info

# Custom macros
curl http://localhost:8000/Living%20Room/morning
curl http://localhost:8000/Living%20Room/set_vol/30
```

### Local File Playback

Mount your music library to `/music` for local file playback:

```bash
# Mount music library
docker run --rm --network host -v /path/to/music:/music:ro skyjia/soco-cli:latest "Living Room" play_file "/music/song.mp3"

# Play M3U playlist
docker run --rm --network host -v /path/to/music:/music:ro skyjia/soco-cli:latest "Living Room" play_m3u "/music/playlist.m3u"

# Play all files in directory
docker run --rm --network host -v /path/to/music:/music:ro skyjia/soco-cli:latest "Living Room" play_directory "/music/album"

# Options: p (print), s (shuffle), r (random), i (interactive)
docker run --rm --network host -v /path/to/music:/music:ro skyjia/soco-cli:latest "Living Room" play_directory "/music/album" s
```

Supported formats: MP3, M4A, MP4, FLAC, OGG, WMA, WAV, AIFF

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_LEVEL` | Log level (NONE, CRITICAL, ERROR, WARN, INFO, DEBUG) | INFO |
| `SPKR` | Default speaker name (allows omitting speaker in commands) | (empty) |
| `USE_LOCAL_CACHE` | Set to `true` to use cached speaker list (faster discovery) | (empty) |
| `SUBNETS` | Network subnets for HTTP API server discovery (e.g., `192.168.1.0/24`) | (empty) |

## Mount Points

| Path | Description |
|------|-------------|
| `/config` | Config directory, stores soco-cli settings, aliases, and speaker cache |
| `/music` | Local music library path (read-only access) |
| `/macros` | Macros file for HTTP API server custom actions |

## Configuration Files

### Aliases (`~/.soco-cli/aliases.json`)

Define custom shortcuts for commands:

```json
{
  "aliases": {
    "p": "play",
    "v": "volume %1",
    "fav": "play_favourite %1"
  },
  "sequences": {
    "start": "play : volume 30",
    "morning": "volume 25 : play_favourite \"Morning Jazz\""
  }
}
```

See `config/.soco-cli/aliases.json` and `aliases.example.md` for details.

### Macros (`~/macros.txt`)

Define custom HTTP API server actions:

```bash
# Basic macro
morning = volume 25 : play_favourite "Morning Playlist"

# Parameterized macro
set_vol = volume %1 : info

# Usage: curl http://localhost:8000/Living%20Room/set_vol/30
```

See `macros.txt` for detailed examples.

## Network Configuration

Uses `network_mode: host` for discovering Sonos devices in the local network.

### Firewall Ports

| Port | Protocol | Description |
|------|----------|-------------|
| UDP 1900 | SSDP multicast | Device discovery (239.255.255.250) |
| TCP 1400-1499 | Sonos events | Event notifications |
| TCP 54000-54099 | HTTP server | Built-in HTTP server |
| TCP 8000 | HTTP API | API server (configurable) |
| UDP 32768-60999 | Ephemeral | SSDP response ports (Linux) |

```bash
# Example: Open ports on Linux (ufw)
sudo ufw allow 32768:60999/udp
sudo ufw allow 1400:1499/tcp
sudo ufw allow 8000/tcp
```

### SSDP Discovery Mechanism

soco-cli uses SSDP multicast for device discovery. If the firewall blocks incoming UDP traffic on the ephemeral port range, discovery falls back to slower network scan. Use `USE_LOCAL_CACHE=true` after initial discovery for faster operations.

## FAQ

### Cannot discover Sonos devices

1. Ensure the container uses `--network host` mode
2. Verify the host machine is on the same LAN as Sonos devices
3. Check firewall settings (see Firewall Ports above)
4. Use cached discovery: `-e USE_LOCAL_CACHE=true`

### Configuration not saved

Check if `/config` directory is correctly mounted with write permissions.

### HTTP API inaccessible

Verify the port is not occupied and firewall allows access (TCP 8000).

### Local files not playing

Ensure music library is mounted to `/music` with correct path.

## Related Links

- [soco-cli GitHub](https://github.com/avantrec/soco-cli)
- [soco-cli Documentation](https://github.com/avantrec/soco-cli#readme)
- [Sonos Official Documentation](https://docs.sonos.com/)

## License

This project is licensed under the [MIT License](LICENSE).