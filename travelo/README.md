# Travelo Helm Chart

Un chart Helm complet pour déployer l'application Travelo (système de réservation de vols) sur Kubernetes.

## Description

Ce chart déploie une stack complète comprenant :
- **MySQL 8.4** - Base de données
- **Backend Spring Boot** - API REST
- **Frontend React** - Interface utilisateur
- **Nginx Proxy** - Reverse proxy

## Prérequis

- Kubernetes 1.19+
- Helm 3.0+
- PersistentVolume provisioner (pour MySQL)

## Installation

### Ajouter le repository Helm

```bash
helm repo add travelo https://tahazizah.github.io/travelo-helm/
helm repo update
```

### Installer le chart

```bash
# Installation simple
helm install travelo travelo/travelo --namespace helm --create-namespace

# Avec des valeurs personnalisées
helm install travelo travelo/travelo \
  --namespace helm \
  --create-namespace \
  --set mysql.auth.rootPassword=monpassword \
  --set backend.replicaCount=3
```

### Installer depuis le code source local

```bash
git clone https://github.com/TahaZizah/travelo-helm.git
cd travelo-helm
helm install travelo ./travelo --namespace helm --create-namespace
```

## Configuration

Les paramètres suivants peuvent être configurés dans `values.yaml` :

### Global

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `global.namespace` | Namespace Kubernetes | `helm` |

### MySQL

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `mysql.enabled` | Activer MySQL | `true` |
| `mysql.image.repository` | Image MySQL | `mysql` |
| `mysql.image.tag` | Tag de l'image | `8.4` |
| `mysql.auth.rootPassword` | Mot de passe root | `rootpassword123` |
| `mysql.auth.database` | Nom de la base | `travelo_db` |
| `mysql.auth.username` | Utilisateur | `travelo_user` |
| `mysql.auth.password` | Mot de passe utilisateur | `travelo_password123` |
| `mysql.persistence.enabled` | Activer la persistance | `true` |
| `mysql.persistence.size` | Taille du volume | `10Gi` |

### Backend

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `backend.enabled` | Activer le backend | `true` |
| `backend.replicaCount` | Nombre de replicas | `2` |
| `backend.image.repository` | Image backend | `anasslpro/travelo_backend` |
| `backend.image.tag` | Tag de l'image | `v5` |
| `backend.service.port` | Port du service | `8080` |

### Frontend

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `frontend.enabled` | Activer le frontend | `true` |
| `frontend.replicaCount` | Nombre de replicas | `2` |
| `frontend.image.repository` | Image frontend | `mohamedkhalilassaddiki/travelo-frontend` |
| `frontend.image.tag` | Tag de l'image | `v3` |

### Proxy

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `proxy.enabled` | Activer le proxy | `true` |
| `proxy.service.type` | Type de service | `LoadBalancer` |
| `proxy.service.port` | Port du service | `80` |

## Utilisation

### Vérifier le déploiement

```bash
# Lister les ressources
kubectl get all -n helm

# Vérifier les pods
kubectl get pods -n helm

# Voir les logs
kubectl logs -n helm -l app.kubernetes.io/component=backend
kubectl logs -n helm -l app.kubernetes.io/component=frontend
```

### Accéder à l'application

#### Avec LoadBalancer (Cloud)

```bash
export SERVICE_IP=$(kubectl get svc --namespace helm travelo-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application disponible à : http://$SERVICE_IP"
```

#### Avec Port-Forward (Local)

```bash
kubectl port-forward -n helm svc/travelo-proxy 8080:80
# Ouvrir http://localhost:8080
```

### Mettre à jour le déploiement

```bash
# Mise à jour simple
helm upgrade travelo travelo/travelo -n helm

# Avec nouvelles valeurs
helm upgrade travelo travelo/travelo -n helm \
  --set backend.replicaCount=3 \
  --set frontend.replicaCount=3
```

### Désinstaller

```bash
helm uninstall travelo -n helm
kubectl delete namespace helm
```

## Architecture

```
┌─────────────────────────────────────────────┐
│              Nginx Proxy                     │
│         (travelo-proxy:80)                   │
│  ┌──────────────┬────────────────────────┐  │
│  │ / -> frontend│ /api -> backend        │  │
└──┴──────────────┴────────────────────────┴──┘
         │                    │
         ▼                    ▼
   ┌──────────┐        ┌──────────┐
   │ Frontend │        │ Backend  │
   │ (React)  │        │ (Spring) │
   │  :80     │        │  :8080   │
   └──────────┘        └────┬─────┘
                            │
                            ▼
                      ┌──────────┐
                      │  MySQL   │
                      │  :3306   │
                      └──────────┘
```

## Développement

### Valider le chart

```bash
helm lint travelo/
```

### Tester le rendu des templates

```bash
helm template travelo travelo/
```

### Packager le chart

```bash
helm package travelo/
```

## Support

- Repository : https://github.com/TahaZizah/travelo-helm
- Issues : https://github.com/TahaZizah/travelo-helm/issues

## Licence

MIT License
