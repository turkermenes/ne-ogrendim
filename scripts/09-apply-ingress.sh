#!/bin/bash
set -e
# ============================================================================
# 09-apply-ingress.sh - Ingress Kaynağını Uygulama
# ============================================================================
# Kubernetes Ingress kaynağını uygular.
# Dış dünyadan gelen HTTP trafiğini yönlendirir.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Ingress Kaynağı Uygulanıyor"

K8S_DIR="${PROJECT_ROOT}/k8s"

# Ingress kaynağını uygula
if [ -f "${K8S_DIR}/ingress.yaml" ]; then
    print_info "Ingress kaynağı uygulanıyor..."
    kubectl apply -f "${K8S_DIR}/ingress.yaml" -n "$NAMESPACE"
    check_error "Ingress kaynağı uygulanamadı!"
else
    print_error "ingress.yaml dosyası bulunamadı: ${K8S_DIR}/ingress.yaml"
    exit 1
fi

# Ingress bilgilerini göster
print_info "Ingress bilgileri:"
kubectl get ingress -n "$NAMESPACE"

print_info "Ingress detayları:"
kubectl describe ingress -n "$NAMESPACE" 2>/dev/null || true

# Harici IP adresini göster (varsa)
INGRESS_IP=$(kubectl get ingress -n "$NAMESPACE" \
    -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [ -n "$INGRESS_IP" ]; then
    print_success "Ingress erişim adresi: http://${INGRESS_IP}"
else
    print_info "Ingress IP adresi henüz atanmadı. Birkaç dakika sonra kontrol edin:"
    print_info "  kubectl get ingress -n $NAMESPACE"
fi

print_success "Ingress kaynağı başarıyla uygulandı!"
