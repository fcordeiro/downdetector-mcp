FROM node:20-bullseye-slim

# Instala o Chromium e as bibliotecas de sistema que o Puppeteer precisa.
# A imagem "alpine" usada antes não tinha essas bibliotecas, por isso o
# downdetector-api falhava silenciosamente ao tentar abrir o navegador
# headless, gerando o erro "Cannot read properties of undefined (reading 'reports')".
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

# Diz ao Puppeteer para usar o Chromium do sistema, em vez de tentar baixar
# o dele próprio (esse download falharia de qualquer forma sem essas bibliotecas).
# As duas variáveis existem porque o nome mudou entre versões do Puppeteer.
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN npm install -g downdetector-mcp@latest supergateway@latest

# Corrige o downdetector-api para não engolir erros silenciosamente: em vez
# de só fazer console.error e devolver "undefined" (o que quebrava o
# downdetector-mcp com uma mensagem confusa), agora ele relança o erro,
# então qualquer falha futura aparece com uma mensagem real e útil.
RUN NPM_ROOT=$(npm root -g) && \
    FILE="$NPM_ROOT/downdetector-mcp/node_modules/downdetector-api/index.js" && \
    if [ -f "$FILE" ]; then \
      sed -i "s/console.error(err.message);/console.error(err.message); throw err;/" "$FILE"; \
    fi

EXPOSE 3000

HEALTHCHECK NONE

CMD ["sh", "-c", "supergateway --stdio 'downdetector-mcp' --port 3000 --outputTransport streamableHttp --streamableHttpPath /${MCP_SECRET_PATH}/mcp --healthEndpoint /health --stateful"]
