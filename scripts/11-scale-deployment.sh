#!/bin/bash
set -e
# ============================================================================
# 11-scale-deployment.sh - Deployment Ölçeklendirme
# ============================================================================
# Belirtilen deployment'ın replika sayısını değiştirir.
# Kullanım: ./11-scale-deployment.sh <deployment-adı> <replika-sayısı>
# Örnek:    ./11-scale-deployment.sh gunluk-backend 3
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

# Parametre kontrolü
if [ $# -ne 2 ]; then
    print_error "Kullanım: $0 <deployment-adı> <replika-sayısı>"
    print_info "Örnek: $0 gunluk-backend 3"
    print_info "Örnek: $0 gunluk-frontend 5"
    exit 1
fi

DEPLOYMENT_NAME="$1"
REPLICAS="$2"

# Replika sayısının sayısal değer olup olmadığını kontrol et
if ! [[ "$REPLICAS" =~ ^[0-9]+$ ]]; then
    print_error "Replika sayısı pozitif bir sayı olmalıdır: $REPLICAS"
    exit 1
fi

print_header "Deployment Ölçeklendirme"

# Deployment'ın var olup olmadığını kontrol et
if ! kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" &>/dev/null; then
    print_error "Deployment bulunamadı: $DEPLOYMENT_NAME (namespace: $NAMESPACE)"
    print_info "Mevcut deployment'lar:"
    kubectl get deployments -n "$NAMESPACE" 2>/dev/null || true
    exit 1
fi

# Mevcut replika sayısını göster
CURRENT_REPLICAS=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.spec.replicas}')
print_info "Mevcut replika sayısı: $CURRENT_REPLICAS"
print_info "Hedef replika sayısı: $REPLICAS"

# Ölçeklendirme işlemini gerçekleştir
print_info "'$DEPLOYMENT_NAME' deployment'ı $REPLICAS replika'ya ölçeklendiriliyor..."
kubectl scale deployment "$DEPLOYMENT_NAME" \
    --replicas="$REPLICAS" \
    -n "$NAMESPACE"
check_error "Ölçeklendirme başarısız oldu!"

# Sonucu göster
print_info "Güncel durum:"
kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"

print_success "'$DEPLOYMENT_NAME' başarıyla $REPLICAS replika'ya ölçeklendirildi!"
