# Minimal remote MCP server for Salesforce

One read-only tool (`get_case`) served over Streamable HTTP at `/mcp`. It is stateless, so it runs on Lambda (behind a web adapter) or Fargate.

```
npm install
npm run typecheck
npm start
claude mcp add --transport http sf-cases http://localhost:3000/mcp
```

Before you expose it: authenticate every request (OAuth access token or a shared key), replace the stub with a real Salesforce call made as a least-privilege integration user, and keep tools read-only unless a write is truly needed.
