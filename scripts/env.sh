#!/bin/bash
# ============================================================================
# env.sh - Ortak Ortam Değişkenleri
# ============================================================================
# Tüm deployment scriptleri tarafından kaynak olarak kullanılır.
# Projeye özgü değişkenleri burada tanımlayın.
# ============================================================================

# GCP Proje Ayarları
export PROJECT_ID="bulut-bilisim-498217"    # GCP Proje ID'nizi buraya yazın
export REGION="europe-west1"                # GCP Bölgesi
export ZONE="europe-west1-b"                # GCP Zone

# Kubernetes / GKE Ayarları
export CLUSTER_NAME="gunluk-cluster"        # GKE Küme adı
export NAMESPACE="gunluk"                   # Kubernetes namespace

# Artifact Registry Ayarları
export REPO_NAME="gunluk-repo"              # Artifact Registry repo adı
export REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}"

# Container İmaj Ayarları
export BACKEND_IMAGE="${REGISTRY}/gunluk-backend"
export FRONTEND_IMAGE="${REGISTRY}/gunluk-frontend"
export TAG="latest"                         # İmaj etiketi

# Dizin Yolları
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ============================================================================
# Renk Kodları (Tüm scriptlerde kullanılır)
# ============================================================================
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # Renk sıfırlama

# ============================================================================
# Yardımcı Fonksiyonlar
# ============================================================================

# Başarı mesajı yazdır
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Hata mesajı yazdır
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Bilgi mesajı yazdır
print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Bölüm başlığı yazdır
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

# Hata durumunda çıkış yap
check_error() {
    if [ $? -ne 0 ]; then
        print_error "$1"
        exit 1
    fi
}
