# 🎯 考研督学教练 (Kaoyan Coach)

> Claude Code Skill — 智能学习规划、真题精析、错题管理、记忆曲线复习、进度追踪

## 📋 简介

考研督学教练是一个基于 Claude Code Skill 系统的考研学习管理工具。它不是替你做题的，而是你的**学习系统架构师 + 督学教练 + 数据分析师**。

### 核心原则

- **数据驱动** — 一切判断基于数据，不做体感判断
- **艾宾浩斯遗忘曲线** — 学习安排遵循记忆规律
- **刻意练习** — 重点攻克薄弱环节
- **闭环管理** — 计划→执行→记录→复盘→调整
- **量化追踪** — 所有学习行为量化

## 📦 安装

### 前提条件

- [Claude Code](https://claude.ai/code) 已安装
- 项目根目录在 `.claude/skills/` 路径下

### 安装步骤

```bash
# 克隆到 skills 目录
git clone git@github.com:Zhanglisong747/kaoyan-skill.git /root/.claude/skills/kaoyan

# 创建数据目录
mkdir -p /root/.claude/skills/kaoyan/data
```

然后在 Claude Code 中输入 `/kaoyan` 即可启动。

## 🛠 工具列表

| 命令 | 功能 | 适用场景 |
|------|------|---------|
| `/kaoyan plan` | 📋 学习计划 | 刚开始/需要调整 |
| `/kaoyan checkin` | ✅ 每日打卡 | 每天学习后 |
| `/kaoyan review` | 📖 阅读精析 | 做完一篇阅读后 |
| `/kaoyan errors` | ❌ 错题分析 | 定期/错题累积后 |
| `/kaoyan vocab` | 📚 单词复习 | 每天 |
| `/kaoyan weekly` | 📈 周复盘 | 每周日 |
| `/kaoyan status` | 📊 数据看板 | 随时查看进度 |
| `/kaoyan sentences` | ✂️ 长难句拆解 | 遇到难句时 |
| `/kaoyan mock` | 📝 模拟考 | 冲刺阶段 |
| `/kaoyan coach` | 💬 督学对话 | 心态波动时 |
| `/kaoyan remind` | ⏰ 定时提醒 | 早晚打卡提醒 |

## 📂 项目结构

```
kaoyan-skill/
├── SKILL.md              # 技能主文件（系统提示）
├── plugin.json           # 插件元数据
├── README.md             # 本文件
├── references/           # 参考文件体系
│   ├── study-plan.md     # 学习计划模板
│   ├── error-analysis.md # 错题分析框架
│   ├── vocab-system.md   # 单词记忆系统
│   ├── reading-analysis.md # 阅读精析方法论
│   ├── progress-tracking.md # 进度追踪模板
│   └── spaced-repetition.md # 艾宾浩斯间隔重复
├── scripts/              # 辅助脚本
│   └── install-reminder.sh # 微信定时提醒安装脚本
└── data/                 # 用户学习数据（本地生成）
    └── .gitkeep
```

## 📊 数据体系

学习数据存储在 `data/learning-data.json` 中，包含：
- 用户档案（目标分、考试时间等）
- 每日打卡记录
- 错题数据库
- 单词进度
- 周/月聚合数据

## 🔧 微信提醒

支持通过企业微信 Bot API 推送每日学习提醒，需要配合 [CLI-WeChat-Bridge](https://github.com/Zhanglisong747/cli-wechat-bridge) 使用。

```bash
sudo bash scripts/install-reminder.sh
```

## 📜 开源协议

MIT License
