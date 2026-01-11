# Travelo Helm Chart Repository

🚀 Repository Helm officiel pour l'application Travelo - Système de réservation de vols

## 📦 Installation rapide

```bash
# Ajouter le repository
helm repo add travelo https://tahazizah.github.io/travelo-helm/
helm repo update

# Installer l'application
helm install travelo travelo/travelo --namespace helm --create-namespace

# Accéder à l'application
kubectl port-forward -n helm svc/travelo-proxy 8080:80
# Ouvrir http://localhost:8080
```

## 📖 Documentation complète

Consultez le [README du chart](travelo/README.md) pour la documentation complète.

## 🏗️ Architecture

L'application Travelo est composée de 4 composants :

- **MySQL 8.4** - Base de données relationnelle
- **Spring Boot Backend** - API REST Java
- **React Frontend** - Interface utilisateur moderne
- **Nginx Proxy** - Reverse proxy et load balancer

## 📋 Prérequis

- Kubernetes 1.19+
- Helm 3.0+
- `kubectl` configuré

## 🚀 Déploiement

### Option 1 : Depuis le repository Helm (Recommandé)

```bash
helm repo add travelo https://tahazizah.github.io/travelo-helm/
helm install travelo travelo/travelo -n helm --create-namespace
```

### Option 2 : Depuis le code source

```bash
git clone https://github.com/TahaZizah/travelo-helm.git
cd travelo-helm
helm install travelo ./travelo -n helm --create-namespace
```

## ⚙️ Configuration

### Valeurs par défaut

```yaml
mysql:
  auth:
    database: travelo_db
    username: travelo_user
  persistence:
    size: 10Gi

backend:
  replicaCount: 2
  image:
    repository: anasslpro/travelo_backend
    tag: v5

frontend:
  replicaCount: 2
  image:
    repository: mohamedkhalilassaddiki/travelo-frontend
    tag: v3

proxy:
  service:
    type: LoadBalancer
```

### Personnalisation

Créez un fichier `custom-values.yaml` :

```yaml
mysql:
  auth:
    rootPassword: "mon-super-password"
  persistence:
    size: 20Gi

backend:
  replicaCount: 3

frontend:
  replicaCount: 3

proxy:
  service:
    type: NodePort  # ou ClusterIP
```

Puis déployez :

```bash
helm install travelo travelo/travelo -f custom-values.yaml -n helm --create-namespace
```

## 🔍 Vérification

```bash
# Status du déploiement
helm list -n helm

# Pods en cours d'exécution
kubectl get pods -n helm

# Services exposés
kubectl get svc -n helm

# Logs
kubectl logs -n helm -l app.kubernetes.io/component=backend --tail=50
```

## 🌐 Accès à l'application

### Avec LoadBalancer (Cloud)

```bash
export SERVICE_IP=$(kubectl get svc -n helm travelo-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application : http://$SERVICE_IP"
```

### Avec Port-Forward (Local/Minikube)

```bash
kubectl port-forward -n helm svc/travelo-proxy 8080:80
```

Puis ouvrir http://localhost:8080

## 📊 Mise à jour

```bash
# Mettre à jour le repository
helm repo update

# Upgrade vers la nouvelle version
helm upgrade travelo travelo/travelo -n helm

# Avec de nouvelles valeurs
helm upgrade travelo travelo/travelo -n helm \
  --set backend.replicaCount=5
```

## 🗑️ Désinstallation

```bash
# Supprimer l'application
helm uninstall travelo -n helm

# Supprimer le namespace
kubectl delete namespace helm
```

## 📁 Structure du repository

```
travelo-helm/
├── README.md                    # Ce fichier
├── index.yaml                   # Index Helm (généré)
├── travelo-1.0.0.tgz           # Package du chart
└── travelo/                     # Code source du chart
    ├── Chart.yaml
    ├── values.yaml
    ├── README.md
    └── templates/
        ├── namespace.yaml
        ├── mysql/
        ├── backend/
        ├── frontend/
        └── proxy/
```

## 🛠️ Développement

### Tester localement

```bash
# Valider le chart
helm lint travelo/

# Voir les templates générés
helm template travelo travelo/

# Installer en mode debug
helm install travelo travelo/ --dry-run --debug -n helm
```

### Packager une nouvelle version

```bash
# 1. Modifier Chart.yaml (incrémenter version)
# 2. Packager
helm package travelo/

# 3. Regénérer l'index
helm repo index . --url https://tahazizah.github.io/travelo-helm/

# 4. Commit et push
git add .
git commit -m "Release v1.0.1"
git push
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amelioration`)
3. Commit vos changements (`git commit -m 'Ajout fonctionnalité'`)
4. Push vers la branche (`git push origin feature/amelioration`)
5. Ouvrir une Pull Request

## 📝 Versions

- **1.0.0** - Version initiale
  - Déploiement complet de l'application Travelo
  - Support MySQL, Backend, Frontend, Proxy
  - Configuration via values.yaml

## 📄 Licence

MIT License

## 👥 Auteurs

- **Taha Zizah** - [@TahaZizah](https://github.com/TahaZizah)

## 🔗 Liens utiles

- [Documentation Helm](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Repository GitHub](https://github.com/TahaZizah/travelo-helm)

---

**⭐ Si ce projet vous est utile, n'hésitez pas à lui donner une étoile !**
