#!/bin/bash
set -e
# ============================================================================
# 07-apply-network-policies.sh - Ağ Politikalarını Uygulama
# ============================================================================
# Kubernetes NetworkPolicy kaynaklarını uygular.
# Pod'lar arası ağ trafiğini kontrol eder.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Ağ Politikaları Uygulanıyor"

K8S_DIR="${PROJECT_ROOT}/k8s"

# Network Policy dosyasını uygula
if [ -f "${K8S_DIR}/network-policy.yaml" ]; then
    print_info "Ağ politikaları uygulanıyor..."
    kubectl apply -f "${K8S_DIR}/network-policy.yaml" -n "$NAMESPACE"
    check_error "Ağ politikaları uygulanamadı!"
else
    print_error "network-policy.yaml dosyası bulunamadı: ${K8S_DIR}/network-policy.yaml"
    exit 1
fi

# Uygulanan politikaları listele
print_info "Uygulanan ağ politikaları:"
kubectl get networkpolicy -n "$NAMESPACE"

print_success "Ağ politikaları başarıyla uygulandı!"
