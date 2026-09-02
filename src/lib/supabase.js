import { createClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
export const supabase = url && anonKey ? createClient(url, anonKey) : null;
export const isSupabaseConfigured = Boolean(supabase);

export async function loadProducts({ admin = false } = {}) {
  if (!supabase) return [];
  let query = supabase.from('products').select('*, product_images(*)');
  if (!admin) query = query.eq('active', true);
  const { data, error } = await query.order('featured', { ascending: false }).order('created_at', { ascending: false });
  if (error) throw error;
  return data || [];
}
export async function loadSettings() {
  if (!supabase) return null;
  const { data, error } = await supabase.from('store_settings').select('*').eq('id', true).maybeSingle();
  if (error) throw error;
  return data;
}
export async function signIn(email, password) {
  if (!supabase) throw new Error('Supabase ainda não configurado.');
  return supabase.auth.signInWithPassword({ email, password });
}
export async function signOut() { return supabase?.auth.signOut(); }
export function publicStorageUrl(bucket, path) {
  if (!supabase || !path) return '';
  return supabase.storage.from(bucket).getPublicUrl(path).data.publicUrl;
}
export function formatProduct(row) {
  return { ...row, spec: row.specification || '', price: Number(row.price || 0), oldPrice: row.compare_at_price == null ? null : Number(row.compare_at_price), stock: row.stock_status === 'Disponível', accent: row.category === 'Samsung' ? 'galaxy-blue' : row.category === 'Xiaomi' ? 'redmi-green' : row.color === 'Azul' ? 'iphone-blue' : 'iphone-white', badge: row.featured ? 'PROMOÇÃO' : '', imageUrl: row.product_images?.[0] ? publicStorageUrl('product-images', row.product_images[0].storage_path) : '' };
}
