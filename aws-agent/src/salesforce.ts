import { getSecret } from "./secrets.js";
import { requiredEnv } from "./claude.js";

/**
 * Minimal Salesforce REST client for the agent's tools.
 * Auth: OAuth 2.0 client credentials flow. The External Client App (or Connected App) is bound to a
 * dedicated integration user, so the agent can do only what that user's permissions allow.
 * SF_SECRET_ID holds JSON: {"loginUrl":"https://<domain>.my.salesforce.com","clientId":"...","clientSecret":"..."}
 */
const API_VERSION = "v68.0";

type Token = { accessToken: string; instanceUrl: string; expiresAt: number };
let cached: Token | undefined;

async function getToken(force = false): Promise<Token> {
  if (!force && cached && cached.expiresAt > Date.now() + 60_000) return cached;
  const cred = JSON.parse(await getSecret(requiredEnv("SF_SECRET_ID"))) as {
    loginUrl: string;
    clientId: string;
    clientSecret: string;
  };
  const res = await fetch(`${cred.loginUrl}/services/oauth2/token`, {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "client_credentials",
      client_id: cred.clientId,
      client_secret: cred.clientSecret,
    }),
  });
  if (!res.ok) throw new Error(`Salesforce token request failed: ${res.status}`);
  const body = (await res.json()) as { access_token: string; instance_url: string };
  // The response may not state a lifetime, so refresh conservatively and retry once on 401 below.
  cached = { accessToken: body.access_token, instanceUrl: body.instance_url, expiresAt: Date.now() + 25 * 60_000 };
  return cached;
}

async function sf(path: string, init: RequestInit = {}, retried = false): Promise<unknown> {
  const t = await getToken(retried);
  const res = await fetch(`${t.instanceUrl}/services/data/${API_VERSION}${path}`, {
    ...init,
    headers: { authorization: `Bearer ${t.accessToken}`, "content-type": "application/json", ...(init.headers ?? {}) },
  });
  if (res.status === 401 && !retried) return sf(path, init, true);
  if (!res.ok) throw new Error(`Salesforce ${init.method ?? "GET"} ${path} failed: ${res.status}`);
  return res.status === 204 ? null : res.json();
}

const SF_ID = /^[a-zA-Z0-9]{15,18}$/;
export function assertId(id: string): string {
  if (!SF_ID.test(id)) throw new Error("Invalid Salesforce Id");
  return id;
}

/** Escape a user-supplied term for a SOQL LIKE clause. */
export function likeEscape(term: string): string {
  return term.replace(/[\\'"%_]/g, (c) => `\\${c}`);
}

export async function soql<T>(query: string): Promise<T[]> {
  const out = (await sf(`/query?q=${encodeURIComponent(query)}`)) as { records: T[] };
  return out.records;
}

export async function addCaseComment(caseId: string, body: string): Promise<void> {
  await sf("/sobjects/CaseComment", {
    method: "POST",
    body: JSON.stringify({ ParentId: assertId(caseId), CommentBody: body.slice(0, 3900), IsPublished: false }),
  });
}
