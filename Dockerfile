FROM node:20-bullseye-slim

# Instala o Chromium e as bibliotecas de sistema que o Puppeteer precisa.
RUN apt-get update && apt-get install -y \
    chromium \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN npm install -g downdetector-mcp@latest supergateway@latest

# Corrige o downdetector-api em dois pontos:
# 1) Não engolir erros silenciosamente (facilita o diagnóstico).
# 2) Adicionar a flag --no-sandbox ao Puppeteer, já que o contêiner do
#    Easypanel não permite a criação dos namespaces de isolamento que o
#    sandbox padrão do Chromium exige (mesmo com o pacote chromium-sandbox
#    instalado e as permissões de SETUID ajustadas).
RUN NPM_ROOT=$(npm root -g) && \
    FILE="$NPM_ROOT/downdetector-mcp/node_modules/downdetector-api/index.js" && \
    if [ -f "$FILE" ]; then \
      sed -i "s/console.error(err.message);/console.error(err.message); throw err;/" "$FILE" && \
      sed -i "s|puppeteer.launch()|puppeteer.launch({ headless: 'new', args: ['--no-sandbox', '--disable-setuid-sandbox'] })|" "$FILE"; \
    fi

EXPOSE 3000

HEALTHCHECK NONE

CMD ["sh", "-c", "supergateway --stdio 'downdetector-mcp' --port 3000 --outputTransport streamableHttp --streamableHttpPath /${MCP_SECRET_PATH}/mcp --healthEndpoint /health --stateful"]
