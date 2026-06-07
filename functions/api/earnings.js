/**
 * Cloudflare Pages Function: A股财报 (东方财富)
 * GET /api/earnings?from=YYYY-MM-DD&to=YYYY-MM-DD
 */
export async function onRequest(context) {
  const { request } = context;
  const url = new URL(request.url);
  const now = new Date();
  const from = url.searchParams.get('from') || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = url.searchParams.get('to')   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));

  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json; charset=utf-8',
  };

  try {
    const rows = await fetchEastmoney(from, to);
    if (rows.length) {
      headers['Cache-Control'] = 's-maxage=7200, stale-while-revalidate=14400';
    }
    return new Response(JSON.stringify(rows), { headers });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 502, headers });
  }
}

async function fetchEastmoney(from, to) {
  const EM = 'https://datacenter.eastmoney.com/securities/api/data/v1/get';
  const UA = 'Mozilla/5.0 (compatible; StockCal/3.0)';
  const allRows = [];
  let page = 1;
  while (page <= 4) {
    const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
    const url = `${EM}?reportName=RPT_LICO_FN_CPD&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,REPORTDATE,DATATYPE,BASIC_EPS,PARENT_NETPROFIT&pageNumber=${page}&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
    const resp = await fetch(url, { headers: { 'User-Agent': UA } });
    if (!resp.ok) break;
    const body = await resp.json();
    if (!body.success) {
      // 尝试 forecast 兜底
      return fetchEastmoneyForecast(from, to);
    }
    const data = body.result?.data || [];
    if (!data.length) break;
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
  if (!allRows.length) return fetchEastmoneyForecast(from, to);
  return allRows;
}

async function fetchEastmoneyForecast(from, to) {
  const EM = 'https://datacenter.eastmoney.com/securities/api/data/v1/get';
  const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
  const url = `${EM}?reportName=RPT_PUBLIC_OP_NEWPREDICT&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,PREDICT_TYPE,PREDICT_AMT_LOWER,PREDICT_AMT_UPPER,ADD_AMP_LOWER,ADD_AMP_UPPER&pageNumber=1&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
  const resp = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
  if (!resp.ok) return [];
  const body = await resp.json();
  if (!body.success) return [];
  return (body.result?.data || []).map(r => ({
    symbol: r.SECURITY_CODE,
    name: r.SECURITY_NAME_ABBR,
    notice_date: r.NOTICE_DATE?.slice(0, 10),
    period: '业绩预告',
    eps: null,
  }));
}

function fmtDate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
