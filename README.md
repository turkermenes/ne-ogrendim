# 💡 Bugün Ne Öğrendim? — Günlük Mikro-Blog

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![GKE](https://img.shields.io/badge/GKE-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/kubernetes-engine)

## 📖 Proje Açıklaması

**"Bugün Ne Öğrendim?"**, kullanıcıların gün içinde öğrendikleri kısa bilgileri (maksimum **140 karakter**) paylaştıkları ve ortak bir zaman akışında herkesin yazılarını görebildiği bir **mikro-blog** uygulamasıdır.

Proje, modern web teknolojileri kullanılarak geliştirilmiş olup, **Podman/Docker** ile container hâline getirilmiş ve **Google Kubernetes Engine (GKE)** üzerinde çalıştırılmak üzere yapılandırılmıştır.

---

## 🏗️ Mimari Diyagram

```
                                    ┌─────────────────────────────────────────────┐
                                    │          Google Kubernetes Engine            │
                                    │              Namespace: gunluk              │
                                    │                                             │
  ┌──────────┐    ┌─────────────┐   │  ┌──────────────┐    ┌──────────────────┐   │
  │          │    │  LoadBalancer│   │  │   Frontend   │    │     Backend      │   │
  │ Kullanıcı├───►│   Service   ├──►│  │  (Nginx +    ├───►│  (Node.js +     │   │
  │          │    │   :80       │   │  │   HTML/CSS/  │    │   Express)      │   │
  └──────────┘    └─────────────┘   │  │   JS)        │    │   :3000         │   │
                                    │  │  2-5 replika  │    │  2-5 replika    │   │
                                    │  └──────────────┘    └───────┬──────────┘   │
                                    │                              │              │
                                    │                    ┌─────────▼──────────┐   │
                                    │                    │     MongoDB        │   │
                                    │                    │     :27017         │   │
                                    │                    │   1 replika        │   │
                                    │                    │   (PVC: 5Gi)       │   │
                                    │                    └────────────────────┘   │
                                    └─────────────────────────────────────────────┘
```

### NetworkPolicy Akışı

```
  İnternet ──► Frontend (port 80) ──► Backend (port 3000) ──► MongoDB (port 27017)
              ↑ Dışarıya açık         ↑ Sadece frontend       ↑ Sadece backend
                                        erişebilir              erişebilir
```

---

## 🛠️ Teknoloji Yığını

| Katman | Teknoloji | Açıklama |
|--------|-----------|----------|
| **Frontend** | HTML5 + CSS3 + Vanilla JS | Modern, koyu temalı SPA |
| **Frontend Sunucu** | Nginx (Alpine) | Statik dosya sunumu + reverse proxy |
| **Backend** | Node.js 18 + Express.js | REST API sunucusu |
| **Veritabanı** | MongoDB 6.0 | Esnek şemalı NoSQL veritabanı |
| **ORM** | Mongoose | MongoDB nesne modelleme |
| **Container** | Podman / Docker | Container oluşturma ve yönetim |
| **Orkestrasyon** | Kubernetes (GKE) | Container orkestrasyonu |
| **CI/CD** | Google Cloud Build | Sürekli entegrasyon ve dağıtım |
| **Registry** | Google Artifact Registry | Container imaj deposu |

---

## 📂 Proje Dizin Yapısı

```
gunluk/
├── README.md                              # Bu dosya - Proje raporu
├── cloudbuild.yaml                        # CI/CD pipeline yapılandırması
├── .gitignore                             # Git tarafından yoksayılacak dosyalar
│
├── frontend/                              # Frontend uygulaması
│   ├── Dockerfile                         # Frontend container tanımı
│   ├── nginx.conf                         # Nginx yapılandırması (reverse proxy)
│   ├── index.html                         # Ana HTML sayfası (SPA)
│   ├── css/
│   │   └── style.css                      # Stil dosyası (koyu tema, glassmorphism)
│   └── js/
│       └── app.js                         # Uygulama mantığı (CRUD, zaman akışı)
│
├── backend/                               # Backend API
│   ├── Dockerfile                         # Backend container tanımı
│   ├── package.json                       # Node.js proje tanımı ve bağımlılıklar
│   ├── server.js                          # Express sunucu başlatma
│   ├── models/
│   │   └── Post.js                        # Mongoose Post modeli
│   └── routes/
│       └── posts.js                       # API rotaları (GET, POST, DELETE)
│
├── k8s/                                   # Kubernetes manifest dosyaları
│   ├── namespace.yaml                     # gunluk namespace tanımı
│   ├── mongo-pv.yaml                      # PersistentVolume (5Gi)
│   ├── mongo-pvc.yaml                     # PersistentVolumeClaim
│   ├── mongo-deployment.yaml              # MongoDB Deployment
│   ├── mongo-service.yaml                 # MongoDB Service (ClusterIP)
│   ├── backend-deployment.yaml            # Backend Deployment (2 replika)
│   ├── backend-service.yaml               # Backend Service (ClusterIP)
│   ├── frontend-deployment.yaml           # Frontend Deployment (2 replika)
│   ├── frontend-service.yaml              # Frontend Service (LoadBalancer)
│   ├── hpa-backend.yaml                   # Backend HPA (2-5 replika)
│   ├── hpa-frontend.yaml                  # Frontend HPA (2-5 replika)
│   ├── network-policy.yaml                # Ağ politikaları (4 kural)
│   └── ingress.yaml                       # Ingress kaynağı
│
└── scripts/                               # Dağıtım ve yönetim scriptleri
    ├── env.sh                             # Ortak ortam değişkenleri
    ├── 01-create-namespace.sh             # Namespace oluştur
    ├── 02-build-images.sh                 # İmajları build et (Podman/Docker)
    ├── 03-push-images.sh                  # İmajları registry'ye push et
    ├── 04-deploy-mongo.sh                 # MongoDB dağıtımı
    ├── 05-deploy-backend.sh               # Backend dağıtımı
    ├── 06-deploy-frontend.sh              # Frontend dağıtımı
    ├── 07-apply-network-policies.sh       # Ağ politikalarını uygula
    ├── 08-apply-hpa.sh                    # HPA uygula
    ├── 09-apply-ingress.sh                # Ingress uygula
    ├── 10-check-status.sh                 # Durum kontrolü
    ├── 11-scale-deployment.sh             # Manuel ölçekleme
    ├── 12-rolling-update.sh               # Rolling update
    ├── 13-rollback.sh                     # Rollback
    ├── 14-view-logs.sh                    # Log görüntüleme
    ├── 15-port-forward.sh                 # Port forwarding
    ├── 16-deploy-all.sh                   # Tümünü dağıt (01-09)
    └── 17-cleanup-all.sh                  # Tümünü temizle
```

---

## 📋 Ön Koşullar

Projeyi çalıştırmak için aşağıdaki araçların kurulu olması gerekmektedir:

| Araç | Versiyon | Kurulum |
|------|----------|---------|
| **Google Cloud SDK (gcloud)** | ≥ 450.0.0 | [Kurulum Rehberi](https://cloud.google.com/sdk/docs/install) |
| **kubectl** | ≥ 1.27 | `gcloud components install kubectl` |
| **Podman** veya **Docker** | ≥ 4.0 / ≥ 20.0 | [Podman](https://podman.io/) / [Docker](https://docs.docker.com/get-docker/) |
| **Node.js** (lokal geliştirme) | ≥ 18.0 | [nodejs.org](https://nodejs.org/) |

### GCP Hesap Yapılandırması

```bash
# GCP'ye giriş yapın
gcloud auth login

# Proje ID'nizi ayarlayın
gcloud config set project YOUR_PROJECT_ID

# Gerekli API'leri etkinleştirin
gcloud services enable container.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com

# Artifact Registry deposu oluşturun
gcloud artifacts repositories create gunluk-repo \
    --repository-format=docker \
    --location=europe-west1 \
    --description="Gunluk mikro-blog imajları"

# GKE kümesi oluşturun
gcloud container clusters create gunluk-cluster \
    --zone=europe-west1-b \
    --num-nodes=3 \
    --machine-type=e2-medium \
    --enable-network-policy

# kubectl'i kümeye bağlayın
gcloud container clusters get-credentials gunluk-cluster \
    --zone=europe-west1-b
```

---

## 🚀 Hızlı Başlangıç

### 1. Ortam Değişkenlerini Ayarlayın

`scripts/env.sh` dosyasını düzenleyerek kendi GCP bilgilerinizi girin:

```bash
# scripts/env.sh içindeki değişkenleri güncelleyin
export PROJECT_ID="your-gcp-project-id"    # Kendi GCP Proje ID'niz
export REGION="europe-west1"                # Tercih ettiğiniz bölge
export ZONE="europe-west1-b"                # Tercih ettiğiniz zone
```

### 2. Tek Komutla Dağıtım

Tüm sistemi tek bir komutla dağıtmak için:

```bash
cd scripts
./16-deploy-all.sh
```

Bu script sırasıyla şunları yapar:
1. Namespace oluşturur
2. Container imajlarını build eder
3. İmajları registry'ye push eder
4. MongoDB'yi dağıtır (PV/PVC dahil)
5. Backend'i dağıtır
6. Frontend'i dağıtır
7. NetworkPolicy'leri uygular
8. HPA'ları uygular
9. Ingress'i uygular

### 3. Durumu Kontrol Edin

```bash
./10-check-status.sh
```

### 4. Uygulamaya Erişin

```bash
# External IP'yi görüntüleyin
kubectl get service gunluk-frontend-service -n gunluk

# Veya port-forward ile lokal test
./15-port-forward.sh
# Tarayıcıda: http://localhost:8080
```

---

## 🔧 Adım Adım Dağıtım

Her adımı ayrı ayrı çalıştırmak isterseniz:

```bash
cd scripts

# 1. Namespace oluştur
./01-create-namespace.sh

# 2. Container imajlarını build et
./02-build-images.sh

# 3. İmajları Artifact Registry'ye push et
./03-push-images.sh

# 4. MongoDB'yi dağıt (PV, PVC, Deployment, Service)
./04-deploy-mongo.sh

# 5. Backend'i dağıt
./05-deploy-backend.sh

# 6. Frontend'i dağıt
./06-deploy-frontend.sh

# 7. NetworkPolicy'leri uygula
./07-apply-network-policies.sh

# 8. HPA'ları uygula (otomatik ölçekleme)
./08-apply-hpa.sh

# 9. Ingress'i uygula
./09-apply-ingress.sh

# 10. Durumu kontrol et
./10-check-status.sh
```

---

## ☸️ Kubernetes Kaynakları Detayları

### Namespace
- **Ad**: `gunluk`
- Tüm kaynaklar bu namespace altında izole edilmiştir.

### Deployment'lar

| Deployment | Replika | Strateji | İmaj |
|------------|---------|----------|------|
| `gunluk-frontend` | 2 (HPA: 2-5) | RollingUpdate | `gunluk-frontend:latest` |
| `gunluk-backend` | 2 (HPA: 2-5) | RollingUpdate | `gunluk-backend:latest` |
| `mongo` | 1 | Recreate | `mongo:6.0` |

**Rolling Update Stratejisi:**
- `maxSurge: 1` — Güncelleme sırasında en fazla 1 ekstra pod
- `maxUnavailable: 0` — Sıfır kesinti süresi (zero-downtime)

### Service'ler

| Service | Tür | Port | Erişim |
|---------|-----|------|--------|
| `gunluk-frontend-service` | LoadBalancer | 80 | Dış dünya → Frontend |
| `gunluk-backend-service` | ClusterIP | 3000 | Frontend → Backend |
| `mongo-service` | ClusterIP | 27017 | Backend → MongoDB |

### Persistent Volume / PVC
- **Kapasite**: 5Gi
- **Erişim Modu**: ReadWriteOnce
- **Amaç**: MongoDB verilerinin kalıcı olarak saklanması
- Pod yeniden başlatıldığında veriler kaybolmaz

### HorizontalPodAutoscaler (HPA)
- **Hedef CPU Kullanımı**: %50
- **Minimum Replika**: 2
- **Maksimum Replika**: 5
- CPU kullanımı %50'yi aştığında otomatik olarak pod sayısı artırılır

### NetworkPolicy (Ağ Politikaları)

4 adet NetworkPolicy tanımlanmıştır:

| Politika | Kaynak | Hedef | Port |
|----------|--------|-------|------|
| `deny-all` | Tümü reddet | Tümü | — |
| `allow-backend-to-mongo` | Backend podları | MongoDB | 27017 |
| `allow-frontend-to-backend` | Frontend podları | Backend | 3000 |
| `allow-external-to-frontend` | Dış trafik | Frontend | 80 |

Bu yapı **zero-trust** güvenlik modelini uygular: varsayılan olarak tüm trafik engellenir, yalnızca gerekli iletişim yolları açılır.

### Ingress
- Dış trafiği frontend servisine yönlendirir
- GKE'de Google Cloud Load Balancer ile entegre çalışır

---

## 📜 Script Kullanım Rehberi

### Temel Operasyonlar

```bash
# Durumu kontrol et
./10-check-status.sh

# Logları görüntüle
./14-view-logs.sh backend        # Backend logları
./14-view-logs.sh frontend       # Frontend logları
./14-view-logs.sh mongo           # MongoDB logları
./14-view-logs.sh backend -f      # Canlı log takibi

# Port forwarding (lokal test)
./15-port-forward.sh
```

### Ölçekleme (Scaling)

```bash
# Manuel ölçekleme
./11-scale-deployment.sh gunluk-backend 4     # Backend'i 4 pod'a çıkar
./11-scale-deployment.sh gunluk-frontend 3    # Frontend'i 3 pod'a çıkar

# HPA ile otomatik ölçekleme zaten aktif (2-5 arası)
kubectl get hpa -n gunluk
```

### Rolling Update

```bash
# Yeni versiyon ile güncelleme
./12-rolling-update.sh backend v2.0.0     # Backend'i v2.0.0'a güncelle
./12-rolling-update.sh frontend v2.0.0    # Frontend'i v2.0.0'a güncelle
```

**Güncelleme sırasında:**
- Yeni pod'lar oluşturulur
- Sağlık kontrolleri (readinessProbe) geçilir
- Eski pod'lar kapatılır
- **Sıfır kesinti** sağlanır

### Rollback

```bash
# Önceki versiyona geri dön
./13-rollback.sh backend     # Backend'i geri al
./13-rollback.sh frontend    # Frontend'i geri al
```

### Temizlik

```bash
# Tüm kaynakları sil
./17-cleanup-all.sh
```

⚠️ **Dikkat**: Bu script namespace dahil tüm kaynakları siler. Onay istenir.

---

## 🔄 CI/CD Pipeline (Google Cloud Build)

### Pipeline Akışı

```
┌─────────────┐    ┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│  GitHub'a   │───►│ Cloud Build  │───►│  İmaj Build   │───►│  İmaj Push   │
│  Push       │    │  Tetiklenir  │    │  & Tag        │    │  (Registry)  │
└─────────────┘    └──────────────┘    └───────────────┘    └──────┬───────┘
                                                                    │
                   ┌──────────────┐    ┌───────────────┐    ┌──────▼───────┐
                   │  Deployment  │◄───│  K8s Apply    │◄───│  GKE Bağlan  │
                   │  Güncelle    │    │  (manifests)  │    │              │
                   └──────────────┘    └───────────────┘    └──────────────┘
```

### Cloud Build Tetikleme

```bash
# Cloud Build tetikleyicisi oluşturun
gcloud builds triggers create github \
    --repo-name=gunluk \
    --repo-owner=YOUR_GITHUB_USERNAME \
    --branch-pattern="^main$" \
    --build-config=cloudbuild.yaml

# Manuel tetikleme
gcloud builds submit --config=cloudbuild.yaml .
```

### Pipeline Adımları

1. **Backend İmaj Build** — `gunluk-backend:$SHORT_SHA` ve `:latest` tag'leri
2. **Frontend İmaj Build** — `gunluk-frontend:$SHORT_SHA` ve `:latest` tag'leri
3. **İmaj Push** — Artifact Registry'ye push
4. **GKE Bağlantı** — Kümeye authentication
5. **Manifest Uygulama** — K8s kaynaklarını güncelle
6. **Deployment Güncelleme** — Yeni imaj versiyonunu set et

---

## 🖥️ API Referansı

### Base URL
```
http://<EXTERNAL-IP>/api
```

### Endpoints

| Metod | Endpoint | Açıklama | Body |
|-------|----------|----------|------|
| `GET` | `/api/posts` | Tüm postları listele | — |
| `POST` | `/api/posts` | Yeni post oluştur | `{ "content": "...", "author": "..." }` |
| `DELETE` | `/api/posts/:id` | Post sil | — |
| `GET` | `/healthz` | Sağlık kontrolü | — |

### Örnek İstekler

```bash
# Postları listele
curl http://localhost:8080/api/posts

# Yeni post oluştur
curl -X POST http://localhost:8080/api/posts \
  -H "Content-Type: application/json" \
  -d '{"content": "TypeScript generics çok güçlüymüş!", "author": "Ahmet"}'

# Post sil
curl -X DELETE http://localhost:8080/api/posts/<POST_ID>

# Sağlık kontrolü
curl http://localhost:8080/healthz
```

---

## 🧪 Lokal Geliştirme

### Backend'i Lokal Çalıştırma

```bash
cd backend
npm install
MONGO_URI=mongodb://localhost:27017/gunluk npm run dev
```

### Frontend'i Lokal Çalıştırma

Frontend statik dosyalardan oluştuğu için herhangi bir HTTP sunucusu ile sunulabilir:

```bash
cd frontend
npx serve .
# veya
python3 -m http.server 8080
```

> **Not:** Lokal geliştirmede API istekleri için `js/app.js` dosyasında `API_URL`'i `http://localhost:3000/api` olarak değiştirin.

---

## 🔐 Güvenlik

- **NetworkPolicy**: Zero-trust modeli — sadece gerekli servisler arası iletişim açık
- **Non-root Container**: Backend container'ı `node` kullanıcısı ile çalışır
- **Resource Limits**: Tüm pod'larda CPU ve bellek limitleri tanımlı
- **Health Probes**: Liveness ve Readiness probe'lar ile otomatik kurtarma
- **Input Validation**: Backend'de içerik uzunluğu doğrulaması (maks. 140 karakter)

---

## 📊 Kaynak Kullanımı

| Bileşen | CPU İstek | CPU Limit | Bellek İstek | Bellek Limit |
|---------|-----------|-----------|--------------|--------------|
| Frontend | 50m | 200m | 64Mi | 128Mi |
| Backend | 100m | 300m | 128Mi | 256Mi |
| MongoDB | 250m | 500m | 256Mi | 512Mi |

---

## 🤝 Katkıda Bulunma

1. Bu depoyu fork edin
2. Feature branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Değişikliklerinizi commit edin (`git commit -m 'Yeni özellik eklendi'`)
4. Branch'i push edin (`git push origin feature/yeni-ozellik`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

---

## 👤 Geliştirici

**Proje**: Bugün Ne Öğrendim? — Günlük Mikro-Blog  
**Kurs**: Kubernetes ve Container Yönetimi  
**Tarih**: 2026
