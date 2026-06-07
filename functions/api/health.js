export async function onRequest() {
  return new Response(JSON.stringify({ status: 'ok', source: 'Eastmoney + Finnhub', platform: 'Cloudflare Pages' }), {
    headers: { 'Access-Control-Allow-Origin': '*', 'Content-Type': 'application/json' },
  });
}
