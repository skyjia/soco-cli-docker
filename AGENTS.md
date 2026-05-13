# AGENTS.md

This file provides guidance to AI coding assistants (Claude Code, Cursor, GitHub Copilot, etc.) when working with code in this repository.

## Project Overview

Docker image for [soco-cli](https://github.com/avantrec/soco-cli), a CLI tool for managing and controlling Sonos devices.

**Docker Hub**: [skyjia/soco-cli](https://hub.docker.com/r/skyjia/soco-cli)

Key features:
- Pre-installed soco-cli (latest version at build time)
- Interactive Shell Mode for device management
- HTTP API Server mode (default port 8000, configurable via CLI)
- Config directory and local music library volume mounts
- Sample config file initialization
- Non-root user execution

## Technical Specifications

| Item | Specification |
|------|---------------|
| Base image | Python >= 3.13 (slim) |
| Architecture | arm64 only |
| User | Non-root (`sonos`) |
| HTTP API port | 8000 (configurable via CLI) |
| Network mode | `host` (required for SSDP multicast) |
| SSDP multicast | 239.255.255.250:1900 (UDP) |
| Environment variables | `LOG_LEVEL` |
| Image tags | Semantic versioning (`latest`, `v1.0.0`, etc.) |
| Update policy | Regular updates for latest soco-cli and security patches |
| License | MIT |

## Project Structure

| File | Purpose |
|------|---------|
| `Dockerfile` | Multi-stage build definition |
| `entrypoint.sh` | Container entrypoint script |
| `docker-compose.yml` | Docker Compose example |
| `README.md` | English user documentation |
| `README-CN.md` | Chinese user documentation |
| `DESIGN.md` | Architecture and design details |
| `LICENSE` | MIT License |
| `config/.soco-cli/` | Sample configuration files |

## Build and Test Commands

```bash
# Pull from Docker Hub
docker pull skyjia/soco-cli:latest

# Build image locally
docker build -t skyjia/soco-cli:test .

# Verify non-root user
docker run --rm --entrypoint "" skyjia/soco-cli:test whoami

# Test CLI
docker run --rm --network host skyjia/soco-cli:test --help

# Test interactive mode
docker run -it --rm --network host skyjia/soco-cli:test -i

# Test HTTP API
docker run -d --network host skyjia/soco-cli:test http-api-server -p 8000
```

## Coding Guidelines

- All documentation should be in English, with Chinese translations in separate files (e.g., `README-CN.md`)
- Use multi-stage Docker builds for minimal image size
- Run containers as non-root user for security
- Use `network_mode: host` for Sonos device discovery
- Mount volumes for persistent configuration and music library access