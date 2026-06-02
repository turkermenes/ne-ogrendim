#!/bin/bash
set -e
# ============================================================================
# 05-deploy-backend.sh - Backend Uygulama Dağıtımı
# ============================================================================
# Backend deployment ve service kaynaklarını uygular.
# İmaj adresini manifest dosyasında günceller.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Backend Uygulama Dağıtılıyor"

K8S_DIR="${PROJECT_ROOT}/k8s"

# Deployment dosyasındaki imaj adresini güncelle
print_info "Backend deployment imaj adresi güncelleniyor..."
if [ -f "${K8S_DIR}/backend-deployment.yaml" ]; then
    # İmaj placeholder'ını gerçek registry adresiyle değiştir
    sed -i "s|image:.*gunluk-backend.*|image: ${BACKEND_IMAGE}:${TAG}|g" \
        "${K8S_DIR}/backend-deployment.yaml"
    check_error "Backend imaj adresi güncellenemedi!"
    print_info "İmaj adresi: ${BACKEND_IMAGE}:${TAG}"
else
    print_error "backend-deployment.yaml dosyası bulunamadı: ${K8S_DIR}/backend-deployment.yaml"
    exit 1
fi

# Deployment uygula
print_info "Backend Deployment oluşturuluyor..."
kubectl apply -f "${K8S_DIR}/backend-deployment.yaml" -n "$NAMESPACE"
check_error "Backend Deployment oluşturulamadı!"

# Service uygula
print_info "Backend Service oluşturuluyor..."
kubectl apply -f "${K8S_DIR}/backend-service.yaml" -n "$NAMESPACE"
check_error "Backend Service oluşturulamadı!"

# Rollout'un tamamlanmasını bekle
print_info "Backend rollout'u bekleniyor..."
kubectl rollout status deployment/gunluk-backend -n "$NAMESPACE" --timeout=120s
check_error "Backend rollout'u zamanında tamamlanmadı!"

# Durumu göster
print_info "Backend kaynakları:"
kubectl get pods,svc -l app=gunluk-backend -n "$NAMESPACE"

print_success "Backend uygulaması başarıyla dağıtıldı!"
