/**
 * Bugün Ne Öğrendim? - Ana Sunucu Dosyası
 *
 * Express tabanlı REST API sunucusu.
 * MongoDB veritabanına bağlanır ve gönderileri yönetir.
 */

require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Ortam değişkenleri
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/gunluk';

// Express uygulaması oluştur
const uygulama = express();

// --- Ara Katmanlar (Middleware) ---

// CORS desteğini etkinleştir
uygulama.use(cors());

// JSON gövde ayrıştırıcı
uygulama.use(express.json());

// --- Rotalar ---

// Sağlık kontrolü uç noktası
uygulama.get('/healthz', (_req, res) => {
  res.json({ status: 'ok' });
});

// Gönderi rotalarını bağla
const gonderiRotalari = require('./routes/posts');
uygulama.use('/api/posts', gonderiRotalari);

// --- MongoDB Bağlantısı ve Sunucu Başlatma ---

/**
 * Veritabanına bağlan ve sunucuyu başlat.
 */
async function baslat() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('✅ MongoDB veritabanına başarıyla bağlanıldı.');

    const sunucu = uygulama.listen(PORT, () => {
      console.log(`🚀 Sunucu ${PORT} portunda çalışıyor.`);
    });

    // --- Zarif Kapatma (Graceful Shutdown) ---

    /**
     * Sunucuyu ve veritabanı bağlantısını düzgünce kapat.
     * SIGINT ve SIGTERM sinyalleri yakalanır.
     */
    const zarifKapat = async (sinyal) => {
      console.log(`\n⚠️  ${sinyal} sinyali alındı. Sunucu kapatılıyor...`);

      // Önce HTTP sunucusunu kapat (yeni bağlantı kabul etme)
      sunucu.close(() => {
        console.log('🔒 HTTP sunucusu kapatıldı.');
      });

      try {
        // Veritabanı bağlantısını kapat
        await mongoose.connection.close();
        console.log('🔒 MongoDB bağlantısı kapatıldı.');
        process.exit(0);
      } catch (hata) {
        console.error('❌ Kapatma sırasında hata oluştu:', hata);
        process.exit(1);
      }
    };

    // Kapatma sinyallerini dinle
    process.on('SIGINT', () => zarifKapat('SIGINT'));
    process.on('SIGTERM', () => zarifKapat('SIGTERM'));
  } catch (hata) {
    console.error('❌ MongoDB bağlantı hatası:', hata.message);
    process.exit(1);
  }
}

baslat();

module.exports = uygulama;
