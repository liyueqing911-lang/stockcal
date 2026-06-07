/**
 * Vercel Serverless: 股票搜索 (Finnhub)
 * GET /api/search?q=特斯拉
 */
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(204).end();

  const q = (req.query.q || '').trim();
  if (!q) return res.json([]);
  res.setHeader('Cache-Control', 's-maxage=3600, stale-while-revalidate=7200');

  const results = [];

  // A股代码精确搜索（纯数字6位）
  if (/^\d{6}$/.test(q)) {
    try {
      const data = await callTushare('stock_basic', { ts_code: `${q}.SH`, list_status: 'L' }, 'ts_code,symbol,name,area,industry');
      let rows = itemsToObjects(data);
      if (!rows.length) {
        const szData = await callTushare('stock_basic', { ts_code: `${q}.SZ`, list_status: 'L' }, 'ts_code,symbol,name,area,industry');
        rows = itemsToObjects(szData);
      }
      results.push(...rows.map(r => ({ symbol: r.symbol || q, name: r.name || q, exchange: r.ts_code?.endsWith('.SH') ? '上交所' : '深交所', market: '🇨🇳' })));
    } catch (_) {}
  }

  // Finnhub 搜索
  try {
    const key = process.env.FINNHUB_KEY || '';
    const url = `https://finnhub.io/api/v1/search?q=${encodeURIComponent(q)}&token=${key}`;
    const resp = await fetch(url);
    if (resp.ok) {
      const body = await resp.json();
      results.push(...(body.result || []).filter(r => r.type === 'Common Stock' && r.symbol && !r.symbol.includes('.'))
        .map(r => ({ symbol: r.symbol, name: r.description || r.symbol, exchange: r.exchange || '', market: '🇺🇸' })).slice(0, 15));
    }
  } catch (_) {}

  return res.json(results);
}

async function callTushare(apiName, params, fields) {
  const body = JSON.stringify({ api_name: apiName, token: process.env.TUSHARE_TOKEN, params, fields });
  const resp = await fetch('https://api.tushare.pro', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body });
  const json = await resp.json();
  if (json.code !== 0) throw new Error(`Tushare ${json.code}`);
  return json.data;
}

function itemsToObjects(data) {
  if (!data || !data.fields || !data.items) return [];
  return data.items.map(row => { const obj = {}; data.fields.forEach((f, i) => { obj[f] = row[i]; }); return obj; });
}
