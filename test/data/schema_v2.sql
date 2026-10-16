CREATE TABLE "app_settings" ("key" TEXT NOT NULL, "value" INTEGER NOT NULL, PRIMARY KEY ("key"));

CREATE TABLE "cicilans" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "nama_cicilan" TEXT NOT NULL, "total_harga_barang" INTEGER NOT NULL, "tenor" INTEGER NOT NULL, "cicilan_ke" INTEGER NOT NULL DEFAULT 0, "jumlah_per_bulan" INTEGER NOT NULL, "tanggal_mulai" INTEGER NOT NULL, "tanggal_bayar_terakhir" INTEGER NULL, "catatan" TEXT NULL);

CREATE TABLE "split_group_orders" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "transaksi_id" INTEGER NOT NULL REFERENCES transaksis (id) ON DELETE CASCADE, "nama" TEXT NOT NULL, "harga_manual" INTEGER NULL, "status" INTEGER NOT NULL, "catatan" TEXT NULL);

CREATE TABLE "subscriptions" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "nama_layanan" TEXT NOT NULL, "harga_tetap" INTEGER NULL, "siklus_billing" INTEGER NOT NULL, "tanggal_tagihan_berikutnya" INTEGER NOT NULL, "hari_tagihan" INTEGER NOT NULL, "status" INTEGER NOT NULL, "catatan" TEXT NULL);

CREATE TABLE "transaksis" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "tanggal" INTEGER NOT NULL, "bulan_tagihan" INTEGER NULL, "deskripsi" TEXT NOT NULL, "jenis" INTEGER NOT NULL, "sumber_bayar" INTEGER NOT NULL, "total_tagihan" INTEGER NOT NULL, "merchant" TEXT NULL, "ongkir_fee" INTEGER NOT NULL DEFAULT 0, "status" INTEGER NOT NULL, "catatan" TEXT NULL, "subscription_id" INTEGER NULL REFERENCES subscriptions (id) ON DELETE SET NULL, "sumber_ekstraksi" INTEGER NULL);
