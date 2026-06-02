#!/bin/bash
set -e
# ============================================================================
# 03-push-images.sh - Container İmajlarını Registry'ye Gönderme
# ============================================================================
# Backend ve frontend imajlarını Google Artifact Registry'ye push eder.
# ============================================================================

# Ortam değişkenlerini yükle
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

print_header "Container İmajları Registry'ye Gönderiliyor"

# Container aracını belirle
CONTAINER_TOOL=""
if command -v podman &>/dev/null; then
    CONTAINER_TOOL="podman"
elif command -v docker &>/dev/null; then
    CONTAINER_TOOL="docker"
else
    print_error "Ne podman ne de docker bulunamadı!"
    exit 1
fi

if [ "$CONTAINER_TOOL" = "podman" ]; then
    print_info "Podman kullanılarak imajlar gönderiliyor (inline credentials ile)..."
    
    # Token'ı bir kez al
    TOKEN=$(gcloud auth print-access-token)
    
    # Backend imajını push et
    print_info "Backend imajı gönderiliyor: ${BACKEND_IMAGE}:${TAG}"
    podman push --creds=oauth2accesstoken:"$TOKEN" "${BACKEND_IMAGE}:${TAG}"
    check_error "Backend imajı gönderilemedi!"
    print_success "Backend imajı başarıyla gönderildi."

    # Frontend imajını push et
    print_info "Frontend imajı gönderiliyor: ${FRONTEND_IMAGE}:${TAG}"
    podman push --creds=oauth2accesstoken:"$TOKEN" "${FRONTEND_IMAGE}:${TAG}"
    check_error "Frontend imajı gönderilemedi!"
    print_success "Frontend imajı başarıyla gönderildi."

else
    # Docker için
    print_info "Docker kullanılarak Artifact Registry kimlik doğrulaması yapılıyor..."
    gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet
    check_error "Docker ile Artifact Registry kimlik doğrulaması yapılamadı!"
    
    print_info "Backend imajı gönderiliyor: ${BACKEND_IMAGE}:${TAG}"
    docker push "${BACKEND_IMAGE}:${TAG}"
    check_error "Backend imajı gönderilemedi!"
    print_success "Backend imajı başarıyla gönderildi."

    print_info "Frontend imajı gönderiliyor: ${FRONTEND_IMAGE}:${TAG}"
    docker push "${FRONTEND_IMAGE}:${TAG}"
    check_error "Frontend imajı gönderilemedi!"
    print_success "Frontend imajı başarıyla gönderildi."
fi

print_success "Tüm imajlar Artifact Registry'ye başarıyla gönderildi!"
print_info "Registry: ${REGISTRY}"
