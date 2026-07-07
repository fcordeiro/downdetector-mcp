FROM node:20-alpine

RUN npm install -g downdetector-mcp supergateway

EXPOSE 3000

CMD ["npx", "-y", "supergateway", "--stdio", "npx -y downdetector-mcp", "--port", "3000"]
