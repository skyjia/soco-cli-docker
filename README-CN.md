# soco-cli Docker 镜像

[English Documentation](README.md)

用于 [soco-cli](https://github.com/avantrec/soco-cli) 的 Docker 镜像，提供便捷的 Sonos 设备管理环境。

**GitHub**: [skyjia/soco-cli-docker](https://github.com/skyjia/soco-cli-docker)
**Docker Hub**: [skyjia/soco-cli](https://hub.docker.com/r/skyjia/soco-cli)

## 功能特性

- 预装最新版 soco-cli
- 轻量级多阶段构建
- 多平台支持：linux/amd64, linux/arm64
- CLI 模式：直接执行 Sonos 控制命令
- 交互模式：进入交互式命令行界面
- HTTP API 模式：启动 HTTP API 服务器（默认端口 8000）
- SPKR 环境变量支持（省略扬声器名称）
- 非 root 用户运行，确保安全
- 配置目录和音乐库持久化

## 支持平台

| 平台 | 架构 | 适用场景 |
|------|------|----------|
| `linux/amd64` | x86_64 | 标准服务器、桌面、云虚拟机 |
| `linux/arm64` | ARM 64位 | Apple Silicon Mac、Raspberry Pi 4、ARM 云实例 |

> **Windows 用户**：Windows 上的 Docker Desktop 通过 WSL2 运行 Linux 容器。本镜像可在 Windows 上通过 Docker Desktop 直接使用，无需额外配置。

## 镜像标签

| 标签 | 类型 | 说明 |
|------|------|------|
| `latest` | 跨架构 | 自动检测本机架构（推荐） |
| `vX.Y.Z` | 跨架构 | 指定版本，自动检测架构 |
| `amd64` | 单架构 | 仅 x86_64 架构 |
| `arm64` | 单架构 | 仅 ARM 64位架构 |

```bash
# 自动检测架构（推荐）
docker pull skyjia/soco-cli:latest

# 强制指定架构
docker pull skyjia/soco-cli:amd64
docker pull skyjia/soco-cli:arm64
```

## 系统要求

- 已安装 Docker
- Sonos 设备连接到同一局域网
- Windows 用户需启用 Docker Desktop 的 WSL2 功能

## 快速开始

### 从 Docker Hub 拉取

```bash
docker pull skyjia/soco-cli:latest
```

### 构建镜像（可选）

```bash
docker build -t skyjia/soco-cli:latest .
```

### 使用 Docker Compose

Docker Compose 默认启动 HTTP API Server（端口 8000）：

```bash
# 设置环境变量（可选）
export MUSIC_PATH=/path/to/your/music
export SPKR="Living Room"

# 启动 HTTP API 服务器
docker-compose up -d

# 测试 API
curl http://localhost:8000/play

# 运行 CLI 命令（使用单独 profile）
docker-compose run --rm soco-cli discover
docker-compose run --rm soco-cli "Living Room" play
```

## 使用示例

本镜像包含三个 CLI 工具：
- **sonos**: 控制 Sonos 扬声器（主命令）
- **sonos-discover**: 发现并缓存网络上的 Sonos 设备
- **sonos-http-api-server**: 运行 HTTP API 服务器用于远程控制

### 设备发现

```bash
# 发现网络上的 Sonos 设备
docker run --rm --network host skyjia/soco-cli:latest discover
```

### 扬声器控制 (sonos CLI)

```bash
# 显示 sonos CLI 帮助
docker run --rm --network host skyjia/soco-cli:latest -- --help

# 获取扬声器信息
docker run --rm --network host skyjia/soco-cli:latest "Living Room" info

# 播放音乐
docker run --rm --network host skyjia/soco-cli:latest "Living Room" play

# 设置音量
docker run --rm --network host skyjia/soco-cli:latest "Living Room" volume 50

# 列出收藏
docker run --rm --network host skyjia/soco-cli:latest "Living Room" list_favs

# 列出所有区域（需要扬声器名称）
docker run --rm --network host skyjia/soco-cli:latest "Living Room" zones
```

### 使用 SPKR 环境变量

设置 `SPKR` 可省略命令中的扬声器名称：

```bash
# 通过环境变量设置默认扬声器
docker run --rm --network host -e SPKR="Living Room" skyjia/soco-cli:latest play
docker run --rm --network host -e SPKR="Living Room" skyjia/soco-cli:latest volume 50
```

### 交互模式

```bash
docker run -it --rm --network host skyjia/soco-cli:latest -i
```

### HTTP API 服务器

```bash
# 启动 HTTP API 服务器（端口 8000）
docker run -d --network host skyjia/soco-cli:latest http-api-server -p 8000

# 测试 API（设置 SPKR 后，省略扬声器名称）
curl http://localhost:8000/play
curl http://localhost:8000/volume/50

# 测试 API（指定扬声器名称）
curl http://localhost:8000/Living%20Room/play
curl http://localhost:8000/Living%20Room/volume/50
```

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `LOG_LEVEL` | 日志级别 (NONE, CRITICAL, ERROR, WARN, INFO, DEBUG) | INFO |
| `SPKR` | 默认扬声器名称（允许省略命令中的扬声器） | (空) |

## 挂载点

| 路径 | 说明 |
|------|------|
| `/config` | 配置目录，存储 soco-cli 设置和别名 |
| `/music` | 本地音乐库路径（只读访问） |
| `/macros` | HTTP API 服务器的自定义 macros 文件 |

## 网络配置

使用 `network_mode: host` 以便发现局域网内的 Sonos 设备。这是最简单的配置方式，无需额外网络设置。

### SSDP 发现机制

soco-cli 使用 SSDP multicast 进行设备发现：
- **Multicast 地址**: 239.255.255.250
- **UDP 端口**: 1900
- **传出端口**: 可变（ephemeral 端口范围，Linux 上为 32768–60999）

如果防火墙阻止 ephemeral 端口范围的传入 UDP 流量，标准发现将失败并回退到较慢的网络扫描发现。为确保快速发现：

```bash
# 示例：在 Linux 上开放 ephemeral UDP 端口（ufw）
sudo ufw allow 32768:60999/udp
```

## 常见问题

### 无法发现 Sonos 设备

1. 确保容器使用 `--network host` 模式
2. 验证宿主机与 Sonos 设备在同一局域网
3. 检查防火墙设置 - 允许 ephemeral 端口范围的传入 UDP 流量（如 32768–60999）
4. 如果发现速度慢，可使用 `-l` 参数启用缓存发现

### 配置不保存

检查 `/config` 目录是否正确挂载并具有写入权限。

### HTTP API 无法访问

确认端口未被占用，并且防火墙允许访问。

## 相关链接

- [soco-cli GitHub](https://github.com/avantrec/soco-cli)
- [soco-cli 文档](https://github.com/avantrec/soco-cli#readme)
- [Sonos 官方文档](https://docs.sonos.com/)

## 许可协议

本项目采用 [MIT 许可协议](LICENSE)。