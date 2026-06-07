exports.main = async (event) => {
  const now = new Date();
  const from = event.from || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = event.to   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));
  const key  = process.env.FINNHUB_KEY || '';
  const all = await fetchFinnhubWithSplit(from, to, key, 0);
  const seen = new Set(); const deduped = [];
  for (const r of all) { const k = r.symbol+'|'+r.date; if (!seen.has(k)) { seen.add(k); deduped.push(r); } }
  return deduped;
};
async function fetchFinnhubWithSplit(from, to, key, depth) {
  if (depth > 5) return [];
  const url = `https://finnhub.io/api/v1/calendar/earnings?from=${from}&to=${to}&token=${key}`;
  const resp = await fetch(url); if (!resp.ok) return [];
  const body = await resp.json(); const page = body.earningsCalendar || [];
  if (page.length < 1500) return page;
  const mid = new Date((new Date(from).getTime()+new Date(to).getTime())/2);
  const m = fmtDate(mid);
  const [l,r] = await Promise.all([fetchFinnhubWithSplit(from,m,key,depth+1), fetchFinnhubWithSplit(fmtDate(new Date(new Date(m).getTime()+86400000)),to,key,depth+1)]);
  return [...l,...r];
}
function fmtDate(d) { return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`; }
