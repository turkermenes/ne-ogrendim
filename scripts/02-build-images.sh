#!/bin/bash
set -e
# ============================================================================
# 02-build-images.sh - Container İmajlarını Oluşturma
# ============================================================================
# Backend ve frontend için container imajlarını oluşturur.
# Önce podman, bulamazsa docker kullanır.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Container İmajları Oluşturuluyor"

# Container aracını belirle (podman öncelikli, yoksa docker)
CONTAINER_TOOL=""
if command -v podman &>/dev/null; then
    CONTAINER_TOOL="podman"
    print_info "Podman kullanılacak."
elif command -v docker &>/dev/null; then
    CONTAINER_TOOL="docker"
    print_info "Docker kullanılacak."
else
    print_error "Ne podman ne de docker bulunamadı! Lütfen birini yükleyin."
    exit 1
fi

# Backend imajını oluştur
print_info "Backend imajı oluşturuluyor: ${BACKEND_IMAGE}:${TAG}"
$CONTAINER_TOOL build \
    -t "${BACKEND_IMAGE}:${TAG}" \
    -f "${PROJECT_ROOT}/backend/Dockerfile" \
    "${PROJECT_ROOT}/backend"
check_error "Backend imajı oluşturulamadı!"
print_success "Backend imajı başarıyla oluşturuldu."

# Frontend imajını oluştur
print_info "Frontend imajı oluşturuluyor: ${FRONTEND_IMAGE}:${TAG}"
$CONTAINER_TOOL build \
    -t "${FRONTEND_IMAGE}:${TAG}" \
    -f "${PROJECT_ROOT}/frontend/Dockerfile" \
    "${PROJECT_ROOT}/frontend"
check_error "Frontend imajı oluşturulamadı!"
print_success "Frontend imajı başarıyla oluşturuldu."

# Oluşturulan imajları listele
print_info "Oluşturulan imajlar:"
$CONTAINER_TOOL images | grep -E "gunluk-(backend|frontend)" || true

print_success "Tüm container imajları başarıyla oluşturuldu!"
