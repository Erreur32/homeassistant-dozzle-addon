#!/bin/bash

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    print_error "Docker n'est pas installé"
    exit 1
fi

# Liste des architectures supportées
ARCHITECTURES=("amd64" "armv7" "aarch64" "armhf" "i386")

# Fonction pour construire une image
build_image() {
    local arch=$1
    local image_name="ghcr.io/erreur32/homeassistant-dozzle-addon/dozzle-${arch}:latest"
    
    print_message "Construction de l'image pour ${arch}..."
    
    if docker build --no-cache --network=host \
        --build-arg BUILD_ARCH="${arch}" \
        -t "${image_name}" .; then
        print_message "Image ${arch} construite avec succès"
        return 0
    else
        print_error "Échec de la construction pour ${arch}"
        return 1
    fi
}

# Fonction pour construire une image locale
build_local_image() {
    local arch=$1
    
    print_message "Construction de l'image locale pour ${arch}..."
    
    if docker build --no-cache --network=host \
        --build-arg BUILD_ARCH="${arch}" \
        -t dozzle-addon .; then
        print_message "Image locale construite avec succès"
        return 0
    else
        print_error "Échec de la construction locale"
        return 1
    fi
}

# Fonction pour pousser une image
push_image() {
    local arch=$1
    local image_name="ghcr.io/erreur32/homeassistant-dozzle-addon/dozzle-${arch}:latest"
    
    print_message "Envoi de l'image ${arch} vers ghcr.io..."
    
    if docker push "${image_name}"; then
        print_message "Image ${arch} envoyée avec succès"
        return 0
    else
        print_error "Échec de l'envoi pour ${arch}"
        return 1
    fi
}

# Menu principal
print_message "Script de construction pour Dozzle Add-on"
print_message "========================================"
echo "1. Construire pour toutes les architectures"
echo "2. Construire pour une architecture spécifique"
echo "3. Construire et pousser pour toutes les architectures"
echo "4. Construire l'image locale (dozzle-addon)"
echo "5. Quitter"
read -p "Choix (1-5): " choice

case $choice in
    1)
        print_message "Construction pour toutes les architectures..."
        for arch in "${ARCHITECTURES[@]}"; do
            build_image "$arch"
        done
        ;;
    2)
        print_message "Architectures disponibles:"
        for i in "${!ARCHITECTURES[@]}"; do
            echo "$((i+1)). ${ARCHITECTURES[$i]}"
        done
        read -p "Choisir une architecture (1-${#ARCHITECTURES[@]}): " arch_choice
        if [ "$arch_choice" -ge 1 ] && [ "$arch_choice" -le "${#ARCHITECTURES[@]}" ]; then
            build_image "${ARCHITECTURES[$((arch_choice-1))]}"
        else
            print_error "Choix invalide"
        fi
        ;;
    3)
        print_message "Construction et envoi pour toutes les architectures..."
        for arch in "${ARCHITECTURES[@]}"; do
            if build_image "$arch"; then
                push_image "$arch"
            fi
        done
        ;;
    4)
        print_message "Construction de l'image locale..."
        build_local_image "amd64"
        ;;
    5)
        print_message "Au revoir!"
        exit 0
        ;;
    *)
        print_error "Choix invalide"
        exit 1
        ;;
esac

print_message "Construction terminée!" 
