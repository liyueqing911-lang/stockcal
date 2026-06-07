/**
 * StockCal 后端缓存服务 v3.0 (Tushare)
 *
 * 数据源:
 *   Tushare — A股财报披露日期 + 业绩预告（主源）
 *   Finnhub — 美股财报（辅源，保留兼容）
 *
 * 架构:
 *   浏览器 → localhost:3000/api/* → 服务器内存缓存
 *     ├─ 命中 → 直接返回
 *     └─ 未命中 → Tushare / Finnhub → 缓存 → 返回
 *
 * 缓存策略:
 *   Tushare 免费版限制 1次/小时 → 24h TTL
 *   Finnhub 60次/分钟 → 6h TTL
 */

import express from 'express';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const PORT = process.env.PORT || 3000;

// ═══════════════════ 配置 ═══════════════════
const TUSHARE_TOKEN = process.env.TUSHARE_TOKEN || '';
const TUSHARE_BASE  = 'https://api.tushare.pro';
const FINNHUB_KEY   = process.env.FINNHUB_KEY || '';
const FINNHUB_BASE  = 'https://finnhub.io/api/v1';
const TUSHARE_CACHE_TTL = 24 * 60 * 60 * 1000;   // Tushare: 24小时（1次/小时限制）
const FINNHUB_CACHE_TTL = 6 * 60 * 60 * 1000;    // Finnhub: 6小时
const CACHE_FILE = path.join(__dirname, '.cache.json');

// ═══════════════════ 缓存引擎 ═══════════════════
const cache = new Map();

try {
  if (fs.existsSync(CACHE_FILE)) {
    const raw = JSON.parse(fs.readFileSync(CACHE_FILE, 'utf-8'));
    for (const [key, entry] of Object.entries(raw)) cache.set(key, entry);
    console.log(`📦 从磁盘恢复 ${cache.size} 条缓存`);
  }
} catch (_) {}

setInterval(() => {
  try { fs.writeFileSync(CACHE_FILE, JSON.stringify(Object.fromEntries(cache)), 'utf-8'); }
  catch (_) {}
}, 5 * 60 * 1000);

function cacheGet(key) {
  const entry = cache.get(key);
  if (!entry) return null;
  if (Date.now() - entry.ts > TUSHARE_CACHE_TTL) { cache.delete(key); return null; }
  return entry.data;
}

function cacheSet(key, data) {
  cache.set(key, { ts: Date.now(), data });
}

// ═══════════════════ CORS ═══════════════════
app.use((req, res, next) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(204).end();
  next();
});

app.use(express.json());
app.use(express.static(path.join(__dirname, '..')));

// ═══════════════════ 工具：调用 Tushare ═══════════════════
async function callTushare(apiName, params, fields) {
  const body = JSON.stringify({ api_name: apiName, token: TUSHARE_TOKEN, params, fields });
  const resp = await fetch(TUSHARE_BASE, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body,
  });
  if (!resp.ok) throw new Error(`Tushare HTTP ${resp.status}`);
  const json = await resp.json();
  if (json.code !== 0) throw new Error(`Tushare ${json.code}: ${json.msg || '未知错误'}`);
  return json.data; // { fields: [...], items: [[...], ...] }
}

// 将 Tushare 的 items 数组转为对象数组
function itemsToObjects(data) {
  if (!data || !data.fields || !data.items) return [];
  return data.items.map(row => {
    const obj = {};
    data.fields.forEach((f, i) => { obj[f] = row[i]; });
    return obj;
  });
}

// ═══════════════════ API 路由 ═══════════════════

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    cacheSize: cache.size,
    source: 'Tushare + Finnhub',
  });
});

// 手动刷新
app.post('/api/refresh', (req, res) => {
  cache.clear();
  try { fs.unlinkSync(CACHE_FILE); } catch (_) {}
  console.log('🔄 缓存已清除');
  res.json({ ok: true });
});

// ── Tushare: 财报披露日期 ──
app.get('/api/earnings', async (req, res) => {
  const now = new Date();
  const from = req.query.from || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = req.query.to   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));
  const cacheKey = `tushare:disclosure:${from}:${to}`;

  const cached = cacheGet(cacheKey);
  if (cached) {
    res.set('X-Cache', 'HIT');
    return res.json(cached);
  }

  console.log(`🌐 Tushare disclosure_date: ${from} → ${to}`);
  try {
    const data = await callTushare('disclosure_date',
      { start_date: from.replace(/-/g, ''), end_date: to.replace(/-/g, '') },
      'ts_code,ann_date,end_date,pre_date,actual_date,modify_date'
    );
    const rows = itemsToObjects(data);
    console.log(`  📄 disclosure_date: ${rows.length} 条`);
    cacheSet(cacheKey, rows);
    res.set('X-Cache', 'MISS');
    res.json(rows);
  } catch (err) {
    console.error('❌ Tushare disclosure_date 失败:', err.message);

    // 如果有旧缓存（即使过期），降级使用
    const entry = cache.get(cacheKey);
    if (entry && entry.data) {
      console.log('⚠️ 降级使用过期缓存');
      res.set('X-Cache', 'STALE');
      return res.json(entry.data);
    }

    res.status(502).json({ error: err.message });
  }
});

// ── Tushare: 业绩预告 ──
app.get('/api/forecast', async (req, res) => {
  const now = new Date();
  const annDate = req.query.ann_date || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1)).replace(/-/g, '');
  const cacheKey = `tushare:forecast:${annDate}`;

  const cached = cacheGet(cacheKey);
  if (cached) {
    res.set('X-Cache', 'HIT');
    return res.json(cached);
  }

  console.log(`🌐 Tushare forecast: ann_date=${annDate}`);
  try {
    const data = await callTushare('forecast',
      { ann_date: annDate },
      'ts_code,ann_date,end_date,type,p_change_min,p_change_max,net_profit_min,summary'
    );
    const rows = itemsToObjects(data);
    console.log(`  📄 forecast: ${rows.length} 条`);
    cacheSet(cacheKey, rows);
    res.set('X-Cache', 'MISS');
    res.json(rows);
  } catch (err) {
    console.error('❌ Tushare forecast 失败:', err.message);
    const entry = cache.get(cacheKey);
    if (entry && entry.data) {
      console.log('⚠️ 降级使用过期缓存');
      res.set('X-Cache', 'STALE');
      return res.json(entry.data);
    }
    // forecast 失败不报错，返回空数组（某些日期可能没数据）
    res.json([]);
  }
});

// ── Finnhub 美股财报（辅源，保留兼容） ──
app.get('/api/us/earnings', async (req, res) => {
  const now = new Date();
  const from = req.query.from || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = req.query.to   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));
  const cacheKey = `finnhub:earnings:${from}:${to}`;

  const cached = cacheGet(cacheKey);
  if (cached) {
    res.set('X-Cache', 'HIT');
    return res.json(cached);
  }

  console.log(`🌐 Finnhub earnings: ${from} → ${to}`);
  try {
    const allRows = await fetchFinnhubWithSplit(from, to);
    const seen = new Set();
    const deduped = [];
    for (const row of allRows) {
      const key = row.symbol + '|' + row.date;
      if (!seen.has(key)) { seen.add(key); deduped.push(row); }
    }
    cacheSet(cacheKey, deduped);
    console.log(`  📄 Finnhub: ${deduped.length} 条`);
    res.set('X-Cache', 'MISS');
    res.json(deduped);
  } catch (err) {
    console.error('❌ Finnhub 失败:', err.message);
    const entry = cache.get(cacheKey);
    if (entry && entry.data) { res.set('X-Cache', 'STALE'); return res.json(entry.data); }
    res.status(502).json({ error: err.message });
  }
});

async function fetchFinnhubWithSplit(from, to, depth) {
  if (depth > 5) return [];
  const pageKey = `finnhub:page:${from}:${to}`;
  let page = cacheGet(pageKey);
  if (page) return page;

  const url = `${FINNHUB_BASE}/calendar/earnings?from=${from}&to=${to}&token=${FINNHUB_KEY}`;
  const resp = await fetch(url);
  if (!resp.ok) throw new Error(`Finnhub ${resp.status}`);
  const body = await resp.json();
  page = body.earningsCalendar || [];

  if (page.length < 1500) { cacheSet(pageKey, page); return page; }

  // 触及 1500 上限，切半重试
  const mid = new Date((new Date(from).getTime() + new Date(to).getTime()) / 2);
  const midStr = fmtDate(mid);
  const [left, right] = await Promise.all([
    fetchFinnhubWithSplit(from, midStr, depth + 1),
    fetchFinnhubWithSplit(fmtDate(new Date(new Date(midStr).getTime() + 86400000)), to, depth + 1),
  ]);
  const combined = [...left, ...right];
  cacheSet(pageKey, combined);
  return combined;
}

// ── 搜索（Tushare + Finnhub 双源） ──
app.get('/api/search', async (req, res) => {
  const q = (req.query.q || '').trim();
  if (!q) return res.json([]);
  const cacheKey = `search:${q.toLowerCase()}`;
  const cached = cacheGet(cacheKey);
  if (cached) { res.set('X-Cache', 'HIT'); return res.json(cached); }

  const results = [];

  // 判断是否像 A 股代码（纯数字）
  if (/^\d{6}$/.test(q)) {
    // A 股代码精确查询
    try {
      const data = await callTushare('stock_basic',
        { ts_code: `${q}.SH`, list_status: 'L' },
        'ts_code,symbol,name,area,industry'
      );
      const rows = itemsToObjects(data);
      if (!rows.length) {
        const szData = await callTushare('stock_basic',
          { ts_code: `${q}.SZ`, list_status: 'L' },
          'ts_code,symbol,name,area,industry'
        );
        rows.push(...itemsToObjects(szData));
      }
      results.push(...rows.map(r => ({
        symbol: r.symbol || q,
        name: r.name || q,
        exchange: r.ts_code && r.ts_code.endsWith('.SH') ? '上交所' : '深交所',
        market: '🇨🇳',
      })));
    } catch (err) {
      console.log('Tushare stock_basic 不可用:', err.message);
    }
  }

  // Finnhub 搜索（美股等）
  try {
    const url = `${FINNHUB_BASE}/search?q=${encodeURIComponent(q)}&token=${FINNHUB_KEY}`;
    const resp = await fetch(url);
    if (resp.ok) {
      const body = await resp.json();
      const us = (body.result || [])
        .filter(r => r.type === 'Common Stock' && r.symbol && !r.symbol.includes('.'))
        .map(r => ({ symbol: r.symbol, name: r.description || r.symbol, exchange: r.exchange || '', market: '🇺🇸' }))
        .slice(0, 15);
      results.push(...us);
    }
  } catch (_) {}

  if (results.length) cacheSet(cacheKey, results);
  res.json(results);
});

// ═══════════════════ 工具函数 ═══════════════════
function fmtDate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

// ═══════════════════ 启动 ═══════════════════
app.listen(PORT, () => {
  console.log(`
  ╔══════════════════════════════════════════╗
  ║   📈 StockCal Server v3.0 (Tushare)     ║
  ║   端口: ${PORT}                            ║
  ║   缓存: ${cache.size} 条                     ║
  ║   主源: Tushare (A股财报+预告)          ║
  ║   辅源: Finnhub (美股财报)              ║
  ║   接口:                                ║
  ║     GET /api/earnings?from=&to=  (A股)  ║
  ║     GET /api/forecast?ann_date=  (预告) ║
  ║     GET /api/us/earnings?from=&to= (美股)║
  ║     GET /api/search?q=         (搜索)   ║
  ║     GET /api/health                    ║
  ╚══════════════════════════════════════════╝
  `);
});
