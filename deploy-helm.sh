#!/bin/bash

# Script de déploiement Travelo avec Helm
# Usage: ./deploy-helm.sh [install|upgrade|uninstall|status]

set -e

RELEASE_NAME="travelo"
NAMESPACE="helm"
CHART_PATH="./helm-charts/travelo"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier les prérequis
check_prerequisites() {
    print_info "Vérification des prérequis..."
    
    if ! command -v helm &> /dev/null; then
        print_error "Helm n'est pas installé. Installez-le depuis https://helm.sh/docs/intro/install/"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl n'est pas installé."
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Impossible de se connecter au cluster Kubernetes."
        exit 1
    fi
    
    print_success "Prérequis OK"
}

# Installer l'application
install_app() {
    print_info "Installation de Travelo dans le namespace '$NAMESPACE'..."
    
    if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
        print_warning "La release '$RELEASE_NAME' existe déjà. Utilisez 'upgrade' pour mettre à jour."
        exit 1
    fi
    
    helm install $RELEASE_NAME $CHART_PATH \
        --namespace $NAMESPACE \
        --create-namespace \
        --wait \
        --timeout 10m
    
    print_success "Installation terminée !"
    show_access_info
}

# Mettre à jour l'application
upgrade_app() {
    print_info "Mise à jour de Travelo..."
    
    if ! helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
        print_error "La release '$RELEASE_NAME' n'existe pas. Utilisez 'install' d'abord."
        exit 1
    fi
    
    helm upgrade $RELEASE_NAME $CHART_PATH \
        --namespace $NAMESPACE \
        --wait \
        --timeout 10m
    
    print_success "Mise à jour terminée !"
    show_status
}

# Désinstaller l'application
uninstall_app() {
    print_warning "Désinstallation de Travelo..."
    
    if ! helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
        print_warning "La release '$RELEASE_NAME' n'existe pas."
        exit 0
    fi
    
    read -p "Êtes-vous sûr de vouloir désinstaller ? (oui/non): " confirm
    if [ "$confirm" != "oui" ]; then
        print_info "Désinstallation annulée."
        exit 0
    fi
    
    helm uninstall $RELEASE_NAME -n $NAMESPACE
    
    read -p "Supprimer le namespace '$NAMESPACE' ? (oui/non): " del_ns
    if [ "$del_ns" == "oui" ]; then
        kubectl delete namespace $NAMESPACE
        print_success "Namespace supprimé."
    fi
    
    print_success "Désinstallation terminée !"
}

# Afficher le statut
show_status() {
    print_info "Statut du déploiement:"
    echo ""
    
    echo "📦 Release Helm:"
    helm list -n $NAMESPACE
    echo ""
    
    echo "🔄 Pods:"
    kubectl get pods -n $NAMESPACE
    echo ""
    
    echo "🌐 Services:"
    kubectl get svc -n $NAMESPACE
    echo ""
    
    echo "💾 Volumes:"
    kubectl get pvc -n $NAMESPACE
}

# Afficher les informations d'accès
show_access_info() {
    echo ""
    print_success "Application déployée avec succès !"
    echo ""
    print_info "Pour accéder à l'application:"
    echo ""
    echo "Option 1 - Port-forward (recommandé pour test local):"
    echo "  kubectl port-forward -n $NAMESPACE svc/travelo-proxy 8080:80"
    echo "  Puis ouvrir: http://localhost:8080"
    echo ""
    echo "Option 2 - LoadBalancer (si disponible):"
    echo "  SERVICE_IP=\$(kubectl get svc -n $NAMESPACE travelo-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
    echo "  echo \"http://\$SERVICE_IP\""
    echo ""
    print_info "Pour voir les logs:"
    echo "  kubectl logs -n $NAMESPACE -l app.kubernetes.io/component=backend --tail=50"
    echo "  kubectl logs -n $NAMESPACE -l app.kubernetes.io/component=frontend --tail=50"
}

# Afficher l'aide
show_help() {
    cat << EOF
🚀 Script de déploiement Travelo avec Helm

Usage: $0 [COMMAND]

Commands:
  install     Installer l'application Travelo
  upgrade     Mettre à jour l'application
  uninstall   Désinstaller l'application
  status      Afficher le statut du déploiement
  logs        Afficher les logs
  help        Afficher ce message

Examples:
  $0 install          # Installer l'application
  $0 status           # Voir le statut
  $0 upgrade          # Mettre à jour
  $0 uninstall        # Désinstaller

EOF
}

# Afficher les logs
show_logs() {
    print_info "Logs de l'application:"
    echo ""
    
    PS3='Choisissez un composant: '
    options=("Backend" "Frontend" "MySQL" "Proxy" "Tous" "Quitter")
    select opt in "${options[@]}"
    do
        case $opt in
            "Backend")
                kubectl logs -n $NAMESPACE -l app.kubernetes.io/component=backend --tail=100 -f
                break
                ;;
            "Frontend")
                kubectl logs -n $NAMESPACE -l app.kubernetes.io/component=frontend --tail=100 -f
                break
                ;;
            "MySQL")
                kubectl logs -n $NAMESPACE -l app.kubernetes.io/component=mysql --tail=100 -f
                break
                ;;
            "Proxy")
                kubectl logs -n $NAMESPACE -l app.kubernetes.io/component=proxy --tail=100 -f
                break
                ;;
            "Tous")
                kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=travelo --tail=50 --all-containers=true
                break
                ;;
            "Quitter")
                break
                ;;
            *) echo "Option invalide $REPLY";;
        esac
    done
}

# Main
main() {
    case "${1:-help}" in
        install)
            check_prerequisites
            install_app
            ;;
        upgrade)
            check_prerequisites
            upgrade_app
            ;;
        uninstall)
            check_prerequisites
            uninstall_app
            ;;
        status)
            check_prerequisites
            show_status
            ;;
        logs)
            check_prerequisites
            show_logs
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Commande inconnue: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
