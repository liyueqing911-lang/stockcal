exports.main = async (event) => {
  const now = new Date();
  const from = event.from || `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}-${String(now.getDate()).padStart(2,'0')}`;
  const to   = event.to   || `${now.getFullYear()}-${String(now.getMonth()+3).padStart(2,'0')}-${String(now.getDate()).padStart(2,'0')}`;
  const filter = `(NOTICE_DATE>='${from}')(NOTICE_DATE<='${to}')`;
  const url = `https://datacenter.eastmoney.com/securities/api/data/v1/get?reportName=RPT_PUBLIC_OP_NEWPREDICT&columns=SECURITY_CODE,SECURITY_NAME_ABBR,NOTICE_DATE,PREDICT_TYPE,PREDICT_AMT_LOWER,PREDICT_AMT_UPPER,ADD_AMP_LOWER,ADD_AMP_UPPER,PREDICT_CONTENT&pageNumber=1&pageSize=500&sortColumns=NOTICE_DATE&sortTypes=1&source=WEB&client=WEB&filter=${encodeURIComponent(filter)}`;
  const resp = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
  if (!resp.ok) return [];
  const body = await resp.json();
  return (body.result?.data || []).map(r => ({
    symbol: r.SECURITY_CODE, name: r.SECURITY_NAME_ABBR,
    notice_date: r.NOTICE_DATE?.slice(0,10), predict_type: r.PREDICT_TYPE,
    profit_lower: r.PREDICT_AMT_LOWER, profit_upper: r.PREDICT_AMT_UPPER,
    amp_lower: r.ADD_AMP_LOWER, amp_upper: r.ADD_AMP_UPPER, summary: r.PREDICT_CONTENT,
  }));
};
