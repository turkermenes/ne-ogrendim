#!/bin/bash
set -e
# ============================================================================
# 16-deploy-all.sh - Tam Dağıtım (Tüm Bileşenler)
# ============================================================================
# Scriptleri 01'den 09'a kadar sırasıyla çalıştırarak
# tüm uygulamayı baştan sona dağıtır.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "🚀 Günlük Uygulaması - Tam Dağıtım Başlıyor"

START_TIME=$(date +%s)

# Adım fonksiyonu - her script'i çalıştır ve sonucu kontrol et
run_step() {
    local step_number="$1"
    local step_script="$2"
    local step_description="$3"

    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  Adım ${step_number}: ${step_description}${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -f "${SCRIPT_DIR}/${step_script}" ]; then
        bash "${SCRIPT_DIR}/${step_script}"
        if [ $? -ne 0 ]; then
            print_error "Adım ${step_number} başarısız oldu: ${step_description}"
            print_error "Dağıtım iptal edildi!"
            exit 1
        fi
        print_success "Adım ${step_number} tamamlandı: ${step_description}"
    else
        print_error "Script bulunamadı: ${step_script}"
        exit 1
    fi
}

# Tüm adımları sırayla çalıştır
run_step "1/9" "01-create-namespace.sh"       "Namespace Oluşturma"
run_step "2/9" "02-build-images.sh"           "Container İmajları Oluşturma"
run_step "3/9" "03-push-images.sh"            "İmajları Registry'ye Gönderme"
run_step "4/9" "04-deploy-mongo.sh"           "MongoDB Dağıtımı"
run_step "5/9" "05-deploy-backend.sh"         "Backend Dağıtımı"
run_step "6/9" "06-deploy-frontend.sh"        "Frontend Dağıtımı"
run_step "7/9" "07-apply-network-policies.sh" "Ağ Politikaları"
run_step "8/9" "08-apply-hpa.sh"              "Otomatik Ölçeklendirme (HPA)"
run_step "9/9" "09-apply-ingress.sh"          "Ingress Yapılandırması"

# Süre hesapla
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

# Genel durumu göster
echo ""
print_header "🎉 Dağıtım Tamamlandı!"
echo ""
print_success "Tüm bileşenler başarıyla dağıtıldı!"
print_info "Toplam süre: ${MINUTES} dakika ${SECONDS} saniye"
echo ""

# Harici IP adresini göster
print_info "Servis bilgileri:"
kubectl get svc -n "$NAMESPACE"
echo ""

EXTERNAL_IP=$(kubectl get svc gunluk-frontend -n "$NAMESPACE" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [ -n "$EXTERNAL_IP" ]; then
    echo -e "${GREEN}🌐 Uygulama erişim adresi: http://${EXTERNAL_IP}${NC}"
else
    print_info "Harici IP henüz atanmadı. Kontrol için:"
    print_info "  kubectl get svc gunluk-frontend -n $NAMESPACE"
fi

echo ""
print_info "Durum kontrolü için: ./10-check-status.sh"
print_info "Loglar için:         ./14-view-logs.sh <backend|frontend|mongo>"
print_info "Port yönlendirme:    ./15-port-forward.sh"
