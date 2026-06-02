#!/bin/bash
set -e
# ============================================================================
# 15-port-forward.sh - Port Yönlendirme
# ============================================================================
# Frontend ve backend servislerini yerel bilgisayara yönlendirir.
# Frontend: localhost:8080
# Backend:  localhost:3000
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Port Yönlendirme Başlatılıyor"

# Önceki port-forward işlemlerini temizle
print_info "Önceki port-forward işlemleri temizleniyor..."
pkill -f "kubectl port-forward.*gunluk" 2>/dev/null || true
sleep 1

# Backend port-forward (arka planda)
print_info "Backend port yönlendirmesi başlatılıyor (localhost:3000)..."
kubectl port-forward svc/gunluk-backend 3000:3000 -n "$NAMESPACE" &
BACKEND_PID=$!
check_error "Backend port yönlendirmesi başlatılamadı!"

# Frontend port-forward (arka planda)
print_info "Frontend port yönlendirmesi başlatılıyor (localhost:8080)..."
kubectl port-forward svc/gunluk-frontend 8080:80 -n "$NAMESPACE" &
FRONTEND_PID=$!
check_error "Frontend port yönlendirmesi başlatılamadı!"

# Kısa bir bekleme ile bağlantıların kurulmasını sağla
sleep 2

# Erişim bilgilerini göster
echo ""
print_success "Port yönlendirme aktif!"
echo ""
print_info "Erişim adresleri:"
echo -e "  ${GREEN}Frontend:${NC} http://localhost:8080"
echo -e "  ${GREEN}Backend:${NC}  http://localhost:3000"
echo ""
print_info "Durdurmak için Ctrl+C tuşlarına basın veya:"
print_info "  kill $BACKEND_PID $FRONTEND_PID"
echo ""

# Ctrl+C ile temiz çıkış
cleanup() {
    echo ""
    print_info "Port yönlendirme durduruluyor..."
    kill $BACKEND_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    print_success "Port yönlendirme durduruldu."
    exit 0
}
trap cleanup INT TERM

# Arka plan işlemleri bitene kadar bekle
wait
