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
- 缓存发现支持（USE_LOCAL_CACHE）
- Aliases 和 Macros 自定义动作
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
export USE_LOCAL_CACHE=true  # 使用缓存发现
export SUBNETS="192.168.1.0/24"  # 网络子网发现

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

# 使用缓存发现（首次扫描后更快）
docker run --rm --network host -e USE_LOCAL_CACHE=true skyjia/soco-cli:latest play
```

### 扬声器控制 (sonos CLI)

```bash
# 显示 sonos CLI 帮助
docker run --rm --network host skyjia/soco-cli:latest -- --help

# 显示可用动作
docker run --rm --network host skyjia/soco-cli:latest -- --actions

# 获取扬声器信息
docker run --rm --network host skyjia/soco-cli:latest "Living Room" info

# 播放音乐
docker run --rm --network host skyjia/soco-cli:latest "Living Room" play

# 设置音量
docker run --rm --network host skyjia/soco-cli:latest "Living Room" volume 50

# 列出收藏
docker run --rm --network host skyjia/soco-cli:latest "Living Room" list_favs

# 播放收藏
docker run --rm --network host skyjia/soco-cli:latest "Living Room" play_favourite "My Playlist"

# 使用 ':' 链接多个命令
docker run --rm --network host skyjia/soco-cli:latest "Living Room" volume 30 : play : wait_start
```

### 使用 SPKR 环境变量

设置 `SPKR` 可省略命令中的扬声器名称：

```bash
# 通过环境变量设置默认扬声器
docker run --rm --network host -e SPKR="Living Room" skyjia/soco-cli:latest play
docker run --rm --network host -e SPKR="Living Room" skyjia/soco-cli:latest volume 50
docker run --rm --network host -e SPKR="Living Room" skyjia/soco-cli:latest list_favs
```

### 使用 LOG_LEVEL 调试

```bash
# 启用调试日志
docker run --rm --network host -e LOG_LEVEL=DEBUG skyjia/soco-cli:latest "Living Room" play
```

### 交互模式

```bash
docker run -it --rm --network host skyjia/soco-cli:latest -i
```

交互模式功能：
- 命令历史
- 自动补全（Linux/macOS）
- Shell aliases（自定义快捷方式）
- 单键模式（`sk` 命令）
- Push/pop 扬声器上下文

### HTTP API 服务器

```bash
# 启动 HTTP API 服务器（端口 8000）
docker run -d --network host skyjia/soco-cli:latest http-api-server -p 8000

# 使用指定子网启动
docker run -d --network host -e SUBNETS="192.168.1.0/24" skyjia/soco-cli:latest http-api-server -p 8000

# 测试 API（设置 SPKR 后，省略扬声器名称）
curl http://localhost:8000/play
curl http://localhost:8000/volume/50

# 测试 API（指定扬声器名称）
curl http://localhost:8000/Living%20Room/play
curl http://localhost:8000/Living%20Room/volume/50
curl http://localhost:8000/Living%20Room/info

# 自定义 macros
curl http://localhost:8000/Living%20Room/morning
curl http://localhost:8000/Living%20Room/set_vol/30
```

### 本地文件播放

将音乐库挂载到 `/music` 以播放本地文件：

```bash
# 挂载音乐库
docker run --rm --network host -v /path/to/music:/music:ro skyjia/soco-cli:latest "Living Room" play_file "/music/song.mp3"

# 播放 M3U 播放列表
docker run --rm --network host -v /path/to/music:/music:ro skyjia/soco-cli:latest "Living Room" play_m3u "/music/playlist.m3u"

# 播放目录中所有文件
docker run --rm --network host -v /path/to/music:/music:ro skyjia/soco-cli:latest "Living Room" play_directory "/music/album"

# 选项：p（打印）、s（随机）、r（随机曲目）、i（交互）
docker run --rm --network host -v /path/to/music:/music:ro skyjia/soco-cli:latest "Living Room" play_directory "/music/album" s
```

支持格式：MP3, M4A, MP4, FLAC, OGG, WMA, WAV, AIFF

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `LOG_LEVEL` | 日志级别 (NONE, CRITICAL, ERROR, WARN, INFO, DEBUG) | INFO |
| `SPKR` | 默认扬声器名称（允许省略命令中的扬声器） | (空) |
| `USE_LOCAL_CACHE` | 设为 `true` 使用缓存扬声器列表（更快发现） | (空) |
| `SUBNETS` | HTTP API 服务器的网络子网（如 `192.168.1.0/24`） | (空) |

## 挂载点

| 路径 | 说明 |
|------|------|
| `/config` | 配置目录，存储 soco-cli 设置、别名和扬声器缓存 |
| `/music` | 本地音乐库路径（只读访问） |
| `/macros` | HTTP API 服务器的自定义 macros 文件 |

## 配置文件

### Aliases (`~/.soco-cli/aliases.json`)

定义命令自定义快捷方式：

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

详见 `config/.soco-cli/aliases.json` 和 `aliases.example.md`。

### Macros (`~/macros.txt`)

定义 HTTP API 服务器自定义动作：

```bash
# 基本 macro
morning = volume 25 : play_favourite "Morning Playlist"

# 参数化 macro
set_vol = volume %1 : info

# 用法：curl http://localhost:8000/Living%20Room/set_vol/30
```

详见 `macros.txt`。

## 网络配置

使用 `network_mode: host` 以便发现局域网内的 Sonos 设备。

### 防火墙端口

| 端口 | 协议 | 说明 |
|------|------|------|
| UDP 1900 | SSDP multicast | 设备发现（239.255.255.250） |
| TCP 1400-1499 | Sonos events | 事件通知 |
| TCP 54000-54099 | HTTP server | 内置 HTTP 服务器 |
| TCP 8000 | HTTP API | API 服务器（可配置） |
| UDP 32768-60999 | Ephemeral | SSDP 响应端口（Linux） |

```bash
# 示例：在 Linux 上开放端口（ufw）
sudo ufw allow 32768:60999/udp
sudo ufw allow 1400:1499/tcp
sudo ufw allow 8000/tcp
```

### SSDP 发现机制

soco-cli 使用 SSDP multicast 进行设备发现。如果防火墙阻止 ephemeral 端口范围的传入 UDP 流量，发现将回退到较慢的网络扫描。首次发现后使用 `USE_LOCAL_CACHE=true` 可加速操作。

## 常见问题

### 无法发现 Sonos 设备

1. 确保容器使用 `--network host` 模式
2. 验证宿主机与 Sonos 设备在同一局域网
3. 检查防火墙设置（见上方防火墙端口）
4. 使用缓存发现：`-e USE_LOCAL_CACHE=true`

### 配置不保存

检查 `/config` 目录是否正确挂载并具有写入权限。

### HTTP API 无法访问

确认端口未被占用，防火墙允许访问（TCP 8000）。

### 本地文件无法播放

确保音乐库正确挂载到 `/music` 并路径正确。

## 相关链接

- [soco-cli GitHub](https://github.com/avantrec/soco-cli)
- [soco-cli 文档](https://github.com/avantrec/soco-cli#readme)
- [Sonos 官方文档](https://docs.sonos.com/)

## 许可协议

本项目采用 [MIT 许可协议](LICENSE)。