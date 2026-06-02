/**
 * Gönderi (Post) Modeli
 *
 * Mikroblog gönderilerinin veritabanı şemasını tanımlar.
 * Her gönderi en fazla 140 karakter içerik barındırabilir.
 */

const mongoose = require('mongoose');

// Gönderi şeması tanımı
const gonderiSemasi = new mongoose.Schema({
  // Gönderi içeriği - zorunlu, en fazla 140 karakter
  content: {
    type: String,
    required: [true, 'İçerik alanı zorunludur.'],
    maxlength: [140, 'İçerik en fazla 140 karakter olabilir.'],
    trim: true,
  },

  // Yazar adı - zorunlu, varsayılan olarak 'Anonim'
  author: {
    type: String,
    required: [true, 'Yazar alanı zorunludur.'],
    maxlength: [50, 'Yazar adı en fazla 50 karakter olabilir.'],
    trim: true,
    default: 'Anonim',
  },

  // Oluşturulma tarihi - otomatik atanır
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Modeli oluştur ve dışa aktar
const Gonderi = mongoose.model('Post', gonderiSemasi);

module.exports = Gonderi;
