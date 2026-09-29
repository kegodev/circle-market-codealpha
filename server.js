import express from 'express';
import { createClient } from '@supabase/supabase-js';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const app = express();
const url = process.env.SUPABASE_URL || 'https://regdrfswpsfoxinymrld.supabase.co';
const key = process.env.SUPABASE_PUBLISHABLE_KEY || 'sb_publishable_ltI4np3B1JUypzE87pZXNg_5NIYUSex';
const db = createClient(url, key, { auth: { persistSession: false } });
const api = (token) => createClient(url, key, { auth: { persistSession: false }, global: { headers: { Authorization: `Bearer ${token}` } } });
app.disable('x-powered-by');
app.use(express.json({ limit: '24kb' }));
app.use(express.static(path.join(path.dirname(fileURLToPath(import.meta.url)), 'public')));
app.get('/api/config', (_req, res) => res.json({ url, key }));
app.get('/api/products', async (_req, res) => {
  const { data, error } = await db.from('shop_products').select('id,slug,name,category,description,price_cents,stock,image_url,featured').eq('active', true).order('id');
  if (error) return res.status(503).json({ error: 'Catalog unavailable. Please try again.' });
  res.json(data);
});
app.get('/api/products/:slug', async (req, res) => {
  const { data, error } = await db.from('shop_products').select('id,slug,name,category,description,price_cents,stock,image_url,featured').eq('slug', req.params.slug).eq('active', true).maybeSingle();
  if (error) return res.status(503).json({ error: 'Product unavailable.' });
  if (!data) return res.status(404).json({ error: 'Product not found.' });
  res.json(data);
});
async function signedIn(req, res, next) {
  const match = /^Bearer (.+)$/.exec(req.headers.authorization || '');
  if (!match) return res.status(401).json({ error: 'Sign in to continue.' });
  const { data, error } = await db.auth.getUser(match[1]);
  if (error || !data.user || data.user.is_anonymous) return res.status(401).json({ error: 'Your session has expired. Sign in again.' });
  req.client = api(match[1]);
  next();
}
app.post('/api/orders', signedIn, async (req, res) => {
  const { items } = req.body || {};
  if (!Array.isArray(items) || items.length < 1 || items.length > 20 || items.some(x => !Number.isSafeInteger(x.product_id) || !Number.isSafeInteger(x.quantity) || x.quantity < 1 || x.quantity > 20)) {
    return res.status(400).json({ error: 'Cart contains invalid items.' });
  }
  const { data, error } = await req.client.rpc('shop_place_order', { p_items: items });
  if (error) return res.status(400).json({ error: error.message });
  res.status(201).json(data);
});
app.get('/api/orders', signedIn, async (req, res) => {
  const { data, error } = await req.client.from('shop_orders').select('id,created_at,status,total_cents,shop_order_items(product_name,quantity,unit_price_cents)').order('created_at', { ascending: false }).limit(20);
  if (error) return res.status(503).json({ error: 'Orders unavailable.' });
  res.json(data);
});
app.use('/api', (_req, res) => res.status(404).json({ error: 'Not found.' }));
app.get('/{*path}', (_req, res) => res.sendFile(path.join(path.dirname(fileURLToPath(import.meta.url)), 'public/index.html')));
app.listen(Number(process.env.PORT) || 3000, '0.0.0.0', () => console.log(`Circle Market on port ${process.env.PORT || 3000}`));
