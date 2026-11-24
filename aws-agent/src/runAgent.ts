import type Anthropic from "@anthropic-ai/sdk";
import { MODEL, getClient } from "./claude.js";
import type { AgentDef, Ctx } from "./agents.js";

const MAX_TOOL_RESULT_CHARS = 12_000;

/**
 * A plain tool loop on the Messages API. It works the same on all three routes and keeps every guard visible.
 * Returns the final text. Throws on refusal, truncation, or too many turns.
 */
export async function runAgent(def: AgentDef, question: string, ctx: Ctx, injected?: Anthropic): Promise<string> {
  const client = injected ?? (await getClient());
  const messages: Anthropic.MessageParam[] = [{ role: "user", content: question }];

  for (let turn = 0; turn < def.maxTurns; turn++) {
    const res = await client.messages.create({
      model: MODEL,
      max_tokens: 16000, // thinking tokens count toward this limit, so leave room
      system: def.system,
      tools: def.tools,
      messages,
    });

    if (res.stop_reason === "refusal") throw new Error("The model declined this request");
    if (res.stop_reason === "max_tokens") throw new Error("Response was cut off; raise max_tokens");

    const toolUses = res.content.filter((b): b is Anthropic.ToolUseBlock => b.type === "tool_use");
    if (res.stop_reason !== "tool_use" || toolUses.length === 0) {
      return res.content
        .filter((b): b is Anthropic.TextBlock => b.type === "text")
        .map((b) => b.text)
        .join("\n")
        .trim();
    }

    messages.push({ role: "assistant", content: res.content });
    const results: Anthropic.ToolResultBlockParam[] = [];
    for (const use of toolUses) {
      try {
        const out = await def.run(use.name, use.input as Record<string, unknown>, ctx);
        results.push({
          type: "tool_result",
          tool_use_id: use.id,
          content: JSON.stringify(out).slice(0, MAX_TOOL_RESULT_CHARS),
        });
      } catch (err) {
        console.error("tool failed", use.name, err);
        results.push({ type: "tool_result", tool_use_id: use.id, is_error: true, content: "The tool failed." });
      }
    }
    messages.push({ role: "user", content: results });
  }
  throw new Error("Agent used too many turns");
}
