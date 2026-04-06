create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.master_instansi (
  id uuid primary key default gen_random_uuid(),
  nama_instansi text not null,
  kategori text not null check (kategori in (
    'Instansi Pusat',
    'Pemerintah Daerah Provinsi',
    'Pemerintah Daerah Kab/Kota'
  )),
  provinsi text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint master_instansi_unique unique (nama_instansi, kategori)
);

create table if not exists public.master_pic (
  id uuid primary key default gen_random_uuid(),
  nama_pic text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.verifikasi_kebutuhan_jfa (
  id uuid primary key default gen_random_uuid(),
  instansi_id uuid references public.master_instansi(id) on update cascade on delete set null,
  nama_instansi text not null,
  kategori text not null check (kategori in (
    'Instansi Pusat',
    'Pemerintah Daerah Provinsi',
    'Pemerintah Daerah Kab/Kota'
  )),
  pic_id uuid references public.master_pic(id) on update cascade on delete set null,
  pic text not null,
  progres text not null check (progres in (
    'Diterima',
    'Koordinasi awal dengan instansi pengusul',
    'Verifikasi',
    'Verifikasi Arsiparis Ahli Utama',
    'Validasi ke Instansi',
    'Proses TTE',
    'Selesai (BA & Rekomendasi)',
    'Surat Jawaban Perbaikan Penghitungan',
    'Surat Jawaban'
  )),
  tanggal_disposisi date,
  jumlah_opd integer not null default 0 check (jumlah_opd >= 0),
  jumlah_usulan integer not null default 0 check (jumlah_usulan >= 0),
  jumlah_rekomendasi integer not null default 0 check (jumlah_rekomendasi >= 0),
  nomor_surat_rekomendasi text,
  tanggal_surat_rekomendasi date,
  link_dokumen_surat_rekomendasi text,
  update_di_rekap date,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_master_instansi_kategori on public.master_instansi(kategori);
create index if not exists idx_master_instansi_provinsi on public.master_instansi(provinsi);
create index if not exists idx_verifikasi_kategori on public.verifikasi_kebutuhan_jfa(kategori);
create index if not exists idx_verifikasi_pic on public.verifikasi_kebutuhan_jfa(pic);
create index if not exists idx_verifikasi_progres on public.verifikasi_kebutuhan_jfa(progres);
create index if not exists idx_verifikasi_tanggal_disposisi on public.verifikasi_kebutuhan_jfa(tanggal_disposisi);

drop trigger if exists trg_master_instansi_updated_at on public.master_instansi;
create trigger trg_master_instansi_updated_at
before update on public.master_instansi
for each row
execute function public.set_updated_at();

drop trigger if exists trg_master_pic_updated_at on public.master_pic;
create trigger trg_master_pic_updated_at
before update on public.master_pic
for each row
execute function public.set_updated_at();

drop trigger if exists trg_verifikasi_kebutuhan_jfa_updated_at on public.verifikasi_kebutuhan_jfa;
create trigger trg_verifikasi_kebutuhan_jfa_updated_at
before update on public.verifikasi_kebutuhan_jfa
for each row
execute function public.set_updated_at();

insert into public.master_pic (nama_pic)
values
  ('Okta Handi Suryadi, S.ST.Ars.'),
  ('Aries Aprilliyan, S. Sej'),
  ('Desti Trisfati Dwi Putri, SAP, M.A.P'),
  ('Nurhayati, S.ST.Ars'),
  ('Arum Esthu Domaz Kusumaning Bawono, S.AP'),
  ('Siti Rubiati, S.IP.')
on conflict (nama_pic) do nothing;

insert into public.verifikasi_kebutuhan_jfa (
  nama_instansi,
  kategori,
  pic,
  progres,
  tanggal_disposisi,
  jumlah_opd,
  jumlah_usulan,
  jumlah_rekomendasi,
  nomor_surat_rekomendasi,
  tanggal_surat_rekomendasi,
  link_dokumen_surat_rekomendasi,
  update_di_rekap
)
values
  ('Kementerian Agama', 'Instansi Pusat', 'Aries Aprilliyan, S. Sej', 'Verifikasi', '2026-03-10', 3, 12, 8, null, null, null, null),
  ('Badan Kepegawaian Negara', 'Instansi Pusat', 'Okta Handi Suryadi, S.ST.Ars.', 'Selesai (BA & Rekomendasi)', '2026-02-15', 1, 5, 5, 'B-102/ANRI/SDM.01/2026', '2026-03-18', 'https://example.com/surat-rekomendasi-bkn', '2026-03-19'),
  ('Kementerian Keuangan', 'Instansi Pusat', 'Nurhayati, S.ST.Ars', 'Proses TTE', '2026-03-20', 2, 9, 7, null, null, null, null),
  ('Pemerintah Provinsi Jawa Barat', 'Pemerintah Daerah Provinsi', 'Desti Trisfati Dwi Putri, SAP, M.A.P', 'Koordinasi awal dengan instansi pengusul', '2026-03-25', 5, 18, 0, null, null, null, null),
  ('Kab. Tangerang', 'Pemerintah Daerah Kab/Kota', 'Siti Rubiati, S.IP.', 'Diterima', '2026-04-01', 1, 4, 0, null, null, null, null),
  ('Kota Bandung', 'Pemerintah Daerah Kab/Kota', 'Arum Esthu Domaz Kusumaning Bawono, S.AP', 'Validasi ke Instansi', '2026-03-05', 1, 6, 4, null, null, null, null)
on conflict do nothing;

alter table public.master_instansi enable row level security;
alter table public.master_pic enable row level security;
alter table public.verifikasi_kebutuhan_jfa enable row level security;

drop policy if exists "Allow authenticated read master_instansi" on public.master_instansi;
create policy "Allow authenticated read master_instansi"
on public.master_instansi
for select
to authenticated
using (true);

drop policy if exists "Allow authenticated read master_pic" on public.master_pic;
create policy "Allow authenticated read master_pic"
on public.master_pic
for select
to authenticated
using (true);

drop policy if exists "Allow authenticated read verifikasi" on public.verifikasi_kebutuhan_jfa;
create policy "Allow authenticated read verifikasi"
on public.verifikasi_kebutuhan_jfa
for select
to authenticated
using (true);

drop policy if exists "Allow authenticated write verifikasi" on public.verifikasi_kebutuhan_jfa;
create policy "Allow authenticated write verifikasi"
on public.verifikasi_kebutuhan_jfa
for all
to authenticated
using (true)
with check (true);
