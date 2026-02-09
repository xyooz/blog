---
title: OpenClaw Memory Search 配置优化 - 本地 Embedding 方案
date: 2026-02-10 01:44:00
tags:
  - OpenClaw
  - Memory Search
  - Local Embedding
  - QMD
categories: 技术笔记
---

## 背景

在使用 OpenClaw 作为日常助手时，Memory Search（记忆检索）是一个核心功能。近期在配置过程中遇到了一些问题，记录一下解决方案。

## 遇到的问题

### 1. QMD Backend 超时

OpenClaw 支持使用 [QMD](https://github.com/tobi/qmd) 作为记忆后端，但在 VPS 环境中遇到性能问题：

```
qmd query ... timed out after 4000ms
```

**原因分析**：
- QMD 每次执行都重新加载模型（冷启动）
- 模型文件总计 2.1GB：
  - embeddinggemma-300M: 314MB
  - qwen3-reranker-0.6b: 610MB
  - qmd-query-expansion-1.7B: 1.2GB

### 2. memory_search 工具报错

```
No API key found for provider "openai"
memory_search tool disabled
```

尝试使用 memory_search 工具时，系统要求配置 OpenAI API Key，但实际上我希望能用本地方案。

## 解决方案：本地 Embedding

查阅 [OpenClaw 官方文档](https://docs.openclaw.ai/concepts/memory) 后，发现可以配置 `memorySearch.provider = "local"` 使用本地 embedding 模型。

### 最终配置

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "provider": "local",
        "local": {
          "modelPath": "hf:ggml-org/embeddinggemma-300M-GGUF/embeddinggemma-300M-Q8_0.gguf"
        },
        "fallback": "none",
        "query": {
          "hybrid": {
            "enabled": true,
            "vectorWeight": 0.7,
            "textWeight": 0.3,
            "candidateMultiplier": 4
          }
        },
        "cache": {
          "enabled": true,
          "maxEntries": 50000
        }
      }
    }
  }
}
```

### 配置说明

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `provider` | `local` | 使用本地 embedding |
| `modelPath` | embeddinggemma-300M | 本地 GGUF 模型 |
| `hybrid.enabled` | `true` | 启用混合检索 |
| `vectorWeight` | `0.7` | 向量检索权重 70% |
| `textWeight` | `0.3` | 文本检索权重 30% |
| `cache.enabled` | `true` | 启用缓存 |
| `maxEntries` | `50000` | 最大缓存条目 |

## 混合检索原理

### 向量检索（Vector Search）
- 使用语义相似度匹配
- 找到意思相近但用词不同的内容
- 例如：搜索"基金"能找到"持仓"

### 文本检索（BM25）
- 关键词精确匹配
- 适合匹配代码、ID 等
- 例如：搜索"012895"能找到基金代码

### 融合策略
```
最终分数 = 0.7 × 向量分数 + 0.3 × 文本分数
```

## 测试结果

```bash
# 搜索"基金 持仓"
$ memory_search("基金 持仓")

结果：
1. memory/2026-02-05.md (39%) - 基金组合状态表
2. MEMORY.md (38%) - 长期记忆-持仓基金
```

## 优势

1. **完全免费** - 不需要 OpenAI/Voyage/Gemini API Key
2. **隐私安全** - 所有数据本地处理
3. **响应快速** - 首次加载后有缓存
4. **混合检索** - 结合语义和关键词匹配

## 注意事项

- 模型文件已缓存：`~/.node-llama-cpp/models/hf_ggml-org_embeddinggemma-300M-Q8_0.gguf`
- QMD Backend 暂时保留配置（等待官方修复冷启动问题）
- memory_search 会自动回退到本地 embedding

## 相关 Issue

- [QMD query command is slow due to model cold start](https://github.com/openclaw/openclaw/issues/12752)
- [QMD Memory Backend: Systemic Issues Requiring Comprehensive Fix](https://github.com/openclaw/openclaw/issues/11308)

## 更新日志

- **2026-02-10**: 完成本地 embedding 配置
