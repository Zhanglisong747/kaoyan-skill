#!/usr/bin/env node
/**
 * 墨墨背单词 → learning-data.json 自动同步
 * 用法: node scripts/maimemo-sync.js [--write]
 * 不加 --write 只查看数据，加 --write 写入 learning-data.json
 */

const TOKEN = process.env.MAIMEMO_TOKEN || "REDACTED";
const BASE = "https://open.maimemo.com/open";
const DATA_FILE = __dirname + "/../data/learning-data.json";

async function fetchStudyProgress() {
  const url = BASE + "/api/v1/study/get_study_progress";
  const res = await fetch(url, {
    method: "POST",
    headers: { Authorization: `Bearer ${TOKEN}`, Accept: "application/json" },
  });
  const json = await res.json();
  if (!json.success) throw new Error("API fail: " + JSON.stringify(json.errors));
  return json.data.progress; // { finished, total, study_time }
}

async function fetchTodayItems() {
  const url = BASE + "/api/v1/study/get_today_items";
  const res = await fetch(url, {
    method: "POST",
    headers: { Authorization: `Bearer ${TOKEN}`, Accept: "application/json", "Content-Type": "application/json" },
    body: JSON.stringify({ limit: 500 }),
  });
  const json = await res.json();
  if (!json.success) throw new Error("API fail: " + JSON.stringify(json.errors));
  return json.data.today_items;
}

function formatStudyTime(ms) {
  const min = Math.round(ms / 60000);
  if (min < 60) return min + "min";
  return Math.floor(min / 60) + "h" + (min % 60) + "min";
}

async function main() {
  const writeMode = process.argv.includes("--write");

  const progress = await fetchStudyProgress();
  console.log("📊 墨墨今日学习数据");
  console.log(`  已学: ${progress.finished} / ${progress.total} 词`);
  console.log(`  时长: ${formatStudyTime(progress.study_time)}`);

  if (writeMode) {
    const fs = require("fs");
    const raw = fs.readFileSync(DATA_FILE, "utf8");
    const data = JSON.parse(raw);
    const today = new Date().toISOString().slice(0, 10);

    let checkin = data.checkins.find(c => c.date === today);
    if (!checkin) {
      checkin = {
        date: today,
        consecutiveDays: (data.consecutiveDays || 0) + 1,
        items: [],
        totalCompletionRate: null,
        summary: "墨墨自动同步"
      };
      data.checkins.push(checkin);
    }

    // 更新或添加单词条目
    const wordItemIdx = checkin.items.findIndex(i => i.name.includes("单词") || i.name.includes("墨墨"));
    const wordItem = {
      name: "单词（墨墨API同步）",
      planned: progress.total,
      completed: progress.finished,
      result: `${progress.finished}/${progress.total} 已学${formatStudyTime(progress.study_time)}`,
      completion: progress.total > 0 ? Math.round((progress.finished / progress.total) * 100) : 0
    };
    if (wordItemIdx >= 0) {
      checkin.items[wordItemIdx] = wordItem;
    } else {
      checkin.items.push(wordItem);
    }

    data.lastCheckinDate = today;
    data.vocabProgress.lastReviewDate = today;
    data.maimemoToken = TOKEN;
    fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2) + "\n");
    console.log("✅ 已写入 learning-data.json");
  } else {
    console.log("\n💡 加 --write 参数写入 learning-data.json");
  }
}

main().catch(err => { console.error("❌", err.message); process.exit(1); });
