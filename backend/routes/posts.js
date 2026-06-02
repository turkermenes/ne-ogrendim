/**
 * Gönderi Rotaları
 *
 * Gönderiler için CRUD işlemlerini yöneten API uç noktaları.
 * Temel yol: /api/posts
 */

const express = require('express');
const router = express.Router();
const Gonderi = require('../models/Post');

/**
 * GET /api/posts
 * Tüm gönderileri listele (en yeniden en eskiye sıralı).
 */
router.get('/', async (_req, res) => {
  try {
    const gonderiler = await Gonderi.find().sort({ createdAt: -1 });
    res.json(gonderiler);
  } catch (hata) {
    console.error('❌ Gönderiler getirilirken hata:', hata.message);
    res.status(500).json({ hata: 'Gönderiler getirilirken bir sunucu hatası oluştu.' });
  }
});

/**
 * POST /api/posts
 * Yeni bir gönderi oluştur.
 * Gövde: { content: string (zorunlu, maks 140), author?: string (maks 50) }
 */
router.post('/', async (req, res) => {
  try {
    const { content, author } = req.body;

    // İçerik doğrulaması - boş veya eksik içerik kontrolü
    if (!content || typeof content !== 'string' || content.trim().length === 0) {
      return res.status(400).json({ hata: 'İçerik alanı zorunludur ve boş olamaz.' });
    }

    // İçerik uzunluk kontrolü
    if (content.trim().length > 140) {
      return res.status(400).json({ hata: 'İçerik en fazla 140 karakter olabilir.' });
    }

    // Yeni gönderi oluştur
    const yeniGonderi = new Gonderi({
      content: content.trim(),
      ...(author && typeof author === 'string' && author.trim().length > 0
        ? { author: author.trim() }
        : {}),
    });

    const kaydedilenGonderi = await yeniGonderi.save();
    res.status(201).json(kaydedilenGonderi);
  } catch (hata) {
    // Mongoose doğrulama hataları
    if (hata.name === 'ValidationError') {
      const dogrulamaHatalari = Object.values(hata.errors).map((e) => e.message);
      return res.status(400).json({ hata: dogrulamaHatalari.join(', ') });
    }

    console.error('❌ Gönderi oluşturulurken hata:', hata.message);
    res.status(500).json({ hata: 'Gönderi oluşturulurken bir sunucu hatası oluştu.' });
  }
});

/**
 * DELETE /api/posts/:id
 * Belirtilen ID'ye sahip gönderiyi sil.
 */
router.delete('/:id', async (req, res) => {
  try {
    const silinenGonderi = await Gonderi.findByIdAndDelete(req.params.id);

    // Gönderi bulunamadıysa 404 döndür
    if (!silinenGonderi) {
      return res.status(404).json({ hata: 'Gönderi bulunamadı.' });
    }

    // Başarılı silme - içerik yok (204 No Content)
    res.status(204).send();
  } catch (hata) {
    // Geçersiz MongoDB ObjectId formatı kontrolü
    if (hata.name === 'CastError') {
      return res.status(400).json({ hata: 'Geçersiz gönderi ID formatı.' });
    }

    console.error('❌ Gönderi silinirken hata:', hata.message);
    res.status(500).json({ hata: 'Gönderi silinirken bir sunucu hatası oluştu.' });
  }
});

module.exports = router;
