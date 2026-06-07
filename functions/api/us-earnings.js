export async function onRequest(context) {
  const url = new URL(context.request.url);
  const now = new Date();
  const from = url.searchParams.get('from') || fmtDate(new Date(now.getFullYear(), now.getMonth() - 1, 1));
  const to   = url.searchParams.get('to')   || fmtDate(new Date(now.getFullYear(), now.getMonth() + 2, 0));

  try {
    const key = context.env.FINNHUB_KEY || '';
    if (!key) return jsonResponse([], 200);
    const allRows = await fetchFinnhubWithSplit(from, to, key, 0);
    const seen = new Set(), deduped = [];
    for (const row of allRows) {
      const k = row.symbol + '|' + row.date;
      if (!seen.has(k)) { seen.add(k); deduped.push(row); }
    }
    return jsonResponse(deduped, 200, 's-maxage=21600');
  } catch (err) {
    return jsonResponse({ error: err.message }, 502);
  }
}

async function fetchFinnhubWithSplit(from, to, key, depth) {
  if (depth > 5) return [];
  const url = `https://finnhub.io/api/v1/calendar/earnings?from=${from}&to=${to}&token=${key}`;
  const resp = await fetch(url);
  if (!resp.ok) return [];
  const body = await resp.json();
  const page = body.earningsCalendar || [];
  if (page.length < 1500) return page;
  const mid = new Date((new Date(from).getTime() + new Date(to).getTime()) / 2);
  const midStr = fmtDate(mid);
  const [left, right] = await Promise.all([
    fetchFinnhubWithSplit(from, midStr, key, depth + 1),
    fetchFinnhubWithSplit(fmtDate(new Date(new Date(midStr).getTime() + 86400000)), to, key, depth + 1),
  ]);
  return [...left, ...right];
}

function fmtDate(d) { return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`; }

function jsonResponse(data, status, cache) {
  const headers = { 'Access-Control-Allow-Origin': '*', 'Content-Type': 'application/json; charset=utf-8' };
  if (cache) headers['Cache-Control'] = cache;
  return new Response(JSON.stringify(data), { status, headers });
}
