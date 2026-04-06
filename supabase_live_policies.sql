-- Ganti email admin di bawah ini sebelum dijalankan di Supabase SQL Editor.
-- Password admin tidak disimpan di SQL. Buat user admin dari Supabase Auth dashboard
-- dengan email yang sama dan password: Lokus1JFA

create or replace function public.is_dashboard_admin()
returns boolean
language sql
stable
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) = lower('admin@example.com');
$$;

alter table public.master_instansi enable row level security;
alter table public.master_pic enable row level security;
alter table public.verifikasi_kebutuhan_jfa enable row level security;

drop policy if exists "Public read master_instansi" on public.master_instansi;
create policy "Public read master_instansi"
on public.master_instansi
for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admin write master_instansi" on public.master_instansi;
create policy "Admin write master_instansi"
on public.master_instansi
for all
to authenticated
using (public.is_dashboard_admin())
with check (public.is_dashboard_admin());

drop policy if exists "Public read master_pic" on public.master_pic;
create policy "Public read master_pic"
on public.master_pic
for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admin write master_pic" on public.master_pic;
create policy "Admin write master_pic"
on public.master_pic
for all
to authenticated
using (public.is_dashboard_admin())
with check (public.is_dashboard_admin());

drop policy if exists "Public read verifikasi" on public.verifikasi_kebutuhan_jfa;
create policy "Public read verifikasi"
on public.verifikasi_kebutuhan_jfa
for select
to anon, authenticated
using (true);

drop policy if exists "Admin write verifikasi" on public.verifikasi_kebutuhan_jfa;
create policy "Admin write verifikasi"
on public.verifikasi_kebutuhan_jfa
for all
to authenticated
using (public.is_dashboard_admin())
with check (public.is_dashboard_admin());
