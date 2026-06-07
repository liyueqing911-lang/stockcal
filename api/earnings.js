/**
 * A股财报数据 (东方财富 + 新浪财经 — 免费/全球可用/无需 Token)
 * GET /api/earnings?from=YYYY-MM-DD&to=YYYY-MM-DD
 */
const EM_BASE = 'https://datacenter.eastmoney.com/securities/api/data/v1/get';
// Vercel 环境用特定 UA，避免被当作爬虫拦截
const UA = 'Mozilla/5.0 (compatible; StockCal/3.0; +https://stockcal.vercel.app)';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(204).end();

  const now = new Date();
  const from = req.query.from || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = req.query.to   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));

  const diagnostics = { from, to, attempts: [] };

  try {
    // ── 方案 1: 东方财富 RPT_LICO_FN_CPD (主源) ──
    let rows = await fetchEastmoney(from, to, diagnostics);

    // ── 方案 2: 东方财富 forecast (兜底) ──
    if (!rows.length) {
      rows = await fetchEastmoneyForecast(from, to, diagnostics);
    }

    // 有数据才缓存，空结果不缓存
    if (rows.length) {
      res.setHeader('Cache-Control', 's-maxage=7200, stale-while-revalidate=14400');
    } else {
      res.setHeader('Cache-Control', 'no-cache, no-store, max-age=0');
    }

    // 通过响应头透传诊断信息，body 保持数组格式兼容前端
    res.setHeader('X-Diagnostics', JSON.stringify(diagnostics).slice(0, 500));
    return res.json(rows);
  } catch (err) {
    console.error('Eastmoney earnings:', err.message);
    return res.status(502).json({ error: err.message, diagnostics });
  }
}

async function fetchEastmoney(from, to, diag) {
  const allRows = [];
  let page = 1;
  try {
    while (page <= 4) {
      const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
      const url = `${EM_BASE}?reportName=RPT_LICO_FN_CPD&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,REPORTDATE,DATATYPE,BASIC_EPS,PARENT_NETPROFIT,REPORTTYPE&pageNumber=${page}&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
      const resp = await fetch(url, { headers: { 'User-Agent': UA, 'Accept': 'application/json' } });
      if (!resp.ok) { diag.push({ source: 'eastmoney', status: resp.status, page }); break; }
      const body = await resp.json();
      if (!body.success) { diag.push({ source: 'eastmoney', code: body.code, msg: body.message, page }); break; }
      const data = body.result?.data || [];
      if (!data.length) { diag.push({ source: 'eastmoney', status: 'empty', page }); break; }
      allRows.push(...data.map(r => ({
        symbol: r.SECURITY_CODE,
        name: r.SECURITY_NAME_ABBR,
        notice_date: r.NOTICE_DATE?.slice(0, 10),
        report_date: r.REPORTDATE?.slice(0, 10),
        period: r.DATATYPE,
        eps: r.BASIC_EPS,
        net_profit: r.PARENT_NETPROFIT,
      })));
      if (data.length < 500) break;
      page++;
    }
  } catch (e) { diag.push({ source: 'eastmoney', error: e.message }); }
  if (allRows.length) diag.push({ source: 'eastmoney', total: allRows.length });
  return allRows;
}

async function fetchEastmoneyForecast(from, to, diag) {
  try {
    const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
    const url = `${EM_BASE}?reportName=RPT_PUBLIC_OP_NEWPREDICT&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,PREDICT_TYPE,PREDICT_AMT_LOWER,PREDICT_AMT_UPPER,ADD_AMP_LOWER,ADD_AMP_UPPER,PREDICT_CONTENT&pageNumber=1&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
    const resp = await fetch(url, { headers: { 'User-Agent': UA, 'Accept': 'application/json' } });
    if (!resp.ok) { diag.push({ source: 'forecast', status: resp.status }); return []; }
    const body = await resp.json();
    if (!body.success) { diag.push({ source: 'forecast', code: body.code }); return []; }
    const data = body.result?.data || [];
    diag.push({ source: 'forecast', total: data.length });
    return data.map(r => ({
      symbol: r.SECURITY_CODE,
      name: r.SECURITY_NAME_ABBR,
      notice_date: r.NOTICE_DATE?.slice(0, 10),
      period: '业绩预告',
      predict_type: r.PREDICT_TYPE,
      eps: null,
    }));
  } catch (e) { diag.push({ source: 'forecast', error: e.message }); return []; }
}

function fmtDate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
