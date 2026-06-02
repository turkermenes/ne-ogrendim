#!/bin/bash
set -e
# ============================================================================
# 10-check-status.sh - Küme Durumu Kontrolü
# ============================================================================
# Tüm Kubernetes kaynaklarının durumunu renkli çıktıyla gösterir.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Günlük Uygulaması - Küme Durum Raporu"
echo ""

# Namespace durumu
echo -e "${BLUE}━━━ NAMESPACE ━━━${NC}"
kubectl get namespaces | grep -E "NAME|${NAMESPACE}" || print_info "Namespace bulunamadı."
echo ""

# Deployment durumu
echo -e "${BLUE}━━━ DEPLOYMENT'LAR ━━━${NC}"
kubectl get deployments -n "$NAMESPACE" 2>/dev/null || print_info "Deployment bulunamadı."
echo ""

# Pod durumu
echo -e "${BLUE}━━━ POD'LAR ━━━${NC}"
kubectl get pods -n "$NAMESPACE" -o wide 2>/dev/null || print_info "Pod bulunamadı."
echo ""

# Service durumu
echo -e "${BLUE}━━━ SERVİS'LER ━━━${NC}"
kubectl get services -n "$NAMESPACE" 2>/dev/null || print_info "Service bulunamadı."
echo ""

# PV ve PVC durumu
echo -e "${BLUE}━━━ PERSISTENT VOLUME / CLAIM ━━━${NC}"
kubectl get pv,pvc -n "$NAMESPACE" 2>/dev/null || print_info "PV/PVC bulunamadı."
echo ""

# HPA durumu
echo -e "${BLUE}━━━ HPA (Otomatik Ölçeklendirme) ━━━${NC}"
kubectl get hpa -n "$NAMESPACE" 2>/dev/null || print_info "HPA bulunamadı."
echo ""

# Network Policy durumu
echo -e "${BLUE}━━━ AĞ POLİTİKALARI ━━━${NC}"
kubectl get networkpolicy -n "$NAMESPACE" 2>/dev/null || print_info "NetworkPolicy bulunamadı."
echo ""

# Ingress durumu
echo -e "${BLUE}━━━ INGRESS ━━━${NC}"
kubectl get ingress -n "$NAMESPACE" 2>/dev/null || print_info "Ingress bulunamadı."
echo ""

print_success "Durum raporu tamamlandı!"
