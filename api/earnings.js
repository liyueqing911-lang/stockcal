/**
 * Vercel Serverless: A股财报披露日期 (Tushare)
 * GET /api/earnings?from=YYYY-MM-DD&to=YYYY-MM-DD
 */
export default async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(204).end();

  const now = new Date();
  const from = req.query.from || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = req.query.to   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));

  // Vercel Edge 缓存: 12 小时（Tushare 限制 1次/小时，需要长缓存）
  res.setHeader('Cache-Control', 's-maxage=43200, stale-while-revalidate=86400');

  try {
    const data = await callTushare('disclosure_date',
      { start_date: from.replace(/-/g, ''), end_date: to.replace(/-/g, '') },
      'ts_code,ann_date,end_date,pre_date,actual_date,modify_date'
    );
    const rows = itemsToObjects(data);
    return res.json(rows);
  } catch (err) {
    console.error('Tushare disclosure_date:', err.message);
    return res.status(502).json({ error: err.message });
  }
}

// ── 工具 ──
async function callTushare(apiName, params, fields) {
  const body = JSON.stringify({
    api_name: apiName,
    token: process.env.TUSHARE_TOKEN,
    params,
    fields,
  });
  const resp = await fetch('https://api.tushare.pro', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body,
  });
  const json = await resp.json();
  if (json.code !== 0) throw new Error(`Tushare ${json.code}: ${json.msg || '未知错误'}`);
  return json.data;
}

function itemsToObjects(data) {
  if (!data || !data.fields || !data.items) return [];
  return data.items.map(row => {
    const obj = {};
    data.fields.forEach((f, i) => { obj[f] = row[i]; });
    return obj;
  });
}

function fmtDate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
