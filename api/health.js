export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.json({
    status: 'ok',
    source: 'Eastmoney + Finnhub',
    deployed: 'Vercel',
    time: new Date().toISOString(),
  });
}
