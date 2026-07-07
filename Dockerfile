FROM node:20-alpine

RUN npm install -g downdetector-mcp@latest supergateway@latest

EXPOSE 3000

CMD ["sh", "-c", "supergateway --stdio 'downdetector-mcp' --port 3000 --outputTransport streamableHttp --streamableHttpPath /${MCP_SECRET_PATH}/mcp --healthEndpoint /health --stateful"]
