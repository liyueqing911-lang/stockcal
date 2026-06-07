/**
 * CloudBase Cloud Function: A股财报 (东方财富)
 * 部署在腾讯云国内节点，直接调用东方财富 API
 */
const EM = 'https://datacenter.eastmoney.com/securities/api/data/v1/get';
const UA = 'Mozilla/5.0 (compatible; StockCal/3.0)';

exports.main = async (event) => {
  const now = new Date();
  const from = event.from || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = event.to   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));

  // 优先拉主报表
  let rows = await fetchMain(from, to);
  // 兜底业绩预告
  if (!rows.length) rows = await fetchForecast(from, to);

  return rows;
};

async function fetchMain(from, to) {
  const allRows = [];
  let page = 1;
  while (page <= 3) {
    const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
    const url = `${EM}?reportName=RPT_LICO_FN_CPD&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,REPORTDATE,DATATYPE,BASIC_EPS,PARENT_NETPROFIT&pageNumber=${page}&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
    const resp = await fetch(url, { headers: { 'User-Agent': UA } });
    if (!resp.ok) break;
    const body = await resp.json();
    if (!body.success) break;
    const data = body.result?.data || [];
    if (!data.length) break;
    allRows.push(...data.map(r => ({
      symbol: r.SECURITY_CODE, name: r.SECURITY_NAME_ABBR,
      notice_date: r.NOTICE_DATE?.slice(0,10), report_date: r.REPORTDATE?.slice(0,10),
      period: r.DATATYPE, eps: r.BASIC_EPS, net_profit: r.PARENT_NETPROFIT,
    })));
    if (data.length < 500) break;
    page++;
  }
  return allRows;
}

async function fetchForecast(from, to) {
  const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
  const url = `${EM}?reportName=RPT_PUBLIC_OP_NEWPREDICT&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,PREDICT_TYPE,PREDICT_AMT_LOWER,PREDICT_AMT_UPPER,ADD_AMP_LOWER,ADD_AMP_UPPER&pageNumber=1&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
  const resp = await fetch(url, { headers: { 'User-Agent': UA } });
  if (!resp.ok) return [];
  const body = await resp.json();
  return (body.result?.data || []).map(r => ({
    symbol: r.SECURITY_CODE, name: r.SECURITY_NAME_ABBR,
    notice_date: r.NOTICE_DATE?.slice(0,10), period: '业绩预告', eps: null,
  }));
}

function fmtDate(d) { return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`; }
