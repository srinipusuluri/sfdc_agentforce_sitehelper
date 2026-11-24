import { timingSafeEqual } from "node:crypto";
import type { LambdaFunctionURLEvent, LambdaFunctionURLResult } from "aws-lambda";
import { agents } from "./agents.js";
import { requiredEnv } from "./claude.js";
import { runAgent } from "./runAgent.js";
import { getSecret } from "./secrets.js";

const json = (statusCode: number, body: unknown): LambdaFunctionURLResult => ({
  statusCode,
  headers: { "content-type": "application/json" },
  body: JSON.stringify(body),
});

async function callerIsAllowed(event: LambdaFunctionURLEvent): Promise<boolean> {
  const sent = event.headers?.["x-api-key"] ?? "";
  const expected = await getSecret(requiredEnv("CALLER_SECRET_ID"));
  const a = Buffer.from(sent);
  const b = Buffer.from(expected);
  return a.length === b.length && timingSafeEqual(a, b);
}

/**
 * Request:  POST {"agent":"case-summary","question":"...","recordId":"500..."}
 * Response: 200 {"answer":"..."}
 * Called by Salesforce Apex through a Named Credential that adds the x-api-key header.
 */
export const handler = async (event: LambdaFunctionURLEvent): Promise<LambdaFunctionURLResult> => {
  try {
    if (!(await callerIsAllowed(event))) return json(401, { error: "unauthorized" });

    const raw = event.isBase64Encoded ? Buffer.from(event.body ?? "", "base64").toString() : (event.body ?? "");
    const body = JSON.parse(raw) as { agent?: string; question?: string; recordId?: string };

    const def = body.agent ? agents[body.agent] : undefined;
    if (!def) return json(400, { error: "unknown agent" });
    const question = (body.question ?? "").trim();
    if (question.length === 0 || question.length > 1000) return json(400, { error: "question must be 1 to 1000 characters" });

    const answer = await runAgent(def, question, { recordId: body.recordId });
    return json(200, { answer });
  } catch (err) {
    console.error(err);
    return json(500, { error: "agent failed" }); // never return internal detail to the caller
  }
};
