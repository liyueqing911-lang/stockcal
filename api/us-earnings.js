/**
 * Vercel Serverless: 美股财报日历 (Finnhub)
 * GET /api/us-earnings?from=YYYY-MM-DD&to=YYYY-MM-DD
 */
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(204).end();

  const now = new Date();
  const from = req.query.from || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = req.query.to   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));
  res.setHeader('Cache-Control', 's-maxage=21600, stale-while-revalidate=43200');

  try {
    const allRows = await fetchFinnhubWithSplit(from, to, 0);
    const seen = new Set(), deduped = [];
    for (const row of allRows) {
      const key = row.symbol + '|' + row.date;
      if (!seen.has(key)) { seen.add(key); deduped.push(row); }
    }
    return res.json(deduped);
  } catch (err) {
    console.error('Finnhub:', err.message);
    return res.status(502).json({ error: err.message });
  }
}

async function fetchFinnhubWithSplit(from, to, depth) {
  if (depth > 5) return [];
  const key = process.env.FINNHUB_KEY || '';
  const url = `https://finnhub.io/api/v1/calendar/earnings?from=${from}&to=${to}&token=${key}`;
  const resp = await fetch(url);
  if (!resp.ok) throw new Error(`Finnhub ${resp.status}`);
  const body = await resp.json();
  const page = body.earningsCalendar || [];

  if (page.length < 1500) return page;

  // 触及 1500 上限，切半重试
  const mid = new Date((new Date(from).getTime() + new Date(to).getTime()) / 2);
  const midStr = fmtDate(mid);
  const [left, right] = await Promise.all([
    fetchFinnhubWithSplit(from, midStr, depth + 1),
    fetchFinnhubWithSplit(fmtDate(new Date(new Date(midStr).getTime() + 86400000)), to, depth + 1),
  ]);
  return [...left, ...right];
}

function fmtDate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
