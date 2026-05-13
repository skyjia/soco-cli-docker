# soco-cli Docker 镜像

[English Documentation](README.md)

用于 [soco-cli](https://github.com/avantrec/soco-cli) 的 Docker 镜像，提供便捷的 Sonos 设备管理环境。

**Docker Hub**: [skyjia/soco-cli](https://hub.docker.com/r/skyjia/soco-cli)

## 功能特性

- 预装最新版 soco-cli
- CLI 模式：直接执行 Sonos 控制命令
- 交互模式：进入交互式命令行界面
- HTTP API 模式：启动 HTTP API 服务器（默认端口 8000）
- 非 root 用户运行，确保安全
- 配置目录和音乐库持久化

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

```bash
# 设置音乐库路径
export MUSIC_PATH=/path/to/your/music

# 启动容器
docker-compose up -d

# 执行命令
docker-compose exec soco-cli sonos --help
```

## 使用示例

### CLI 模式

```bash
# 显示帮助
docker run --rm --network host skyjia/soco-cli:latest --help

# 列出所有设备
docker run --rm --network host skyjia/soco-cli:latest list

# 播放音乐
docker run --rm --network host skyjia/soco-cli:latest "Living Room" play

# 设置音量
docker run --rm --network host skyjia/soco-cli:latest "Living Room" volume 50
```

### 交互模式

```bash
docker run -it --rm --network host skyjia/soco-cli:latest -i
```

### HTTP API 模式

```bash
# 启动 HTTP API 服务器（端口 8000）
docker run -d --network host skyjia/soco-cli:latest http-api-server -p 8000

# 测试 API
curl http://localhost:8000/Living%20Room/play
curl http://localhost:8000/Living%20Room/volume/50
```

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `LOG_LEVEL` | 日志级别 (NONE, CRITICAL, ERROR, WARN, INFO, DEBUG) | INFO |

## 挂载点

| 路径 | 说明 |
|------|------|
| `/config` | 配置目录，存储 soco-cli 设置和别名 |
| `/music` | 本地音乐库路径（只读访问） |

## 网络配置

使用 `network_mode: host` 以便发现局域网内的 Sonos 设备。这是最简单的配置方式，无需额外网络设置。

## 常见问题

### 无法发现 Sonos 设备

确保容器使用 host 网络模式，并且宿主机与 Sonos 设备在同一局域网。

### 配置不保存

检查 `/config` 目录是否正确挂载并具有写入权限。

### HTTP API 无法访问

确认端口未被占用，并且防火墙允许访问。

## 相关链接

- [soco-cli GitHub](https://github.com/avantrec/soco-cli)
- [soco-cli 文档](https://github.com/avantrec/soco-cli#readme)

## 许可协议

本项目采用 [MIT 许可协议](LICENSE)。