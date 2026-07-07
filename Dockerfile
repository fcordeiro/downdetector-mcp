FROM node:20-alpine

RUN npm install -g downdetector-mcp supergateway

EXPOSE 3000

CMD ["sh", "-c", "npx -y supergateway --stdio 'npx -y downdetector-mcp' --port 3000 --baseUrl https://monitoramento-downdetector-mcp.cackbc.easypanel.host --healthEndpoint /health --ssePath /${MCP_SECRET_PATH}/sse --messagePath /${MCP_SECRET_PATH}/message"]
