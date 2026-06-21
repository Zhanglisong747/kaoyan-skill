#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 考研督学教练 · 定时提醒安装脚本
# 安装本地 cron 准点微信提醒（早 9:00 / 晚 21:00）
# 依赖：node >= 18, cli-wechat-bridge（已配置）
# ============================================================

echo "📦 安装考研定时提醒..."

# ── 检查依赖 ──────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  echo "❌ 未找到 node，请先安装 Node.js >= 18"
  exit 1
fi

# 检查 cli-wechat-bridge 是否已安装
WECHAT_TRANSPORT="/usr/local/lib/node_modules/cli-wechat-bridge/dist/wechat/wechat-transport.js"
if [ ! -f "$WECHAT_TRANSPORT" ]; then
  echo "⚠️ 未检测到 cli-wechat-bridge，尝试全局安装..."
  npm install -g cli-wechat-bridge 2>/dev/null || {
    echo "❌ 安装 cli-wechat-bridge 失败，请手动安装：npm install -g cli-wechat-bridge"
    exit 1
  }
fi

# 检查微信是否已登录
if ! node -e "
  const p = '$WECHAT_TRANSPORT';
  import(p).then(m => {
    const t = new m.WeChatTransport({log:()=>{}});
    const a = t.getCredentials();
    if (!a?.userId) { process.exit(1); }
  });
" 2>/dev/null; then
  echo "❌ 微信未登录，请先运行：wechat-setup"
  exit 1
fi

# ── 写入提醒脚本 ──────────────────────────────────────────
LOCAL_BIN="${HOME}/.local/bin"
mkdir -p "$LOCAL_BIN"

cat > "$LOCAL_BIN/kaoyan-wechat-morning-reminder" << 'REMINDER'
#!/usr/bin/env node
const path = '/usr/local/lib/node_modules/cli-wechat-bridge/dist/wechat/wechat-transport.js';
(async()=>{
  const { WeChatTransport } = await import(path);
  const transport = new WeChatTransport({ log: () => {} });
  const account = transport.getCredentials();
  if (!account?.userId) throw new Error('WeChat account not configured');
  const now = new Date();
  const hh = String(now.getHours()).padStart(2,'0');
  const mm = String(now.getMinutes()).padStart(2,'0');
  const text = [
    `☀️ 现在是 ${hh}:${mm}，考研早间提醒`,
    '',
    '今天开始前，先定一下学习计划：',
    '1. 今天英语学什么？',
    '2. 今天数学刷什么？',
    '3. 今天专业课 812 学什么？',
    '4. 今天单词计划多少？',
    '5. 今晚记得按 /kaoyan checkin 打卡复盘'
  ].join('\n');
  await transport.sendNotification(text, account.userId);
})().catch(err => {
  console.error('[kaoyan-wechat-morning-reminder] ' + (err?.stack || err?.message || String(err)));
  process.exit(1);
});
REMINDER

cat > "$LOCAL_BIN/kaoyan-wechat-reminder" << 'REMINDER'
#!/usr/bin/env node
const path = '/usr/local/lib/node_modules/cli-wechat-bridge/dist/wechat/wechat-transport.js';
(async()=>{
  const { WeChatTransport } = await import(path);
  const transport = new WeChatTransport({ log: () => {} });
  const account = transport.getCredentials();
  if (!account?.userId) throw new Error('WeChat account not configured');
  const now = new Date();
  const hh = String(now.getHours()).padStart(2,'0');
  const mm = String(now.getMinutes()).padStart(2,'0');
  const text = [
    `🌙 现在是 ${hh}:${mm}，考研晚间打卡提醒`,
    '',
    '请按 /kaoyan checkin 的方式记录：',
    '1. 今天学了什么？',
    '2. 做了几篇阅读？正确率如何？',
    '3. 单词复习/新学了多少？',
    '4. 数学刷了什么题？',
    '5. 专业课 812 学了什么？',
    '6. 明天计划是什么？'
  ].join('\n');
  await transport.sendNotification(text, account.userId);
})().catch(err => {
  console.error('[kaoyan-wechat-reminder] ' + (err?.stack || err?.message || String(err)));
  process.exit(1);
});
REMINDER

chmod +x "$LOCAL_BIN/kaoyan-wechat-morning-reminder" "$LOCAL_BIN/kaoyan-wechat-reminder"
echo "✅ 提醒脚本已创建：$LOCAL_BIN/"

# ── 安装 cron 定时任务 ──────────────────────────────────
CRON_FILE="/etc/cron.d/kaoyan-wechat-reminder"
CRON_CONTENT="SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
0 9 * * * root ${LOCAL_BIN}/kaoyan-wechat-morning-reminder >> ${HOME}/.cli-bridge/kaoyan-reminder.log 2>&1
0 21 * * * root ${LOCAL_BIN}/kaoyan-wechat-reminder >> ${HOME}/.cli-bridge/kaoyan-reminder.log 2>&1
"

if [ -f "$CRON_FILE" ]; then
  echo "$CRON_CONTENT" > "$CRON_FILE"
  echo "✅ cron 配置已更新：$CRON_FILE"
else
  echo "$CRON_CONTENT" | sudo tee "$CRON_FILE" > /dev/null 2>&1 || {
    echo "$CRON_CONTENT" | tee "$CRON_FILE" > /dev/null
  }
  echo "✅ cron 配置已创建：$CRON_FILE"
fi
chmod 644 "$CRON_FILE"

# ── 确保 cron 守护进程运行 ──────────────────────────────
if command -v systemctl &>/dev/null; then
  systemctl enable cron 2>/dev/null || true
  systemctl start cron 2>/dev/null || true
elif command -v service &>/dev/null; then
  service cron start 2>/dev/null || true
else
  # 直接启动
  if ! pgrep -x cron >/dev/null 2>&1; then
    /usr/sbin/cron 2>/dev/null || true
  fi
fi

echo "✅ cron 守护进程已启动（如果之前未运行）"

# ── 测试 ─────────────────────────────────────────────────
echo "📤 发送测试消息到微信..."
node "$LOCAL_BIN/kaoyan-wechat-morning-reminder" && echo "✅ 测试消息发送成功！"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 定时提醒安装完成！"
echo "  ☀️  早间提醒：每天 9:00"
echo "  🌙  晚间提醒：每天 21:00"
echo "  📌  发送方式：本地 cron → 微信 Bot"
echo "  📄  日志文件：${HOME}/.cli-bridge/kaoyan-reminder.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
