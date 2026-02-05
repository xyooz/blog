---
title: OpenClaw 折腾记 - 从 Telegram AI 助手到向量记忆系统
date: 2026-02-06 00:57:00
tags:
  - OpenClaw
  - AI
  - Telegram
  - QMD
  - Hexo
categories:
  - 技术
---

# OpenClaw 折腾记 - 从 Telegram AI 助手到向量记忆系统

## 前言

作为一个热爱折腾的普通人，我一直在寻找一个能够随时随地与 AI 对话解决方案。直到发现了 OpenClaw —— 一个开源的 AI 助手框架。

## 什么是 OpenClaw？

OpenClaw 是一个开源的 AI 助手网关，具有以下特点：

- **多平台支持**：Telegram、WhatsApp、Discord、iMessage 等
- **Agent 能力**：集成 Claude Code、Pi 等编程 Agent
- **本地化部署**：数据完全掌握在自己手中
- **可扩展性**：通过 Skills 扩展功能

我的使用场景：

1. 📱 在手机上通过 Telegram 与 AI 对话
2. 🧠 QMD 向量记忆系统，精准检索
3. 📊 基金数据自动追踪
4. 🛠️ VPS 运维工具箱

---

## 第一章：QMD 向量记忆系统配置

OpenClaw 最新版内置了 QMD 支持，这是一个强大的语义搜索工具。

### 配置步骤

1. 修改 `~/.openclaw/openclaw.json`：

```json
{
  "memory": {
    "backend": "qmd",
    "qmd": {
      "includeDefaultMemory": true,
      "update": {
        "interval": "5m",
        "debounceMs": 15000
      },
      "limits": {
        "maxResults": 6,
        "timeoutMs": 4000
      }
    }
  }
}
```

2. 使用命令：

```bash
# 全文搜索 (BM25)
qmd search "基金"

# 向量搜索
qmd vsearch "我的投资偏好"

# 混合搜索
qmd query "持仓基金走势"
```

### 🐛 遇到的问题：Bun 兼容问题

> **问题现象**：
> ```
> panic: Segmentation fault at address 0x7FCF86E3E840
> Peak: 6.58GB | Machine: 10.42GB
> ```

**解决方案**：

最终解决方案：**手动从源码安装 QMD**，并保持 Bun 1.3.8。

---

## 第二章：基金数据自动追踪

### 部署方案

1. 创建数据获取脚本

2. 配置定时任务：

```bash
# crontab -e
0 15 * * * cd /root/.openclaw && python3 scripts/fetch_fund_nav.py
```

### 数据展示

通过 OpenClaw 的 QMD 搜索，可以快速检索历史数据。

---

## 第三章：VPS 优化

### 添加 Swap 空间

```bash
# 创建 4GB Swap 文件
dd if=/dev/zero of=/swapfile bs=1M count=4096
mkswap /swapfile
swapon /swapfile

# 永久生效
echo "/swapfile none swap sw 0 0" >> /etc/fstab
```

效果：
```
Mem:           9.7Gi       692Mi       5.3Gi
Swap:          4.0Gi          0B       4.0Gi
```

---

## 第四章：Hexo 博客部署

### 部署步骤

1. 安装 Node.js 和 Hexo：

```bash
# 使用 nvm 安装
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
npm install -g hexo-cli
```

2. 初始化博客：

```bash
hexo init /var/www/blog
cd /var/www/blog
hexo theme next
```

3. 配置 Caddy 自动 HTTPS：

```caddyfile
blog.2001.life {
    root * /var/www/blog/public
    file_server
    encode gzip
}
```

---

## 总结

通过这段时间的折腾，我获得了：

1. ✅ **随时可用的 AI 助手** - Telegram 随时对话
2. ✅ **精准的记忆系统** - QMD 向量检索
3. ✅ **自动化的基金追踪** - 每日净值数据
4. ✅ **安全的 VPS 配置** - Swap + SSH 加固
5. ✅ **独立的博客系统** - Hexo + Caddy 自动 HTTPS

**心得**：

- 遇到问题不要慌，善用搜索和社区资源
- 保留原始配置，备份是关键
- 记录过程，既是总结也是分享

---

**Tags**: OpenClaw, AI, Telegram, QMD, Hexo, VPS
