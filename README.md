# 考研督学教练 🎯

> 一个给 Claude Code 用的考研学习管理系统 — 计划、打卡、精析、复盘、记忆曲线全覆盖

## 安装方式

```bash
npx skills add [owner]/kaoyan-skill
# 或在 .claude/skills/ 下手动安装
```

## 功能一览

| 命令 | 功能 |
|------|------|
| `/kaoyan plan` | 智能学习规划（含四阶段模型） |
| `/kaoyan checkin` | 每日打卡（自动计算完成率） |
| `/kaoyan review` | 阅读精析（题型归因+错因分析） |
| `/kaoyan errors` | 错题本分析（按题型/错因/趋势统计） |
| `/kaoyan vocab` | 艾宾浩斯单词复习（间隔重复调度） |
| `/kaoyan weekly` | 周复盘报告（含环比和趋势） |
| `/kaoyan status` | 全局数据看板 |
| `/kaoyan sentences` | 长难句拆解 |
| `/kaoyan mock` | 限时模拟考 |
| `/kaoyan coach` | AI 督学对话 |

## 特性

- **数据驱动**：一切基于量化数据，不做体感判断
- **艾宾浩斯遗忘曲线**：基于 SM-2 算法的间隔重复调度
- **错因归因模型**：5 类 MECE 错因分类，针对性练习推荐
- **学习风格自适应**：根据打卡数据自动判断并调整策略
- **完整闭环**：计划→执行→记录→复盘→调整

## License

MIT
