// Run an agent from your terminal while you build it with Claude Code:
//   AWS_REGION=us-east-1 ANTHROPIC_SECRET_ID=... SF_SECRET_ID=... npm run local -- kb-answer "How often should I change generator oil?"
import { agents } from "./agents.js";
import { runAgent } from "./runAgent.js";

const [name, question, recordId] = process.argv.slice(2);
const def = agents[name ?? ""];
if (!def || !question) {
  console.error(`Usage: npm run local -- <${Object.keys(agents).join("|")}> "<question>" [recordId]`);
  process.exit(1);
}
console.log(await runAgent(def, question, { recordId }));
