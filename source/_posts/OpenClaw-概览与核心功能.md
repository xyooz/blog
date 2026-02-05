---
title: OpenClaw 概览与核心功能 - 你的 AI 助手网关
date: 2026-02-06 01:20:00
tags:
  - OpenClaw
  - AI
  - Telegram
  - Agent
  - Gateway
categories:
  - 技术
---

# OpenClaw 概览与核心功能 - 你的 AI 助手网关

## 什么是 OpenClaw？

OpenClaw 是一个**开源的 AI 助手网关**，连接聊天平台与 AI Agent。

### 核心理念

- 🤖 **多平台支持**：Telegram、WhatsApp、Discord、iMessage 等
- 🧠 **Agent 能力**：集成 Claude Code、Pi 等编程 Agent
- 🔌 **Skills 扩展**：通过 Skills 扩展功能
- 🔒 **本地部署**：数据完全掌握在自己手中

### 解决的问题

| 问题 | OpenClaw 方案 |
|------|---------------|
| 不方便对话 | Telegram 随时随地聊天 |
| 记忆丢失 | QMD 向量记忆系统 |
| 工具单一 | Skills 扩展生态 |
| 隐私泄露 | 完全本地部署 |

## 架构设计

### 核心组件

```
┌─────────────┐
│  Telegram   │
│  WhatsApp  │  ← 聊天平台
│  Discord   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Gateway    │  ← 统一网关
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Agent     │  ← AI 能力
│  Skills     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Memory     │  ← 记忆系统 (QMD)
└─────────────┘
```

### 关键概念

#### Gateway

网关是 OpenClaw 的核心，负责：

- **会话管理**：多用户、多会话
- **路由分发**：消息路由到对应 Agent
- **通道连接**：连接各种聊天平台
- **认证授权**：Token、密码验证

#### Agent

Agent 提供 AI 能力：

| Agent | 特点 |
|-------|------|
| **Pi** | 友好对话，适合日常使用 |
| **Claude Code** | 编程能力强，适合开发者 |
| **自定义** | 可集成其他 LLM |

#### Skills

Skills 是功能扩展：

| 分类 | Skills |
|------|--------|
| 💬 通讯 | discord, slack, imsg, bird |
| 🍎 Apple | apple-notes, things-mac |
| 🎵 音乐 | spotify-player |
| 🔧 开发 | github, coding-agent |
| 🛠️ 工具 | weather, healthcheck |

## 核心功能

### 1. 多平台集成

#### Telegram 配置

```json
{
  "channels": {
    "telegram": {
      "token": "your-bot-token",
      "allowFrom": ["user-id-1", "user-id-2"],
      "groups": {
        "*": {
          "requireMention": true
        }
      }
    }
  }
}
```

#### 多账号支持

```json
{
  "agents": {
    "list": [
      {
        "id": "assistant",
        "name": "AI 助手",
        "channels": ["telegram"]
      },
      {
        "id": "coder",
        "name": "编程助手",
        "channels": ["discord"]
      }
    ]
  }
}
```

### 2. Agent 系统

#### Agent 配置

```json
{
  "agents": {
    "default": "pi",
    "list": [
      {
        "id": "pi",
        "provider": "pi",
        "model": "sonnet-4-2-2025-01-21"
      },
      {
        "id": "coder",
        "provider": "anthropic",
        "model": "claude-code"
      }
    ]
  }
}
```

#### MCP 集成

OpenClaw 支持 MCP (Model Context Protocol)：

```json
{
  "mcp": {
    "servers": {
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"]
      }
    }
  }
}
```

### 3. QMD 向量记忆

QMD 是 OpenClaw 的记忆系统：

#### 配置

```json
{
  "memory": {
    "backend": "qmd",
    "qmd": {
      "includeDefaultMemory": true,
      "update": {
        "interval": "5m"
      },
      "limits": {
        "maxResults": 6,
        "timeoutMs": 4000
      }
    }
  }
}
```

#### 功能

| 功能 | 命令 |
|------|------|
| 全文搜索 | `qmd search` |
| 向量搜索 | `qmd vsearch` |
| 混合搜索 | `qmd query` |

### 4. Tools 工具集

OpenClaw 内置丰富的 Tools：

| 分类 | 工具 | 功能 |
|------|------|------|
| 🖥️ | browser | 浏览器控制 |
| 📝 | read/write/edit | 文件操作 |
| 🔧 | exec | 命令执行 |
| 🔍 | web_search | 网络搜索 |
| 📊 | cron | 定时任务 |
| 🌐 | nodes | 节点管理 |

### 5. 安全性

#### 认证配置

```json
{
  "gateway": {
    "auth": {
      "mode": "token",
      "token": "your-secret-token"
    }
  }
}
```

#### 工具权限

```json
{
  "tools": {
    "allow": ["read", "write", "browser"],
    "deny": ["exec"]
  }
}
```

## 部署方式

### 方式 1：VPS 部署（推荐）

```bash
# 安装
npm install -g openclaw

# 启动
openclaw gateway

# 后台运行
nohup openclaw gateway > /var/log/openclaw.log 2>&1 &
```

### 方式 2：Docker 部署

```yaml
# docker-compose.yml
version: '3.8'
services:
  openclaw:
    image: openclaw/openclaw
    volumes:
      - ~/.openclaw:/root/.openclaw
    ports:
      - "18789:18789"
    restart: always
```

### 方式 3：源码部署

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
npm install
npm run build
node dist/entry.js gateway
```

## Skills 生态

### 官方 Skills

| 分类 | Skills |
|------|--------|
| 💬 通讯 | discord, slack, imsg, bird |
| 🔧 开发 | github, coding-agent, mcporter |
| 🍎 Apple | apple-notes, things-mac, bear-notes |
| 🎵 媒体 | spotify-player, songsee |
| 🛠️ 工具 | weather, healthcheck, qmd |

### 安装 Skills

```bash
# 通过 OpenClaw CLI
openclaw skills install github

# 或手动安装
cd /path/to/openclaw/skills
git clone https://github.com/tobi/qmd.git
```

## 使用场景

### 场景 1：个人 AI 助手

- Telegram 随时对话
- 记住你的偏好和习惯
- 帮你管理日程

### 场景 2：编程助手

- Claude Code 集成
- GitHub PR Review
- 代码审查和优化

### 场景 3：运维工具箱

- VPS 健康检查
- 自动备份
- 定时任务

## 性能与优化

### 系统要求

| 配置 | 最低 | 推荐 |
|------|------|------|
| 内存 | 1GB | 2GB+ |
| CPU | 1 核 | 2 核 |
| 存储 | 10GB | 20GB+ |

### 性能优化

#### 1. Swap 配置

```bash
# 创建 4GB Swap
dd if=/dev/zero of=/swapfile bs=1M count=4096
mkswap /swapfile
swapon /swapfile
```

#### 2. 内存限制

```json
{
  "agents": {
    "defaults": {
      "maxMemory": "2g"
    }
  }
}
```

## 常见问题

### Q: 如何备份？

```bash
# 备份配置
cp -r ~/.openclaw ~/backup-openclaw-$(date +%Y%m%d)

# 备份数据
cp -r ~/.cache/qmd ~/backup-qmd-$(date +%Y%m%d)
```

### Q: Agent 没响应？

1. 检查 API Key 配置
2. 查看日志 `openclaw logs`
3. 重启 Gateway `openclaw gateway restart`

### Q: 内存不足？

1. 添加 Swap
2. 降低并发数
3. 关闭不需要的 Skills

## 总结

OpenClaw 是一个强大的 AI 助手网关：

- ✅ **多平台**：Telegram、Discord 等
- ✅ **强 Agent**：Pi、Claude Code
- ✅ **好记忆**：QMD 向量检索
- ✅ **易扩展**：Skills 生态
- ✅ **够安全**：本地部署

**让 AI 助手随时随地为你服务！**

---

**Tags**: OpenClaw, AI, Telegram, Agent, Gateway, Skills, QMD

**系列文章**：

- [OpenClaw 折腾记](./OpenClaw-折腾记)
- [QMD 向量记忆高级用法](./QMD-向量记忆高级用法)
- OpenClaw 概览与核心功能 ✅
