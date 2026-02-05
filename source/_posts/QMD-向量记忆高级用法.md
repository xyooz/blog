---
title: QMD 向量记忆高级用法 - 打造你的第二大脑
date: 2026-02-06 01:15:00
tags:
  - QMD
  - 向量检索
  - 语义搜索
  - OpenClaw
  - AI
categories:
  - 技术
---

# QMD 向量记忆高级用法 - 打造你的第二大脑

## 前言

在信息爆炸的时代，如何高效检索信息成为关键。QMD (Quick Markdown) 不仅仅是一个搜索工具，它是你的**第二大脑**。

## 什么是向量检索？

### 传统搜索 vs 向量搜索

| 对比项 | 传统搜索 (BM25) | 向量搜索 |
|--------|----------------|----------|
| 原理 | 关键词匹配 | 语义理解 |
| 能力 | 精确匹配 | 模糊理解 |
| 速度 | 快 | 稍慢 |
| 场景 | 专业术语 | 日常表达 |

### 示例

```
搜索: "我的投资基金表现如何"

BM25 结果: 匹配 "基金" 关键词的文章
向量搜索: 理解语义，找到所有关于投资、收益、持仓的文章
```

## OpenClaw QMD 配置

### 基础配置

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

### 命令行用法

```bash
# 全文搜索 (BM25)
qmd search "基金 持仓"

# 向量相似度搜索
qmd vsearch "我的投资偏好"

# 混合搜索 (推荐)
qmd query "最近买了什么股票"

# 指定集合搜索
qmd query "工作安排" -c memory

# JSON 格式输出
qmd query "项目进度" --json
```

## 实战场景

### 场景 1：快速回顾对话

```
$ qmd query "昨天讨论的 AI 项目"

结果:
- 匹配度 85%: 2026-02-04.md - AI Agent 测试记录
- 匹配度 72%: 项目计划.md - Agent 集成方案
```

### 场景 2：跨时间检索

```bash
# 搜索所有关于 "投资" 的记录
qmd search "投资" --all

# 搜索最近一个月的记录
qmd query "基金走势" --min-score 0.5
```

### 场景 3：精准定位

```bash
# 获取完整文档
qmd get qmd://memory/2026-02-05.md

# 多文档获取
qmd multi-get "qmd://memory/*.md" --json
```

## 高级技巧

### 1. 优化检索质量

```bash
# 提高相似度阈值，过滤低质量结果
qmd query "关键词" --min-score 0.7

# 扩大搜索范围
qmd query "内容" -n 10
```

### 2. 集合管理

```bash
# 查看所有集合
qmd collection list

# 创建新集合
qmd collection add /path/to/notes --name my-notes

# 删除集合
qmd collection remove old-notes
```

### 3. 索引维护

```bash
# 强制重新索引
qmd update --pull

# 清理无用数据
qmd cleanup

# 查看索引状态
qmd status
```

## QMD 工作原理

### 向量嵌入模型

```
Embedding 模型: embeddinggemma-300M-Q8_0
- 轻量级模型，适合 VPS
- 300M 参数
- 本地运行，不依赖外部 API
```

### 数据存储

```
~/.cache/qmd/index.sqlite
- 向量索引
- BM25 索引
- 元数据
```

## 与 OpenClaw 集成

### 配置 memory-core

```json
{
  "memory": {
    "backend": "qmd",
    "memory-core": {
      "enabled": true
    }
  }
}
```

### 可用工具

| 工具 | 功能 |
|------|------|
| `memory_search` | QMD 搜索 |
| `memory_get` | 获取记忆内容 |
| `memory_list` | 列出所有记忆 |

## 常见问题

### Q: 向量搜索崩溃

**问题**: Bun 1.3.8 + node-llama-cpp 兼容问题

**解决**:
```bash
# 方案1: 使用 BM25
qmd search "关键词"

# 方案2: 重装 QMD
git clone https://github.com/tobi/qmd.git
cd qmd && bun install
```

### Q: 搜索结果不准确

**解决**:
1. 增加文档数量
2. 提高检索阈值
3. 使用混合搜索 `query` 而非单一 `search`

### Q: 索引过大

**解决**:
```bash
# 清理无用数据
qmd cleanup

# 移除不需要的集合
qmd collection remove unused-collection
```

## 最佳实践

### 1. 命名规范

```
# 推荐命名
2026-02-06-项目计划.md
2026-02-05-投资笔记.md
对话-2026-02-04-AI讨论.md
```

### 2. 内容结构

```markdown
# 标题

## 关键信息
- 时间
- 人物
- 地点

## 详细内容

## 结论/行动项
```

### 3. 定期维护

```bash
# 每周执行
qmd update  # 更新索引
qmd cleanup  # 清理垃圾
qmd status  # 检查状态
```

## 总结

QMD + OpenClaw 让我实现了：

- ✅ **精准检索**：不用记住文件名，记住关键词就行
- ✅ **语义理解**：用自然语言搜索
- ✅ **完全本地**：数据在自己手里
- ✅ **零成本**：不需要外部 API

**你的第二大脑，从 QMD 开始！**

---

**Tags**: QMD, 向量检索, 语义搜索, OpenClaw, AI, 知识管理
