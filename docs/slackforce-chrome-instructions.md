# Instructions for Claude in Chrome: connect Slack and Salesforce ("Slackforce")

Paste everything below the line into Claude in Chrome. It is written to be followed step by step, with stop points.

---

## Goal

Connect the Slack workspace your to the Salesforce org so that:

1. Salesforce can post case alerts and a daily digest into a Slack channel (incoming webhook).
2. If the org allows it, the Salesforce and Slack native integration (Agentforce in Slack) is switched on so the Case Triage Assistant agent can be used from Slack.

Do part 1 fully. Do part 2 only as far as the org and plan allow, and report what blocks you.

## Where things are

- Slack workspace: `https://app.slack.com/client/<WORKSPACE_ID>` (your workspace and channel)
- Slack apps: `https://api.slack.com/apps`
- Salesforce org: `https://<your-org>.my.salesforce.com` (open Setup from the gear icon)
- Salesforce item to fill in: Setup > Custom Labels > `Slack_Webhook_Url` (currently `REPLACE_ME`)
- The Slack workspace is on a free plan. Some Slack features need a paid plan. Report this instead of working around it.

## Rules for you

- Work in a new browser tab. Take a screenshot before each click that changes something.
- Do not type, paste, read aloud or repeat any secret: not the webhook URL, tokens, passwords or verification codes. When one is needed, tell me and wait. I will enter it myself.
- Do not enter passwords or approve login, MFA or CAPTCHA prompts. Stop and ask me.
- Ask me before any of these, and wait for a clear yes: creating a Slack app, adding an app to a channel, clicking Allow or Approve on a permissions screen, saving a change in Salesforce Setup, and posting a message in Slack.
- Do not change other Slack settings, channels or members, and do not change Salesforce settings other than the ones named here.
- If a page does not load, a button does nothing, or you fail after 2 or 3 attempts at the same step, stop and tell me what you tried.
- Do not open or trigger browser alert, confirm or prompt dialogs.

## Part 1: Slack incoming webhook

1. Check that I am signed in to Slack in this browser. If a sign-in page appears, stop and ask me to sign in.
2. Open `https://api.slack.com/apps`. Ask me for a yes, then choose **Create New App**, **From scratch**. Name it `Salesforce Case Alerts` and pick the your workspace.
3. In the app's left menu open **Incoming Webhooks** and switch **Activate Incoming Webhooks** on.
4. Ask me for a yes, then click **Add New Webhook to Workspace**. Choose the channel your alert channel (or the channel I name). On the permission screen, stop. Tell me what it asks for and wait for my yes before clicking **Allow**.
5. A webhook URL starting with `https://hooks.slack.com/services/` appears in the table. Do not read it out and do not copy it into any chat or file. Tell me it exists and show me where on the page it is, so I can use its **Copy** button myself.
6. Open a second tab at the Salesforce org, then Setup, and search **Custom Labels** in Quick Find. Open the label `Slack_Webhook_Url`. Tell me it is open and wait. I will paste the URL into the **Value** field and tell you when it is done.
7. After I say it is entered, ask me for a yes, then click **Save**. Confirm the value no longer says `REPLACE_ME` without reading the value back to me.
8. Tell me to tell Claude Code that the webhook is set. Claude Code will run the test message and the digest schedule from the command line.

Done when: the Slack app has an active webhook for the channel, and the Salesforce label is saved with my value.

## Part 2: Agentforce in Slack (only if available)

1. In Salesforce Setup, search Quick Find for `Slack`. List the Slack-related pages you find (for example Slack integration, Agentforce in Slack, or Slack apps). Do not click Connect, Install or Enable on anything yet.
2. Open the page that connects the org to a Slack workspace. Report to me: the page name, whether the connect button is enabled, and any message about plan, edition or licence.
3. If it is available, tell me what connecting will do (which permissions it asks for in Slack and what it enables in Salesforce) and wait for a yes. Then follow the connect flow. At each Slack or Salesforce permission screen, stop and wait for my yes.
4. After connecting, find where agents are made available in Slack and whether `Case_Triage_Assistant` can be added. Report options and wait for my choice. Do not enable more than I approve.
5. If any step is blocked by plan or edition, stop and report the exact message on screen.

Done when: I know whether the integration is available in this org and plan, and, if it is, the agent is reachable from Slack with the permissions I approved.

## Final report

Reply with a short list:

- What you did, step by step, with the page name for each.
- What I still need to do myself.
- Anything blocked, with the exact on-screen message.
- Anything you saw that looked unexpected.

Never include secrets in the report.
