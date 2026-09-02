import { createClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = url && anonKey ? createClient(url, anonKey) : null;
export const isSupabaseConfigured = Boolean(supabase);

export async function loadProducts() {
  if (!supabase) return null;
  const { data, error } = await supabase.from('products').select('*, product_images(*)').eq('active', true).order('featured', { ascending: false }).order('created_at', { ascending: false });
  if (error) throw error;
  return data;
}
export async function signIn(email, password) {
  if (!supabase) throw new Error('Supabase ainda não configurado.');
  return supabase.auth.signInWithPassword({ email, password });
}
export async function signOut() { return supabase?.auth.signOut(); }
