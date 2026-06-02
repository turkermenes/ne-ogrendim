#!/bin/bash
set -e
# ============================================================================
# 04-deploy-mongo.sh - MongoDB Veritabanı Dağıtımı
# ============================================================================
# MongoDB için PV, PVC, Deployment ve Service kaynaklarını uygular.
# Pod'un hazır olmasını bekler.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "MongoDB Veritabanı Dağıtılıyor"

K8S_DIR="${PROJECT_ROOT}/k8s"

# PersistentVolume (GKE'de dynamic provisioning kullanıldığı için iptal edildi)
# print_info "MongoDB PersistentVolume oluşturuluyor..."
# kubectl apply -f "${K8S_DIR}/mongo-pv.yaml" -n "$NAMESPACE"
# check_error "MongoDB PV oluşturulamadı!"

# PersistentVolumeClaim uygula
print_info "MongoDB PersistentVolumeClaim oluşturuluyor..."
kubectl apply -f "${K8S_DIR}/mongo-pvc.yaml" -n "$NAMESPACE"
check_error "MongoDB PVC oluşturulamadı!"

# Deployment uygula
print_info "MongoDB Deployment oluşturuluyor..."
kubectl apply -f "${K8S_DIR}/mongo-deployment.yaml" -n "$NAMESPACE"
check_error "MongoDB Deployment oluşturulamadı!"

# Service uygula
print_info "MongoDB Service oluşturuluyor..."
kubectl apply -f "${K8S_DIR}/mongo-service.yaml" -n "$NAMESPACE"
check_error "MongoDB Service oluşturulamadı!"

# Pod'un hazır olmasını bekle
print_info "MongoDB pod'unun hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod \
    -l component=database \
    -n "$NAMESPACE" \
    --timeout=120s
check_error "MongoDB pod'u zamanında hazır olmadı!"

# Durumu göster
print_info "MongoDB kaynakları:"
kubectl get pods,svc,pv,pvc -l component=database -n "$NAMESPACE" 2>/dev/null || \
    kubectl get pods,svc -n "$NAMESPACE" | grep -i mongo

print_success "MongoDB veritabanı başarıyla dağıtıldı!"
