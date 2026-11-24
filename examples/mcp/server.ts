// A minimal remote MCP server that exposes one read-only Salesforce tool over Streamable HTTP.
// Stateless: a new server and transport per request, which suits Lambda or Fargate.
import { createServer, type IncomingMessage } from "node:http";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { z } from "zod";

// Replace with a real call to the Salesforce REST API (see aws-agent/src/salesforce.ts).
async function getCaseByNumber(caseNumber: string): Promise<{ caseNumber: string; subject: string; status: string }> {
  return { caseNumber, subject: "Example subject", status: "New" };
}

function buildServer(): McpServer {
  const server = new McpServer({ name: "salesforce-cases", version: "0.1.0" });
  server.registerTool(
    "get_case",
    {
      title: "Get a Case",
      description: "Look up one Case by its case number. Read-only.",
      inputSchema: { caseNumber: z.string().regex(/^\d{8}$/, "8 digits, e.g. 00001038") },
    },
    async ({ caseNumber }) => ({
      content: [{ type: "text", text: JSON.stringify(await getCaseByNumber(caseNumber)) }],
    }),
  );
  return server;
}

async function readJson(req: IncomingMessage): Promise<unknown> {
  const chunks: Buffer[] = [];
  for await (const c of req) chunks.push(c as Buffer);
  return chunks.length ? JSON.parse(Buffer.concat(chunks).toString()) : undefined;
}

createServer(async (req, res) => {
  if (req.url !== "/mcp" || req.method !== "POST") {
    res.writeHead(404).end();
    return;
  }
  // Authenticate the caller here (OAuth access token or a shared key) BEFORE any tool runs.
  const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined });
  const server = buildServer();
  res.on("close", () => {
    void transport.close();
    void server.close();
  });
  await server.connect(transport);
  await transport.handleRequest(req, res, await readJson(req));
}).listen(3000, () => console.log("MCP server on :3000/mcp"));
