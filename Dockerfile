FROM node:18.20-alpine

# Instala as dependências necessárias para n8n e Puppeteer
RUN apk add --update --no-cache \
    graphicsmagick \
    tzdata \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

USER root

# Instala n8n
RUN apk --update add --virtual build-dependencies python3 build-base && \
    npm_config_user=root npm install --location=global n8n && \
    apk del build-dependencies

WORKDIR /data

# Configura as variáveis de ambiente para o Puppeteer
ENV  PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
     PUPPETEER_EXECUTABLE_PATH=/data/chrome/linux-127.0.6533.99/chrome-linux64/chrome \
     NODE_PATH=/usr/local/lib/node_modules:/data/node_modules

# Instala o Puppeteer e o Chrome
RUN npm init -y && npm install puppeteer@23.0.2
RUN npx @puppeteer/browsers install chrome@stable


EXPOSE $PORT

# Set root user
ENV N8N_USER_ID=root

# Adiciona a configuração para permitir módulos externos
ENV NODE_FUNCTION_ALLOW_EXTERNAL=puppeteer

CMD export N8N_PORT=$PORT && n8n start