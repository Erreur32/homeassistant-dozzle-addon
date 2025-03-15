#!/bin/bash

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${SCRIPT_DIR}/bin"
ERROR_LOG="${SCRIPT_DIR}/build_errors.log"
FAILED_BUILDS=()
SUCCESSFUL_BUILDS=()

# Fonction pour afficher les messages
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$ERROR_LOG"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Fonction pour vérifier si un binaire est valide
check_binary() {
    local binary="$1"
    local arch="$2"
    
    if [ ! -f "$binary" ]; then
        error "Le binaire $binary n'existe pas"
        return 1
    fi
    
    # Vérifier que le binaire est exécutable
    if [ ! -x "$binary" ]; then
        error "Le binaire $binary n'est pas exécutable"
        return 1
    fi
    
    # Vérifier l'architecture du binaire
    file_output=$(file "$binary")
    case $arch in
        "amd64")
            if ! echo "$file_output" | grep -q "x86-64"; then
                error "Le binaire $binary n'est pas un binaire x86-64"
                return 1
            fi
            ;;
        "i386")
            if ! echo "$file_output" | grep -q "Intel 80386"; then
                error "Le binaire $binary n'est pas un binaire i386"
                return 1
            fi
            ;;
        "arm64"|"aarch64")
            if ! echo "$file_output" | grep -q "aarch64"; then
                error "Le binaire $binary n'est pas un binaire ARM64"
                return 1
            fi
            ;;
        "arm"|"armv7"|"armhf")
            if ! echo "$file_output" | grep -q "ARM"; then
                error "Le binaire $binary n'est pas un binaire ARM"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Fonction pour installer protoc
install_protoc() {
    log "Installation de protoc..."
    
    # Détecter le système d'exploitation
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        OS=$(uname -s)
    fi
    
    case $OS in
        "ubuntu"|"debian")
            sudo apt-get update
            sudo apt-get install -y protobuf-compiler
            ;;
        "fedora"|"rhel")
            sudo dnf install -y protobuf-compiler
            ;;
        "arch")
            sudo pacman -S --noconfirm protobuf
            ;;
        "alpine")
            sudo apk add --no-cache protobuf protobuf-dev
            ;;
        *)
            warning "Système non reconnu, installation manuelle de protoc nécessaire"
            warning "Veuillez installer protobuf-compiler manuellement"
            exit 1
            ;;
    esac
    
    # Vérifier l'installation
    if ! command -v protoc &> /dev/null; then
        error "❌ L'installation de protoc a échoué"
        exit 1
    fi
    log "✅ protoc installé avec succès"
}

# Fonction pour vérifier les dépendances
check_dependencies() {
    log "Vérification des dépendances..."
    
    # Liste des dépendances requises
    local deps=("git" "go" "make" "pnpm" "node" "protoc" "file")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            if [ "$dep" = "protoc" ]; then
                warning "⚠️ protoc n'est pas installé, tentative d'installation..."
                install_protoc
            else
                error "❌ $dep n'est pas installé"
                exit 1
            fi
        fi
        log "✅ $dep est installé"
    done
}

# Fonction pour cloner/mettre à jour le repo
setup_repo() {
    local repo_url="https://github.com/amir20/dozzle.git"
    local branch="${1:-master}"
    
    if [ ! -d "dozzle" ]; then
        log "Clonage du repo Dozzle..."
        git clone "$repo_url" dozzle || {
            error "Échec du clonage du repo"
            exit 1
        }
        cd dozzle
    else
        log "Mise à jour du repo Dozzle..."
        cd dozzle
        git fetch origin || {
            error "Échec de la récupération des mises à jour"
            exit 1
        }
        git reset --hard "origin/$branch" || {
            error "Échec du reset à la dernière version"
            exit 1
        }
    fi
    
    # Récupérer la dernière version
    DOZZLE_VERSION=$(git describe --tags --abbrev=0)
    if [ -z "$DOZZLE_VERSION" ]; then
        error "Impossible de déterminer la version de Dozzle"
        exit 1
    fi
    log "Version de Dozzle à compiler: ${DOZZLE_VERSION}"
}

# Fonction pour installer les dépendances
install_dependencies() {
    log "Installation des dépendances Node..."
    pnpm install || {
        error "Échec de l'installation des dépendances Node"
        exit 1
    }
    
    log "Installation des outils Go..."
    make tools || {
        error "Échec de l'installation des outils Go"
        exit 1
    }
}

# Fonction pour gérer le dossier de version
setup_version_dir() {
    local version=$1
    local version_dir="${BIN_DIR}/${version}"
    
    # Afficher le dossier qui va être créé
    log "📁 Dossier de compilation : ${version_dir}"
    
    # Créer le dossier bin s'il n'existe pas
    if [ ! -d "${BIN_DIR}" ]; then
        mkdir -p "${BIN_DIR}" || {
            error "Impossible de créer le dossier bin"
            return 1
        }
    fi
    
    # Vérifier si le dossier version existe déjà
    if [ -d "$version_dir" ]; then
        echo -e "\n${YELLOW}⚠️  ${version_dir} existe déjà${NC}"
        read -p "Écraser ? (o/N) " response
        case "$response" in
            [oO])
                rm -rf "$version_dir" || return 1
                ;;
            *)
                error "Compilation annulée"
                return 1
                ;;
        esac
    fi
    
    # Créer le dossier version
    mkdir -p "$version_dir" || {
        error "Impossible de créer ${version_dir}"
        return 1
    }
    
    echo "$version_dir"
    return 0
}

# Fonction pour compiler Dozzle
build_dozzle() {
    log "Compilation de Dozzle..."
    
    # Créer le dossier de sortie
    local version_dir="${BIN_DIR}/${DOZZLE_VERSION}"
    log "Création du dossier: ${version_dir}"
    
    # Supprimer l'ancien dossier s'il existe
    if [ -d "$version_dir" ]; then
        log "Suppression de l'ancienne version..."
        rm -rf "$version_dir"
    fi
    
    # Créer le nouveau dossier
    mkdir -p "$version_dir"
    
    # Architectures à compiler
    local -a architectures=(
        "amd64:amd64"
        "aarch64:arm64"
        "armv7:arm:7"
        "armhf:arm:6"
    )
    
    # Compiler pour chaque architecture
    for arch_config in "${architectures[@]}"; do
        IFS=':' read -r ha_arch go_arch go_arm <<< "$arch_config"
        log "Compilation pour $ha_arch..."
        
        # Configuration de l'environnement
        export GOOS=linux
        export GOARCH=$go_arch
        export CGO_ENABLED=0
        
        # Configuration spécifique
        if [ "$ha_arch" = "i386" ]; then
            export CGO_ENABLED=1
        fi
        
        if [ -n "$go_arm" ]; then
            export GOARM=$go_arm
        fi
        
        # Compilation
        if go build -ldflags "-s -w -X github.com/amir20/dozzle/internal/support/cli.Version=${DOZZLE_VERSION}" -o "${version_dir}/dozzle-${ha_arch}"; then
            chmod +x "${version_dir}/dozzle-${ha_arch}"
            log "✅ Compilation réussie pour $ha_arch"
            SUCCESSFUL_BUILDS+=("$ha_arch")
        else
            error "❌ Échec de la compilation pour $ha_arch"
            FAILED_BUILDS+=("$ha_arch")
        fi
        
        # Nettoyage
        unset GOARCH GOARM CGO_ENABLED
    done
    
    # Créer le lien latest si tout est ok
    if [ ${#FAILED_BUILDS[@]} -eq 0 ]; then
        rm -f "${BIN_DIR}/latest"
        ln -sf "${DOZZLE_VERSION}" "${BIN_DIR}/latest"
    fi
}

# Fonction pour afficher le résumé
show_summary() {
    echo ""
    log "📊 Résumé de la compilation :"
    echo "----------------------------------------"
    
    if [ ${#SUCCESSFUL_BUILDS[@]} -gt 0 ]; then
        echo -e "${GREEN}✅ Compilations réussies :${NC}"
        for arch in "${SUCCESSFUL_BUILDS[@]}"; do
            echo "   - $arch"
        done
    fi
    
    if [ ${#FAILED_BUILDS[@]} -gt 0 ]; then
        echo -e "${RED}❌ Compilations échouées :${NC}"
        for arch in "${FAILED_BUILDS[@]}"; do
            echo "   - $arch"
        done
        echo "Consultez $ERROR_LOG pour plus de détails"
        return 1
    fi
    
    # Afficher l'emplacement des binaires
    echo ""
    log "📁 Binaires disponibles dans : ${BIN_DIR}/${DOZZLE_VERSION}/"
    log "🔗 Lien vers la dernière version : ${BIN_DIR}/latest/"
    
    return 0
}

# Fonction pour nettoyer
cleanup() {
    log "Nettoyage..."
    cd ..
    if [ ${#FAILED_BUILDS[@]} -eq 0 ]; then
        rm -rf dozzle
        rm -f "$ERROR_LOG"
    fi
}

# Fonction principale
main() {
    # Initialiser le fichier de log
    > "$ERROR_LOG"
    
    log "🚀 Début de la compilation de Dozzle"
    
    # Vérifier les dépendances
    check_dependencies
    
    # Configurer le repo
    setup_repo "$@"
    
    # Installer les dépendances
    install_dependencies
    
    # Compiler
    build_dozzle
    
    # Afficher le résumé
    show_summary
    build_status=$?
    
    # Nettoyer
    cleanup
    
    if [ $build_status -eq 0 ]; then
        log "✨ Compilation terminée avec succès!"
        log "Les binaires sont disponibles dans : ${BIN_DIR}/${DOZZLE_VERSION}/"
    else
        error "⚠️ La compilation a rencontré des erreurs"
        exit 1
    fi
}

# Exécuter le script
main "$@" 