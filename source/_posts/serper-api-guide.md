---
title: Serper.dev 免费 Google 搜索 API 使用指南
date: 2026-02-06 13:50:00
tags:
  - API
  - Google
  - 搜索
  - 开发工具
categories:
  - 技术
---

> 本文首发于 2026-02-06

## 为什么需要 Serper？

在开发 AI 助手或自动化脚本时，经常需要获取搜索引擎结果。常见的方案有：

| 服务 | 特点 | 限制 |
|------|------|------|
| Google Custom Search | 官方但复杂 | 需要配置 Search Console |
| Brave Search | 新兴选择 | 免费额度有限 |
| **Serper.dev** | Google 结果，**免费 2500 次** | 额度用完后收费 |

对于个人项目或小规模使用，**Serper 2500 次免费额度足够用很久**。

---

## Serper 简介

Serper.dev 是一个提供 Google 搜索结果 API 的服务：

- ✅ 无需信用卡，**免费 2500 次查询**
- ✅ 返回结构化 JSON
- ✅ 支持搜索、图片、新闻、地点、自动补全
- ✅ 响应速度快

### 免费额度

| 套餐 | 价格 | 额度 |
|------|------|------|
| Free | **免费** | 2,500 次 |
| Pro | $50/月 | 10,000 次 |

---

## 快速上手

### 1. 获取 API Key

访问 https://serper.dev 注册账号，免费获取 API Key。

### 2. 基础用法（cURL）

```bash
# 设置 API Key
export SERPER_API_KEY="你的API密钥"

# 网页搜索
curl "https://google.serper.dev/search?q=OpenClaw" \
  -H "X-API-Key: $SERPER_API_KEY"
```

### 3. 响应示例

```json
{
  "searchParameters": {
    "q": "OpenClaw",
    "type": "search",
    "engine": "google"
  },
  "organic": [
    {
      "title": "OpenClaw - AI Assistant",
      "url": "https://github.com/openclaw/openclaw",
      "snippet": "OpenClaw is an AI assistant that runs on your machine...",
      "domain": "github.com",
      "position": 1
    }
  ],
  "credits": 1
}
```

---

## Python 示例

```python
import requests

SERPER_API_KEY = "你的API密钥"

def search(query, num=10):
    url = "https://google.serper.dev/search"
    params = {"q": query, "num": num}
    headers = {"X-API-Key": SERPER_API_KEY}
    
    response = requests.get(url, params=params, headers=headers)
    return response.json()

# 使用
results = search("基金行情 今日")
for r in results["organic"]:
    print(f"{r['position']}. {r['title']}")
    print(f"   {r['url']}")
```

---

## 进阶：支持多种搜索类型

```python
import requests

SERPER_API_KEY = "你的API密钥"

def serper_search(query, search_type="search", num=10):
    """通用搜索接口"""
    endpoints = {
        "search": "https://google.serper.dev/search",
        "images": "https://google.serper.dev/images",
        "news": "https://google.serper.dev/news",
        "places": "https://google.serper.dev/places",
        "autocomplete": "https://google.serper.dev/autocomplete"
    }
    
    url = endpoints.get(search_type, endpoints["search"])
    params = {"q": query, "num": num}
    headers = {"X-API-Key": SERPER_API_KEY}
    
    return requests.get(url, params=params, headers=headers).json()

# 使用
images = serper_search("可爱猫咪", search_type="images", num=5)
news = serper_search("AI 新闻", search_type="news", num=10)
```

---

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `q` | 搜索关键词 | 必填 |
| `gl` | 国家代码 | US |
| `hl` | 语言代码 | en |
| `num` | 返回数量 | 10 |
| `safe` | 安全搜索 | on |

示例：
```bash
curl "https://google.serper.dev/search?q=Python&gl=US&hl=en&num=5" \
  -H "X-API-Key: $SERPER_API_KEY"
```

---

## 在 OpenClaw 中使用

OpenClaw 是一个本地运行的 AI 助手，可以通过以下方式集成 Serper：

```bash
# 1. 设置环境变量
export SERPER_API_KEY="你的API密钥"

# 2. 使用 serper skill 进行搜索
/root/.openclaw/skills/serper/scripts/search.sh "今日基金行情"
```

---

## 替代方案对比

| 服务 | 免费额度 | 特点 |
|------|---------|------|
| **Serper** | 2,500 次 | Google 结果准 |
| DuckDuckGo API | 无限 | 完全免费但结果一般 |
| Brave Search | 有限 | 需要申请 |
| **LangSearch** | 无限 | 免费，支持 Rerank |

---

## 总结

Serper.dev 是一个适合个人开发者和小型项目的搜索 API：

1. **免费 2500 次**，无需信用卡
2. **Google 质量**，结果准确
3. **使用简单**，返回 JSON
4. **响应快速**，适合实时应用

对于大多数个人项目来说，2500 次免费额度已经足够用很久了。即使用完，升级到付费版（$50/月）也比自建爬虫省心。

---

**参考链接：**
- 官网：https://serper.dev
- 文档：https://serper.dev/docs
- 注册：https://serper.dev/signup

---

*欢迎在评论区分享你的使用经验！*
