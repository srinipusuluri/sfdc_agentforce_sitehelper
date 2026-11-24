import Anthropic from "@anthropic-ai/sdk";
import { getSecret } from "./secrets.js";

/**
 * Three ways to reach Claude from AWS. Pick one with CLAUDE_ROUTE:
 *  - "anthropic"              Anthropic API with a key held in Secrets Manager (simplest)
 *  - "claude-platform-on-aws" Anthropic-operated, AWS IAM (SigV4) auth and AWS billing
 *  - "bedrock"                Amazon Bedrock through the Mantle client (partner-operated)
 */
export type Route = "anthropic" | "claude-platform-on-aws" | "bedrock";

export const route = (process.env.CLAUDE_ROUTE ?? "anthropic") as Route;

/** Bedrock model IDs carry an "anthropic." prefix. The other two routes use the bare ID. */
export function resolveModel(r: Route, configured?: string): string {
  const id = configured && configured.length > 0 ? configured : "claude-sonnet-5-5";
  const bare = id.startsWith("anthropic.") ? id.slice("anthropic.".length) : id;
  return r === "bedrock" ? `anthropic.${bare}` : bare;
}

export const MODEL = resolveModel(route, process.env.CLAUDE_MODEL);

let client: Anthropic | undefined;

export async function getClient(): Promise<Anthropic> {
  if (client) return client;
  switch (route) {
    case "anthropic": {
      const apiKey = await getSecret(requiredEnv("ANTHROPIC_SECRET_ID"));
      client = new Anthropic({ apiKey });
      break;
    }
    case "claude-platform-on-aws": {
      // Needs AWS_REGION and ANTHROPIC_AWS_WORKSPACE_ID. Credentials come from the Lambda role.
      const { default: AnthropicAws } = await import("@anthropic-ai/aws-sdk");
      client = new AnthropicAws() as unknown as Anthropic;
      break;
    }
    case "bedrock": {
      const { AnthropicBedrockMantle } = await import("@anthropic-ai/bedrock-sdk");
      client = new AnthropicBedrockMantle({ awsRegion: process.env.AWS_REGION }) as unknown as Anthropic;
      break;
    }
    default:
      throw new Error(`Unknown CLAUDE_ROUTE: ${route}`);
  }
  return client;
}

export function requiredEnv(name: string): string {
  const v = process.env[name];
  if (!v) throw new Error(`Missing environment variable ${name}`);
  return v;
}
