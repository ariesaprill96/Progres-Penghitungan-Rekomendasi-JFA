# Dashboard GitHub Pages + Supabase

## Struktur

- `index.html`: entry untuk GitHub Pages
- `dashboard-progres.html`: dashboard utama
- `supabase-config.js`: config frontend Supabase
- `supabase_schema.sql`: schema dan seed awal
- `supabase_live_policies.sql`: policy live yang aman untuk publik baca, admin tulis

## Setup Supabase

1. Buat project Supabase.
2. Jalankan `supabase_schema.sql` di SQL Editor.
3. Edit `supabase_live_policies.sql`:
   Ganti `admin@example.com` dengan email admin Anda.
4. Jalankan `supabase_live_policies.sql`.
5. Di Supabase Auth, buat user admin:
   - Email: samakan dengan `adminEmail` di `supabase-config.js`
   - Password: `Lokus1JFA`

## Setup Frontend

Edit `supabase-config.js`:

```js
window.SUPABASE_CONFIG = {
  url: 'https://YOUR_PROJECT_REF.supabase.co',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
  adminUsername: 'Admin',
  adminEmail: 'admin@example.com',
};
```

## Aturan Admin

- Dashboard tetap bisa dibuka publik dalam mode baca.
- Tambah, edit, hapus hanya aktif setelah login admin.
- Username admin di UI: `Admin`
- Password admin dicek lewat Supabase Auth, bukan hardcoded di HTML.

## GitHub Pages

1. Push repo ke GitHub.
2. Buka `Settings > Pages`.
3. Pilih branch utama dan root folder.
4. Akses site dari URL GitHub Pages.

## Catatan

- `anonKey` aman dipakai di frontend selama RLS aktif.
- Jangan pernah taruh `service_role` key di repo/frontend.
