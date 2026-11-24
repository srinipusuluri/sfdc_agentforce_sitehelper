import assert from "node:assert/strict";
import { test } from "node:test";
import type Anthropic from "@anthropic-ai/sdk";
import type { AgentDef } from "./agents.js";
import { assertId, likeEscape } from "./salesforce.js";
import { resolveModel } from "./claude.js";
import { runAgent } from "./runAgent.js";

/** A fake client that replays scripted responses and records the requests it was sent. */
function fakeClient(script: Partial<Anthropic.Message>[]) {
  const seen: Anthropic.MessageCreateParamsNonStreaming[] = [];
  let i = 0;
  const client = {
    messages: { create: async (p: Anthropic.MessageCreateParamsNonStreaming) => (seen.push(p), script[i++]) },
  } as unknown as Anthropic;
  return { client, seen };
}

const def = (run: AgentDef["run"], maxTurns = 3): AgentDef => ({ system: "s", tools: [], run, maxTurns });

test("runs a tool, feeds the result back, returns the final text", async () => {
  const { client, seen } = fakeClient([
    { stop_reason: "tool_use", content: [{ type: "tool_use", id: "t1", name: "get_case", input: {} }] as never },
    { stop_reason: "end_turn", content: [{ type: "text", text: "Summary done" }] as never },
  ]);
  const out = await runAgent(def(async () => ({ subject: "Generator down" })), "summarize", { recordId: "500000000000001AAA" }, client);
  assert.equal(out, "Summary done");
  const toolResult = (seen[1].messages.at(-1)!.content as Anthropic.ToolResultBlockParam[])[0];
  assert.equal(toolResult.tool_use_id, "t1");
  assert.match(String(toolResult.content), /Generator down/);
});

test("a failing tool returns is_error and does not leak the error text", async () => {
  const { client, seen } = fakeClient([
    { stop_reason: "tool_use", content: [{ type: "tool_use", id: "t1", name: "x", input: {} }] as never },
    { stop_reason: "end_turn", content: [{ type: "text", text: "ok" }] as never },
  ]);
  await runAgent(def(async () => { throw new Error("secret detail"); }), "q", {}, client);
  const r = (seen[1].messages.at(-1)!.content as Anthropic.ToolResultBlockParam[])[0];
  assert.equal(r.is_error, true);
  assert.equal(r.content, "The tool failed.");
});

test("stops with an error on refusal, on truncation, and on too many turns", async () => {
  await assert.rejects(runAgent(def(async () => 1), "q", {}, fakeClient([{ stop_reason: "refusal", content: [] }]).client), /declined/);
  await assert.rejects(runAgent(def(async () => 1), "q", {}, fakeClient([{ stop_reason: "max_tokens", content: [] }]).client), /cut off/);
  const loop = { stop_reason: "tool_use", content: [{ type: "tool_use", id: "t", name: "x", input: {} }] } as never;
  await assert.rejects(runAgent(def(async () => 1, 2), "q", {}, fakeClient([loop, loop]).client), /too many turns/);
});

test("Salesforce Id and LIKE inputs are sanitized", () => {
  assert.equal(assertId("500gL00001jIf2KQAS"), "500gL00001jIf2KQAS");
  assert.throws(() => assertId("500' OR Id != '"), /Invalid/);
  assert.equal(likeEscape("a'b%c_d"), "a\\'b\\%c\\_d");
});

test("the model ID is adjusted for the route", () => {
  assert.equal(resolveModel("anthropic", undefined), "claude-sonnet-5-5");
  assert.equal(resolveModel("claude-platform-on-aws", "claude-opus-5-5"), "claude-opus-5-5");
  assert.equal(resolveModel("bedrock", "claude-sonnet-5-5"), "anthropic.claude-sonnet-5-5");
  assert.equal(resolveModel("bedrock", "anthropic.claude-sonnet-5-5"), "anthropic.claude-sonnet-5-5");
  assert.equal(resolveModel("anthropic", "anthropic.claude-sonnet-5-5"), "claude-sonnet-5-5");
});
