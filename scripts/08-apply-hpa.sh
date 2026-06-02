#!/bin/bash
set -e
# ============================================================================
# 08-apply-hpa.sh - Yatay Pod Otomatik Ölçeklendirme (HPA)
# ============================================================================
# Backend ve frontend için HPA kaynaklarını uygular.
# Yük artışında pod sayısını otomatik olarak ölçeklendirir.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "HPA (Otomatik Ölçeklendirme) Uygulanıyor"

K8S_DIR="${PROJECT_ROOT}/k8s"

# Backend HPA uygula
if [ -f "${K8S_DIR}/hpa-backend.yaml" ]; then
    print_info "Backend HPA uygulanıyor..."
    kubectl apply -f "${K8S_DIR}/hpa-backend.yaml" -n "$NAMESPACE"
    check_error "Backend HPA uygulanamadı!"
    print_success "Backend HPA başarıyla uygulandı."
else
    print_error "hpa-backend.yaml dosyası bulunamadı!"
    exit 1
fi

# Frontend HPA uygula
if [ -f "${K8S_DIR}/hpa-frontend.yaml" ]; then
    print_info "Frontend HPA uygulanıyor..."
    kubectl apply -f "${K8S_DIR}/hpa-frontend.yaml" -n "$NAMESPACE"
    check_error "Frontend HPA uygulanamadı!"
    print_success "Frontend HPA başarıyla uygulandı."
else
    print_error "hpa-frontend.yaml dosyası bulunamadı!"
    exit 1
fi

# HPA durumunu göster
print_info "HPA durumu:"
kubectl get hpa -n "$NAMESPACE"

print_success "Tüm HPA kaynakları başarıyla uygulandı!"
