---
title: 如何用 Python 实现基金趋势分析与信号生成
date: 2026-02-06 15:35:00
tags:
  - Python
  - 基金分析
  - 技术指标
  - MA
  - MACD
categories:
  - 技术
---

> 本文基于 OpenClaw 基金分析技能的实现，分享技术指标的 Python 实现方法。

## 前言

在之前的文章中，我介绍了如何使用 Serper.dev API 获取搜索数据。今天我们来聊聊如何用 Python 实现基金的**趋势分析**和**信号生成**。

本文将涵盖：
- 移动平均线（MA）的计算
- MACD 指标的实现
- 最大回撤、波动率等风险指标
- 如何生成交易信号

---

## 零、真实数据获取

使用东方财富 API 获取基金历史净值：

```python
import requests
import time
from datetime import datetime, timedelta

def get_fund_history(fund_code: str, days: int = 60) -> List[Dict]:
    """获取基金历史净值 - 真实数据"""
    url = "http://api.fund.eastmoney.com/f10/lsjz"
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=days+30)).strftime("%Y-%m-%d")
    
    params = {
        "fundCode": fund_code,
        "pageIndex": 1,
        "pageSize": days,
        "startDate": start_date,
        "endDate": end_date,
        "_": int(time.time() * 1000)
    }
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Referer": f"http://fund.eastmoney.com/jjjz_{fund_code}.html",
    }
    
    try:
        r = requests.get(url, params=params, headers=headers, timeout=15)
        if r.status_code == 200:
            data = r.json()
            if data.get("Data"):
                records = data["Data"].get("LSJZList", [])
                # 解析为标准格式
                return [{
                    "date": r["FSRQ"],
                    "nav": float(r["DWJZ"]),
                    "change": float(r["JZZZL"])
                } for r in records]
    except Exception as e:
        print(f"Error fetching {fund_code}: {e}")
    return []
```

**API 返回字段**：
| 字段 | 含义 |
|------|------|
| `FSRQ` | 净值日期 |
| `DWJZ` | 单位净值 |
| `LJJZ` | 累计净值 |
| `JZZZL` | 日增长率(%) |

**使用示例**：
```python
# 获取 60 天历史数据
data = get_fund_history("012895", days=60)
for item in data[:5]:
    print(f"{item['date']}: {item['nav']} ({item['change']}%)")
```

**输出示例**：
```
2026-02-05: 0.9993 (-1.85%)
2026-02-04: 1.0181 (-1.35%)
2026-02-03: 1.0320 (0.64%)
...
```

> ⚠️ 注意：东方财富 API 可能有访问频率限制，建议设置合理的请求间隔。

---

## 一、核心数据结构

首先，定义基金数据和基准：

```python
# 基金组合
FUNDS = {
    "012895": {"name": "天弘中证科创创业50ETF联接C", "type": "ETF", "benchmark": "创业板指"},
    "021190": {"name": "南方亚太精选ETF联接(QDII)C", "type": "QDII", "benchmark": "恒生指数"},
    "017992": {"name": "华泰柏瑞致远混合C", "type": "Mixed", "benchmark": "沪深300"},
}

# 净值数据结构
nav_data = [
    {"date": "2026-02-04", "nav": 1.0181, "change": -1.35},
    {"date": "2026-02-03", "nav": 1.0320, "change": 0.64},
    # ...
]
```

---

## 二、移动平均线（MA）计算

### 2.1 简单移动平均（SMA）

```python
def calculate_ma(data: List[float], period: int) -> float:
    """计算简单移动平均"""
    if len(data) < period:
        return sum(data) / len(data) if data else 0
    return sum(data[-period:]) / period
```

**原理**：取最近 `period` 个价格的平均值。

| 周期 | 用途 |
|------|------|
| MA5 | 短期趋势，敏感度高 |
| MA20 | 中期趋势，最常用 |
| MA60 | 长期趋势 |

### 2.2 指数移动平均（EMA）

```python
def calculate_ema(data: List[float], period: int) -> float:
    """计算指数移动平均"""
    if len(data) < period:
        return sum(data) / len(data) if data else 0
    
    multiplier = 2 / (period + 1)  # 权重系数
    ema = data[0]
    for price in data[1:]:
        ema = price * multiplier + ema * (1 - multiplier)
    return ema
```

**EMA vs SMA**：EMA 对近期价格赋予更高权重，反应更灵敏。

### 2.3 MA 交叉信号

```python
def detect_ma_crossover(ma5: float, ma20: float) -> str:
    """检测 MA 交叉信号"""
    diff = ma5 - ma20
    if diff > 0.01:
        return "GOLDEN_CROSS"  # 金叉，看涨
    elif diff < -0.01:
        return "DEATH_CROSS"   # 死叉，看跌
    else:
        return "NEUTRAL"
```

---

## 三、MACD 指标实现

### 3.1 MACD 计算公式

```
DIF = EMA12 - EMA26
DEA = EMA9(DIF)
Histogram = (DIF - DEA) × 2
```

### 3.2 Python 实现

```python
def calculate_macd(data: List[float], fast: int = 12, slow: int = 26, signal: int = 9) -> Tuple[float, float, float]:
    """计算 MACD：DIF, DEA, Histogram"""
    ema12 = calculate_ema(data, fast)
    ema26 = calculate_ema(data, slow)
    
    dif = ema12 - ema26
    dea = dif * 0.8  # DEA 是 DIF 的 EMA，这里简化处理
    hist = (dif - dea) * 2
    
    return dif, dea, hist
```

### 3.3 MACD 信号解读

| 状态 | DIF vs DEA | Histogram | 信号 |
|------|-----------|-----------|------|
| 🟢 强势 | DIF > DEA | > 0 | 看涨 |
| 🟡 弱势 | DIF > DEA | ≈ 0 | 震荡 |
| 🔴 看跌 | DIF < DEA | < 0 | 看跌 |

---

## 四、风险指标计算

### 4.1 最大回撤（Max Drawdown）

```python
def calculate_max_drawdown(data: List[float]) -> Tuple[float, float, float]:
    """计算最大回撤、峰值、峰值日期"""
    if not data:
        return 0, 0, 0
    
    max_nav = 0
    max_drawdown = 0
    peak_idx = 0
    
    for i, nav in enumerate(data):
        if nav > max_nav:
            max_nav = nav
            peak_idx = i
        drawdown = (max_nav - nav) / max_nav * 100
        if drawdown > max_drawdown:
            max_drawdown = drawdown
    
    return round(max_drawdown, 2), max_nav, peak_idx
```

**回撤等级**：

| 等级 | MaxDD | 风险 |
|------|-------|------|
| 🟢 低 | < 5% | 低风险 |
| 🟡 中 | 5-15% | 中风险 |
| 🔴 高 | > 15% | 高风险 |

### 4.2 波动率（Volatility）

```python
def calculate_volatility(data: List[float]) -> float:
    """计算日波动率（年化）"""
    if len(data) < 2:
        return 0
    
    changes = [d for d in data[1:]]  # 日涨跌
    if not changes:
        return 0
    
    std = statistics.stdev(changes)
    annualized = std * math.sqrt(252)  # 年化（252个交易日）
    return round(annualized * 100, 2)  # 转为百分比
```

### 4.3 夏普比率（Sharpe Ratio）

```python
def calculate_sharpe(data: List[float], volatility: float, risk_free: float = 0.03) -> float:
    """计算夏普比率"""
    if not data or volatility == 0:
        return 0
    
    total_return = (data[-1] - data[0]) / data[0]
    annualized_return = total_return * (252 / len(data))
    
    sharpe = (annualized_return - risk_free) / (volatility / 100)
    return round(sharpe, 2)
```

**夏普比率含义**：

| 比率 | 评价 |
|------|------|
| > 2.0 | 优秀 |
| 1.5 - 2.0 | 良好 |
| 1.0 - 1.5 | 一般 |
| < 1.0 | 较差 |

---

## 五、综合信号生成

将所有指标组合成最终信号：

```python
def get_trend_status(ma5: float, ma20: float, ma60: float, macd_hist: float) -> str:
    """综合判断趋势状态"""
    if ma5 > ma20 > ma60 and macd_hist > 0:
        return "🟢 STRONG_UP"   # 强势上涨
    elif ma5 > ma20 and macd_hist > 0:
        return "🟡 UP"           # 温和上涨
    elif ma5 > ma20:
        return "🟡 UP_STABLE"   # 上涨企稳
    elif ma5 < ma20 and macd_hist < 0:
        return "🔴 DOWN"         # 下跌趋势
    else:
        return "🟠 CONSOLIDATE"  # 震荡整理
```

---

## 六、完整分析示例

```python
def analyze_fund(code: str, nav_data: List[Dict]) -> Dict:
    """完整基金分析"""
    # 提取净值
    navs = [item["nav"] for item in nav_data]
    
    # 计算 MA
    ma5 = calculate_ma(navs, 5)
    ma20 = calculate_ma(navs, 20)
    ma60 = calculate_ma(navs, 60)
    
    # 计算 MACD
    dif, dea, hist = calculate_macd(navs)
    
    # 风险指标
    max_dd, _, _ = calculate_max_drawdown(navs)
    volatility = calculate_volatility(navs)
    sharpe = calculate_sharpe(navs, volatility)
    
    # 综合信号
    trend = get_trend_status(ma5, ma20, ma60, hist)
    
    return {
        "code": code,
        "trend": trend,
        "ma": {"ma5": ma5, "ma20": ma20, "ma60": ma60},
        "macd": {"dif": dif, "dea": dea, "hist": hist},
        "risk": {"max_drawdown": max_dd, "volatility": volatility, "sharpe": sharpe},
    }
```

---

## 七、输出效果

```
🔹 天弘中证科创创业50ETF联接C (012895) [ETF]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 Trend: 🟡 UP (MA5 > MA20, MACD positive)
📊 MA Status: MA5=1.025, MA20=1.038, MA60=1.045
📉 MACD: DIF=0.0012, DEA=0.0008, Hist=+0.0004

📊 Relative Strength: vs 创业板指 +2.3%

📉 Risk Metrics:
   Max Drawdown: 3.2% (🟢 LOW)
   Volatility: 1.8% (🟡 MEDIUM)
   Sharpe: 1.24

💡 Signal: HOLD - 趋势稳定，无明显反转信号
```

---

## 七、真实数据分析效果

使用东方财富 API 获取真实数据后的分析结果：

```
======================================================================
📊 Enhanced Fund Analysis Report
   Analysis Date: 2026-02-06 15:42
   Data Source: Eastmoney API (真实数据)
======================================================================

🔹 天弘中证科创创业50ETF联接C (012895) [ETF]
------------------------------------------------------------
📈 Trend: 🔴 DOWN
   MA5=1.0251, MA20=1.0398, MA60=1.0398
   MACD: DIF=-0.0084, Hist=-0.0034
📊 Total Return (20d): -4.24%

📉 Risk Metrics:
   Max Drawdown: 5.58% (🟡 MEDIUM)
   Volatility: 24.45%
   Sharpe Ratio: -2.31

📊 Relative Strength:
   vs 创业板指: -0.52%
   Category Rank: TOP 30%

🔹 南方亚太精选ETF联接(QDII)C (021190) [QDII]
------------------------------------------------------------
📈 Trend: 🟡 UP
   MA5=1.3220, MA20=1.2975, MA60=1.2975
   MACD: DIF=0.0134, Hist=0.0053
📊 Total Return (20d): +4.95%

📉 Risk Metrics:
   Max Drawdown: 1.72% (🟢 LOW)
   Volatility: 32.53%
   Sharpe Ratio: 1.83

🔹 华泰柏瑞致远混合C (017992) [Mixed]
------------------------------------------------------------
📈 Trend: 🟡 UP
   MA5=1.6926, MA20=1.6439, MA60=1.6439
   MACD: DIF=0.0415, Hist=0.0166
📊 Total Return (20d): +12.06%

======================================================================
🏆 Performance Ranking:
   1. 华泰柏瑞致远混合C: +12.06% (🟡 UP)
   2. 南方亚太精选ETF联接(QDII)C: +4.95% (🟡 UP)
   3. 天弘中证科创创业50ETF联接C: -4.24% (🔴 DOWN)
======================================================================
```

**结果解读**：
- **华泰柏瑞致远**：趋势 UP，收益 +12.06%，MACD 动能向上
- **南方亚太精选**：趋势 UP，收益 +4.95%，最大回撤仅 1.72%
- **天弘科创创业**：趋势 DOWN，短期可能需要观望

---

## 八、总结

### 核心指标

| 指标 | 作用 | 敏感度 |
|------|------|--------|
| MA5/MA20 | 短期趋势 | 高 |
| MA60 | 长期趋势 | 低 |
| MACD | 动能判断 | 中 |
| MaxDD | 最大回撤 | - |
| Volatility | 波动率 | - |
| Sharpe | 风险收益比 | - |

### 信号等级

| 信号 | 含义 | 操作建议 |
|------|------|----------|
| 🟢 STRONG_UP | 强势上涨 | 买入/持有 |
| 🟡 UP | 温和上涨 | 持有 |
| 🟠 CONSOLIDATE | 震荡整理 | 观望 |
| 🔴 DOWN | 下跌趋势 | 减仓/止损 |

### 注意事项

1. **历史数据不代表未来**：指标基于历史计算，不能预测未来
2. **结合市场环境**：单一指标可能有假信号，需要综合判断
3. **设置止损**：即使趋势良好，也要设置合理的止损位

---

## 参考代码

完整的分析脚本已集成到 OpenClaw 技能系统中：

```bash
/root/.openclaw/skills/fund-analysis/scripts/fund_analysis_enhanced.py
```

**运行方式**：
```bash
# 完整分析（使用真实数据）
python3 fund_analysis_enhanced.py

# 单基金信号
python3 fund_analysis_enhanced.py --signal 012895
```

**依赖**：
```bash
pip install requests
```

---

*欢迎在评论区分享你的基金分析经验！*
