FROM node:18.20-alpine

# Instala as dependências necessárias para n8n
RUN apk add --update --no-cache \
    graphicsmagick \
    tzdata \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Habilita o repositório comunitário
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

USER root

# Instala n8n
RUN apk --update add --virtual build-dependencies python3 build-base && \
    npm_config_user=root npm install --location=global n8n && \
    apk del build-dependencies

# Instala o Firefox
RUN apk add --no-cache firefox

# Configura as variáveis de ambiente para o Puppeteer
ENV  PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
     PUPPETEER_EXECUTABLE_PATH=/usr/bin/firefox \
     NODE_PATH=/usr/local/lib/node_modules:/data/node_modules

WORKDIR /data

# Instala o Puppeteer
RUN npm init -y && npm install puppeteer@23.0.2

EXPOSE $PORT

# Set root user
ENV N8N_USER_ID=root

# Adiciona a configuração para permitir módulos externos
ENV NODE_FUNCTION_ALLOW_EXTERNAL=puppeteer

CMD export N8N_PORT=$PORT && n8n start
