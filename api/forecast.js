/**
 * A股业绩预告 (东方财富 — 免费/全球可用/无需 Token)
 * GET /api/forecast?from=YYYY-MM-DD&to=YYYY-MM-DD
 */
const EM_BASE = 'https://datacenter.eastmoney.com/securities/api/data/v1/get';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(204).end();

  const now = new Date();
  const from = req.query.from || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = req.query.to   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));
  res.setHeader('Cache-Control', 's-maxage=7200, stale-while-revalidate=14400');

  try {
    const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
    const url = `${EM_BASE}?reportName=RPT_PUBLIC_OP_NEWPREDICT&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,PREDICT_TYPE,PREDICT_AMT_LOWER,PREDICT_AMT_UPPER,ADD_AMP_LOWER,ADD_AMP_UPPER,PREDICT_CONTENT&pageNumber=1&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
    const resp = await fetch(url);
    if (!resp.ok) return res.json([]);
    const body = await resp.json();
    if (!body.success) return res.json([]);

    const data = body.result?.data || [];
    return res.json(data.map(r => ({
      symbol: r.SECURITY_CODE,
      name: r.SECURITY_NAME_ABBR,
      notice_date: r.NOTICE_DATE?.slice(0, 10),
      predict_type: r.PREDICT_TYPE,
      profit_lower: r.PREDICT_AMT_LOWER,
      profit_upper: r.PREDICT_AMT_UPPER,
      amp_lower: r.ADD_AMP_LOWER,
      amp_upper: r.ADD_AMP_UPPER,
      summary: r.PREDICT_CONTENT,
    })));
  } catch (err) {
    console.error('Eastmoney forecast:', err.message);
    return res.json([]);
  }
}

function fmtDate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
