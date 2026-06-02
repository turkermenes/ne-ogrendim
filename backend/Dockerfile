# ============================================
# Bugün Ne Öğrendim? - Backend Dockerfile
# Çok aşamalı, güvenli ve optimize edilmiş yapı
# ============================================

FROM node:18-alpine

# Uygulama meta verileri
LABEL maintainer="gunluk-ekibi"
LABEL description="Bugün Ne Öğrendim? - Mikroblog Backend API"
LABEL version="1.0.0"

# Çalışma dizinini ayarla
WORKDIR /app

# Önce paket dosyalarını kopyala (Docker önbellek optimizasyonu)
# Bu sayede bağımlılıklar değişmediğinde yeniden yükleme yapılmaz
COPY package*.json ./

# Sadece üretim bağımlılıklarını yükle
RUN npm ci --omit=dev

# Kaynak kodunu kopyala
COPY . .

# Uygulamanın dinleyeceği portu belirt
EXPOSE 3000

# Güvenlik: root yerine 'node' kullanıcısıyla çalıştır
USER node

# Uygulamayı başlat
CMD ["node", "server.js"]
