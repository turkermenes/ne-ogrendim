#!/bin/bash
set -e
# ============================================================================
# 14-view-logs.sh - Pod Loglarını Görüntüleme
# ============================================================================
# Belirtilen bileşenin pod loglarını gösterir.
# Kullanım: ./14-view-logs.sh <backend|frontend|mongo> [-f]
# -f bayrağı ile canlı log takibi yapılabilir.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

# Parametre kontrolü
if [ $# -lt 1 ]; then
    print_error "Kullanım: $0 <backend|frontend|mongo> [-f]"
    print_info "Örnek: $0 backend"
    print_info "Örnek: $0 frontend -f  (canlı takip)"
    print_info "Örnek: $0 mongo"
    exit 1
fi

COMPONENT="$1"
FOLLOW_FLAG=""

# -f bayrağını kontrol et
if [ "${2}" == "-f" ]; then
    FOLLOW_FLAG="-f"
    print_info "Canlı log takibi etkin (çıkmak için Ctrl+C)"
fi

# Bileşene göre etiket seçici belirle
case "$COMPONENT" in
    backend)
        LABEL_SELECTOR="app=gunluk-backend"
        ;;
    frontend)
        LABEL_SELECTOR="app=gunluk-frontend"
        ;;
    mongo)
        LABEL_SELECTOR="app=mongo"
        ;;
    *)
        print_error "Geçersiz bileşen: $COMPONENT"
        print_info "Geçerli bileşenler: backend, frontend, mongo"
        exit 1
        ;;
esac

print_header "'$COMPONENT' Logları"

# Pod'ların var olup olmadığını kontrol et
POD_COUNT=$(kubectl get pods -l "$LABEL_SELECTOR" -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
if [ "$POD_COUNT" -eq 0 ]; then
    print_error "'$COMPONENT' için çalışan pod bulunamadı."
    print_info "Pod durumunu kontrol edin: kubectl get pods -n $NAMESPACE"
    exit 1
fi

print_info "Pod sayısı: $POD_COUNT"
print_info "Etiket seçici: $LABEL_SELECTOR"
echo ""

# Logları göster (tüm pod'lardan)
kubectl logs -l "$LABEL_SELECTOR" \
    -n "$NAMESPACE" \
    --all-containers=true \
    --tail=100 \
    $FOLLOW_FLAG
