#!/bin/bash
set -e
# ============================================================================
# 01-create-namespace.sh - Kubernetes Namespace Oluşturma
# ============================================================================
# Günlük uygulaması için Kubernetes namespace oluşturur ve etiketler.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Kubernetes Namespace Oluşturuluyor"

# Namespace zaten var mı kontrol et
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    print_info "Namespace '$NAMESPACE' zaten mevcut, atlanıyor."
else
    # Namespace oluştur
    print_info "Namespace '$NAMESPACE' oluşturuluyor..."
    kubectl create namespace "$NAMESPACE"
    check_error "Namespace oluşturulamadı!"
fi

# Namespace'i etiketle
print_info "Namespace etiketleniyor..."
kubectl label namespace "$NAMESPACE" \
    app=gunluk \
    environment=production \
    managed-by=scripts \
    --overwrite
check_error "Namespace etiketlenemedi!"

# Sonucu göster
print_info "Namespace bilgileri:"
kubectl get namespace "$NAMESPACE" --show-labels

print_success "Namespace '$NAMESPACE' başarıyla oluşturuldu ve etiketlendi!"
