#!/bin/bash
set -e
# ============================================================================
# 17-cleanup-all.sh - Tüm Kaynakları Temizleme
# ============================================================================
# Günlük uygulamasına ait tüm Kubernetes kaynaklarını siler.
# Silmeden önce kullanıcıdan onay ister.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "⚠️  Tüm Kaynakları Temizleme"

K8S_DIR="${PROJECT_ROOT}/k8s"

# Kullanıcıdan onay al
echo ""
print_error "DİKKAT: Bu işlem '${NAMESPACE}' namespace'indeki TÜM kaynakları silecek!"
print_info "Bu işlem geri alınamaz."
echo ""
read -p "Devam etmek istiyor musunuz? (evet/hayır): " CONFIRM

if [ "$CONFIRM" != "evet" ]; then
    print_info "İşlem iptal edildi."
    exit 0
fi

echo ""
print_info "Temizleme işlemi başlıyor..."

# 1. Ingress sil
print_info "[1/7] Ingress siliniyor..."
kubectl delete ingress --all -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → Ingress bulunamadı, atlanıyor."

# 2. HPA'ları sil
print_info "[2/7] HPA'lar siliniyor..."
kubectl delete hpa --all -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → HPA bulunamadı, atlanıyor."

# 3. Ağ politikalarını sil
print_info "[3/7] Ağ politikaları siliniyor..."
kubectl delete networkpolicy --all -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → NetworkPolicy bulunamadı, atlanıyor."

# 4. Frontend deployment ve service sil
print_info "[4/7] Frontend kaynakları siliniyor..."
kubectl delete deployment gunluk-frontend -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → Frontend deployment bulunamadı."
kubectl delete service gunluk-frontend -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → Frontend service bulunamadı."

# 5. Backend deployment ve service sil
print_info "[5/7] Backend kaynakları siliniyor..."
kubectl delete deployment gunluk-backend -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → Backend deployment bulunamadı."
kubectl delete service gunluk-backend -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → Backend service bulunamadı."

# 6. MongoDB kaynakları sil
print_info "[6/7] MongoDB kaynakları siliniyor..."
kubectl delete deployment mongo -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → MongoDB deployment bulunamadı."
kubectl delete service mongo -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → MongoDB service bulunamadı."
kubectl delete pvc --all -n "$NAMESPACE" 2>/dev/null || \
    print_info "  → PVC bulunamadı."
kubectl delete pv --all 2>/dev/null || \
    print_info "  → PV bulunamadı."

# 7. Namespace sil
print_info "[7/7] Namespace siliniyor..."
kubectl delete namespace "$NAMESPACE" 2>/dev/null || \
    print_info "  → Namespace bulunamadı."

echo ""
print_success "🧹 Tüm kaynaklar başarıyla temizlendi!"
print_info "Namespace '$NAMESPACE' ve içindeki tüm kaynaklar silindi."
