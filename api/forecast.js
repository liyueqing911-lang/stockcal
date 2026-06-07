/**
 * Vercel Serverless: A股业绩预告 (Tushare)
 * GET /api/forecast?ann_date=YYYYMMDD
 */
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(204).end();

  const now = new Date();
  const annDate = req.query.ann_date || fmtDateCompact(now);
  res.setHeader('Cache-Control', 's-maxage=43200, stale-while-revalidate=86400');

  try {
    const data = await callTushare('forecast',
      { ann_date: annDate },
      'ts_code,ann_date,end_date,type,p_change_min,p_change_max,net_profit_min,summary'
    );
    return res.json(itemsToObjects(data));
  } catch (err) {
    console.error('Tushare forecast:', err.message);
    return res.json([]); // forecast 失败返回空，不报错
  }
}

async function callTushare(apiName, params, fields) {
  const body = JSON.stringify({ api_name: apiName, token: process.env.TUSHARE_TOKEN, params, fields });
  const resp = await fetch('https://api.tushare.pro', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body });
  const json = await resp.json();
  if (json.code !== 0) throw new Error(`Tushare ${json.code}: ${json.msg || ''}`);
  return json.data;
}

function itemsToObjects(data) {
  if (!data || !data.fields || !data.items) return [];
  return data.items.map(row => { const obj = {}; data.fields.forEach((f, i) => { obj[f] = row[i]; }); return obj; });
}

function fmtDateCompact(d) {
  return `${d.getFullYear()}${String(d.getMonth() + 1).padStart(2, '0')}${String(d.getDate()).padStart(2, '0')}`;
}
