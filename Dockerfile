FROM node:18.20-alpine

ARG N8N_VERSION=1.50.2

# Instala as dependências necessárias para n8n e Puppeteer
RUN apk add --update --no-cache \
    graphicsmagick \
    tzdata \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

USER root

# Instala n8n
RUN apk --update add --virtual build-dependencies python3 build-base && \
    npm_config_user=root npm install --location=global n8n@${N8N_VERSION} && \
    apk del build-dependencies

# Configura as variáveis de ambiente para o Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    NODE_PATH=/usr/local/lib/node_modules:/data/node_modules

WORKDIR /data

# Instala o Puppeteer localmente
RUN npm init -y && npm install puppeteer@22.13.1 && npm install wappalyzer@7.0.3

EXPOSE $PORT

ENV N8N_USER_ID=root

# Adiciona a configuração para permitir módulos externos
ENV NODE_FUNCTION_ALLOW_EXTERNAL=puppeteer

CMD export N8N_PORT=$PORT && n8n start