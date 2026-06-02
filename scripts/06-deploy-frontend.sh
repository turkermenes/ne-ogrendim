#!/bin/bash
set -e
# ============================================================================
# 06-deploy-frontend.sh - Frontend Uygulama Dağıtımı
# ============================================================================
# Frontend deployment ve service kaynaklarını uygular.
# İmaj adresini manifest dosyasında günceller.
# Harici IP adresini gösterir.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Frontend Uygulama Dağıtılıyor"

K8S_DIR="${PROJECT_ROOT}/k8s"

# Deployment dosyasındaki imaj adresini güncelle
print_info "Frontend deployment imaj adresi güncelleniyor..."
if [ -f "${K8S_DIR}/frontend-deployment.yaml" ]; then
    # İmaj placeholder'ını gerçek registry adresiyle değiştir
    sed -i "s|image:.*gunluk-frontend.*|image: ${FRONTEND_IMAGE}:${TAG}|g" \
        "${K8S_DIR}/frontend-deployment.yaml"
    check_error "Frontend imaj adresi güncellenemedi!"
    print_info "İmaj adresi: ${FRONTEND_IMAGE}:${TAG}"
else
    print_error "frontend-deployment.yaml dosyası bulunamadı: ${K8S_DIR}/frontend-deployment.yaml"
    exit 1
fi

# Deployment uygula
print_info "Frontend Deployment oluşturuluyor..."
kubectl apply -f "${K8S_DIR}/frontend-deployment.yaml" -n "$NAMESPACE"
check_error "Frontend Deployment oluşturulamadı!"

# Service uygula
print_info "Frontend Service oluşturuluyor..."
kubectl apply -f "${K8S_DIR}/frontend-service.yaml" -n "$NAMESPACE"
check_error "Frontend Service oluşturulamadı!"

# Rollout'un tamamlanmasını bekle
print_info "Frontend rollout'u bekleniyor..."
kubectl rollout status deployment/gunluk-frontend -n "$NAMESPACE" --timeout=120s
check_error "Frontend rollout'u zamanında tamamlanmadı!"

# Durumu göster
print_info "Frontend kaynakları:"
kubectl get pods,svc -l app=gunluk-frontend -n "$NAMESPACE"

# Harici IP adresini göster
print_info "Harici IP adresi alınıyor (LoadBalancer varsa)..."
EXTERNAL_IP=$(kubectl get svc gunluk-frontend -n "$NAMESPACE" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Henüz atanmadı")

if [ -n "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "Henüz atanmadı" ]; then
    print_success "Frontend erişim adresi: http://${EXTERNAL_IP}"
else
    print_info "Harici IP henüz atanmadı. Birkaç dakika sonra tekrar kontrol edin:"
    print_info "  kubectl get svc gunluk-frontend -n $NAMESPACE"
fi

print_success "Frontend uygulaması başarıyla dağıtıldı!"
