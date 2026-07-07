FROM node:20-alpine

RUN npm install -g downdetector-mcp supergateway

EXPOSE 8000

CMD ["npx", "-y", "supergateway", "--stdio", "npx -y downdetector-mcp", "--port", "8000"]
