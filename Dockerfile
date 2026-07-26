# ---- Stage 1 : build de l'application Angular ----
FROM node:20-alpine AS build

WORKDIR /app

# On copie d'abord les manifestes de dépendances seuls.
# Docker met en cache cette couche : tant que package*.json ne change pas,
# le npm ci n'est pas rejoué même si le code source change.
COPY package.json package-lock.json ./
RUN npm ci

# Puis le reste du code source
COPY . .

# Build de production. La sortie va dans dist/olympic-games-starter/browser/
RUN npm run build

# ---- Stage 2 : image finale, Nginx servant les fichiers statiques ----
FROM nginx:alpine

# Config Nginx fournie par le repo (gère le routing SPA via try_files, root /app)
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# On copie UNIQUEMENT le contenu de browser/ (l'index.html s'y trouve)
# vers /app, la racine configurée dans nginx.conf.
COPY --from=build /app/dist/olympic-games-starter/browser /app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]