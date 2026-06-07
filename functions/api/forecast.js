export async function onRequest(context) {
  const url = new URL(context.request.url);
  const now = new Date();
  const from = url.searchParams.get('from') || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = url.searchParams.get('to')   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));

  try {
    const EM = 'https://datacenter.eastmoney.com/securities/api/data/v1/get';
    const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
    const emUrl = `${EM}?reportName=RPT_PUBLIC_OP_NEWPREDICT&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,PREDICT_TYPE,PREDICT_AMT_LOWER,PREDICT_AMT_UPPER,ADD_AMP_LOWER,ADD_AMP_UPPER,PREDICT_CONTENT&pageNumber=1&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
    const resp = await fetch(emUrl, { headers: { 'User-Agent': 'Mozilla/5.0' } });
    if (!resp.ok) return json([]);
    const body = await resp.json();
    if (!body.success) return json([]);
    return json((body.result?.data || []).map(r => ({
      symbol: r.SECURITY_CODE, name: r.SECURITY_NAME_ABBR,
      notice_date: r.NOTICE_DATE?.slice(0,10), predict_type: r.PREDICT_TYPE,
      profit_lower: r.PREDICT_AMT_LOWER, profit_upper: r.PREDICT_AMT_UPPER,
      amp_lower: r.ADD_AMP_LOWER, amp_upper: r.ADD_AMP_UPPER, summary: r.PREDICT_CONTENT,
    })));
  } catch (_) { return json([]); }
}

function fmtDate(d) { return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`; }
function json(data) { return new Response(JSON.stringify(data), { headers: { 'Access-Control-Allow-Origin': '*', 'Content-Type': 'application/json' } }); }
