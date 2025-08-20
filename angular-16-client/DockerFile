# Multi-stage build pour optimiser la taille de l'image finale

# Stage 1: Build de l'application Angular
FROM node:18-alpine AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer toutes les dépendances (dev + prod) pour le build
RUN npm ci

# Copier le code source
COPY . .

# Build de l'application Angular pour la production
RUN npm run build

# Stage 2: Servir l'application avec Nginx
FROM nginx:alpine

# Copier les fichiers buildés depuis le stage précédent
COPY --from=build /app/dist/angular-16-crud /usr/share/nginx/html

# Copier la configuration Nginx personnalisée (optionnel)
# COPY nginx.conf /etc/nginx/nginx.conf

# Exposer le port 80
EXPOSE 80

# Commande par défaut pour démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]