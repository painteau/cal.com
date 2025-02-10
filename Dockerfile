FROM node:18-bullseye AS build

ARG NEXTAUTH_SECRET="s3hZEw5YsmZixzmAC9UWat9sVLQUiBCiKEJK"
ARG DATABASE_URL="postgresql://cal:s5vFyESc@cal-db:5432/caldb"

ENV NEXTAUTH_SECRET=$NEXTAUTH_SECRET
ENV DATABASE_URL=$DATABASE_URL

# Définition des variables d'environnement
ENV NEXT_TELEMETRY_DISABLED 1
WORKDIR /app

# Cloner le dépôt de Cal.com
RUN git clone --depth 1 https://github.com/calcom/cal.com.git .

# Installer les dépendances
RUN corepack enable && yarn install --frozen-lockfile

# Construire l'application
RUN yarn build

# Production image
FROM node:18-bullseye

WORKDIR /app
COPY --from=build /app /app

# Installer les dépendances runtime
RUN corepack enable && yarn install --production

# Exposer le port
EXPOSE 3000

# Commande de démarrage
CMD ["yarn", "start"]
