/**
 * A股财报数据 (东方财富 — 免费/全球可用/无需 Token)
 * GET /api/earnings?from=YYYY-MM-DD&to=YYYY-MM-DD
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
    const allRows = [];
    let page = 1;
    let hasMore = true;

    // 分页拉取（每页 500 条）
    while (hasMore) {
      const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
      const url = `${EM_BASE}?reportName=RPT_LICO_FN_CPD&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,REPORTDATE,DATATYPE,BASIC_EPS,PARENT_NETPROFIT,REPORTTYPE&pageNumber=${page}&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
      const resp = await fetch(url);
      if (!resp.ok) break;
      const body = await resp.json();
      if (!body.success) break;

      const data = body.result?.data || [];
      allRows.push(...data.map(r => ({
        symbol: r.SECURITY_CODE,
        name: r.SECURITY_NAME_ABBR,
        notice_date: r.NOTICE_DATE?.slice(0, 10),
        report_date: r.REPORTDATE?.slice(0, 10),
        period: r.DATATYPE,
        eps: r.BASIC_EPS,
        net_profit: r.PARENT_NETPROFIT,
      })));

      hasMore = data.length === 500;
      page++;
    }

    return res.json(allRows);
  } catch (err) {
    console.error('Eastmoney earnings:', err.message);
    return res.status(502).json({ error: err.message });
  }
}

function fmtDate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
