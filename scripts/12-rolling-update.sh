#!/bin/bash
set -e
# ============================================================================
# 12-rolling-update.sh - Sıralı Güncelleme (Rolling Update)
# ============================================================================
# Backend veya frontend bileşenini yeni bir imaj etiketi ile günceller.
# Kullanım: ./12-rolling-update.sh <backend|frontend> <yeni-etiket>
# Örnek:    ./12-rolling-update.sh backend v1.2.0
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

# Parametre kontrolü
if [ $# -ne 2 ]; then
    print_error "Kullanım: $0 <backend|frontend> <yeni-etiket>"
    print_info "Örnek: $0 backend v1.2.0"
    print_info "Örnek: $0 frontend v2.0.1"
    exit 1
fi

COMPONENT="$1"
NEW_TAG="$2"

# Bileşen adını doğrula
case "$COMPONENT" in
    backend)
        DEPLOYMENT_NAME="gunluk-backend"
        IMAGE="${BACKEND_IMAGE}:${NEW_TAG}"
        CONTAINER_NAME="gunluk-backend"
        ;;
    frontend)
        DEPLOYMENT_NAME="gunluk-frontend"
        IMAGE="${FRONTEND_IMAGE}:${NEW_TAG}"
        CONTAINER_NAME="gunluk-frontend"
        ;;
    *)
        print_error "Geçersiz bileşen: $COMPONENT"
        print_info "Geçerli bileşenler: backend, frontend"
        exit 1
        ;;
esac

print_header "Sıralı Güncelleme (Rolling Update)"

# Mevcut imaj bilgisini göster
CURRENT_IMAGE=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" \
    -o jsonpath="{.spec.template.spec.containers[0].image}" 2>/dev/null || echo "Bilinmiyor")
print_info "Mevcut imaj: $CURRENT_IMAGE"
print_info "Yeni imaj:   $IMAGE"

# İmajı güncelle
print_info "'$DEPLOYMENT_NAME' güncelleniyor..."
kubectl set image deployment/"$DEPLOYMENT_NAME" \
    "$CONTAINER_NAME=$IMAGE" \
    -n "$NAMESPACE"
check_error "İmaj güncellemesi başarısız oldu!"

# Rollout durumunu takip et
print_info "Rollout durumu izleniyor..."
kubectl rollout status deployment/"$DEPLOYMENT_NAME" \
    -n "$NAMESPACE" \
    --timeout=180s
check_error "Rollout zamanında tamamlanmadı!"

# Sonucu göster
print_info "Güncelleme sonrası durum:"
kubectl get pods -l app="$DEPLOYMENT_NAME" -n "$NAMESPACE"

print_success "'$DEPLOYMENT_NAME' başarıyla '$NEW_TAG' sürümüne güncellendi!"
