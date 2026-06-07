/**
 * StockCal API Proxy - CloudBase Cloud Function
 * 代理东方财富 + Finnhub API，绕过 CORS 跨域限制
 *
 * 调用方式:
 *   GET ?action=earnings&from=YYYY-MM-DD&to=YYYY-MM-DD   → A股财报
 *   GET ?action=forecast&from=YYYY-MM-DD&to=YYYY-MM-DD   → 业绩预告
 *   GET ?action=us&from=YYYY-MM-DD&to=YYYY-MM-DD          → 美股财报
 */
const EM_BASE = 'https://datacenter.eastmoney.com/securities/api/data/v1/get';
const FH_BASE = 'https://finnhub.io/api/v1';
const UA = 'Mozilla/5.0 (compatible; StockCal/3.0)';

exports.main = async (event) => {
  const { action, from, to } = event;
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json; charset=utf-8',
  };

  try {
    let data;
    switch (action) {
      case 'earnings': data = await fetchEastmoney(from, to); break;
      case 'forecast': data = await fetchForecast(from, to); break;
      case 'us':       data = await fetchFinnhub(from, to); break;
      default:         return { error: 'Unknown action: ' + action };
    }
    return data;
  } catch (err) {
    return { error: err.message };
  }
};

async function fetchEastmoney(from, to) {
  let rows = await fetchMain(from, to);
  if (!rows.length) rows = await fetchForecast(from, to);
  return rows;
}

async function fetchMain(from, to) {
  const allRows = [];
  let page = 1;
  while (page <= 3) {
    const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
    const url = `${EM_BASE}?reportName=RPT_LICO_FN_CPD&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,REPORTDATE,DATATYPE,BASIC_EPS,PARENT_NETPROFIT&pageNumber=${page}&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
    const resp = await fetch(url, { headers: { 'User-Agent': UA } });
    if (!resp.ok) break;
    const body = await resp.json();
    if (!body.success) break;
    const data = body.result?.data || [];
    if (!data.length) break;
    allRows.push(...data.map(r => ({
      symbol: r.SECURITY_CODE, name: r.SECURITY_NAME_ABBR,
      notice_date: r.NOTICE_DATE?.slice(0,10), report_date: r.REPORTDATE?.slice(0,10),
      period: r.DATATYPE, eps: r.BASIC_EPS,
    })));
    if (data.length < 500) break;
    page++;
  }
  return allRows;
}

async function fetchForecast(from, to) {
  const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
  const url = `${EM_BASE}?reportName=RPT_PUBLIC_OP_NEWPREDICT&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,PREDICT_TYPE,PREDICT_AMT_LOWER,PREDICT_AMT_UPPER,ADD_AMP_LOWER,ADD_AMP_UPPER&pageNumber=1&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
  const resp = await fetch(url, { headers: { 'User-Agent': UA } });
  if (!resp.ok) return [];
  const body = await resp.json();
  if (!body.success) return [];
  return (body.result?.data || []).map(r => ({
    symbol: r.SECURITY_CODE, name: r.SECURITY_NAME_ABBR,
    notice_date: r.NOTICE_DATE?.slice(0,10), period: '业绩预告', eps: null,
  }));
}

async function fetchFinnhub(from, to) {
  const key = process.env.FINNHUB_KEY || '';
  if (!key) return [];
  const url = `${FH_BASE}/calendar/earnings?from=${from}&to=${to}&token=${key}`;
  const resp = await fetch(url);
  if (!resp.ok) return [];
  const body = await resp.json();
  const seen = new Set();
  const deduped = [];
  for (const r of (body.earningsCalendar || [])) {
    const k = r.symbol + '|' + r.date;
    if (!seen.has(k)) { seen.add(k); deduped.push(r); }
  }
  return deduped;
}
