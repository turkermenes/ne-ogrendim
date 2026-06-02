#!/bin/bash
set -e
# ============================================================================
# 13-rollback.sh - Önceki Sürüme Geri Alma (Rollback)
# ============================================================================
# Backend veya frontend bileşenini önceki sürüme geri alır.
# Kullanım: ./13-rollback.sh <backend|frontend>
# Örnek:    ./13-rollback.sh backend
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

# Parametre kontrolü
if [ $# -ne 1 ]; then
    print_error "Kullanım: $0 <backend|frontend>"
    print_info "Örnek: $0 backend"
    print_info "Örnek: $0 frontend"
    exit 1
fi

COMPONENT="$1"

# Bileşen adını doğrula
case "$COMPONENT" in
    backend)
        DEPLOYMENT_NAME="gunluk-backend"
        ;;
    frontend)
        DEPLOYMENT_NAME="gunluk-frontend"
        ;;
    *)
        print_error "Geçersiz bileşen: $COMPONENT"
        print_info "Geçerli bileşenler: backend, frontend"
        exit 1
        ;;
esac

print_header "Geri Alma İşlemi (Rollback)"

# Mevcut rollout geçmişini göster
print_info "'$DEPLOYMENT_NAME' rollout geçmişi:"
kubectl rollout history deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE"
echo ""

# Geri alma işlemini gerçekleştir
print_info "'$DEPLOYMENT_NAME' önceki sürüme geri alınıyor..."
kubectl rollout undo deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE"
check_error "Geri alma işlemi başarısız oldu!"

# Rollout durumunu takip et
print_info "Rollout durumu izleniyor..."
kubectl rollout status deployment/"$DEPLOYMENT_NAME" \
    -n "$NAMESPACE" \
    --timeout=180s
check_error "Rollout zamanında tamamlanmadı!"

# Güncel rollout geçmişini göster
print_info "Güncellenmiş rollout geçmişi:"
kubectl rollout history deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE"

# Sonucu göster
print_info "Geri alma sonrası pod durumu:"
kubectl get pods -l app="$DEPLOYMENT_NAME" -n "$NAMESPACE"

print_success "'$DEPLOYMENT_NAME' başarıyla önceki sürüme geri alındı!"
