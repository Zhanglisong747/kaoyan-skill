# 间隔重复调度算法

## 核心公式

基于 SuperMemo SM-2 算法简化版：

```
interval(n) = interval(n-1) × factor(n)
```

其中：
- interval(1) = 1 天
- interval(2) = 3 天
- interval(3) = 7 天
- interval(4) = 15 天
- interval(5) = 30 天
- for n > 5: interval(n) = interval(n-1) × 1.5

factor(n) 根据复习质量调整：

| 复习质量 | factor | 说明 |
|---------|--------|------|
| 0（完全忘记） | 0.5 | 重新学习，interval回到1天 |
| 1（错误但记得） | 0.8 | 缩短间隔，加强复习 |
| 2（模糊） | 1.0 | 保持原间隔 |
| 3（正确但慢） | 1.2 | 适当延长 |
| 4（瞬间反应） | 1.5 | 正常延长 |
| 5（完美） | 2.0 | 大幅延长 |

## 每日调度算法

```
function getTodayReviewList(today, wordDatabase):
    reviewList = []
    for each word in wordDatabase:
        if word.nextReviewDate == today:
            reviewList.append(word)
    return reviewList
```

## 用户侧简化版

不需要让用户了解算法细节，只需要输出：

```
📅 今日需复习：List 4-6 (Day1) + List 1-3 (Day3) = 约85词
📝 今日新学：List 7 (25词)
```

## 优先级排序

当复习量过大时，按以下优先级处理：

| 优先级 | 类型 | 理由 |
|--------|------|------|
| 高 | 已复习3次以上的词 | 快掌握了，别浪费进度 |
| 中 | 第一次复习的词 | 刚学的，趁热打铁 |
| 低 | 简单词/已熟悉的 | 快速过一遍即可 |
