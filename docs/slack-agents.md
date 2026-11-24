# Slack agents for Salesforce cases

Four agents for the `aiforall` Slack workspace. Two are Salesforce automation that posts into Slack (built and deployed). Two are Slackbot-style assistants (definitions below, to be created in Slack).

## 1. Daily case digest (built)
Posts open Cases by priority every morning.
- Code: `SlackCaseDigestJob`, `SlackCaseNotifier.buildDigest()`
- Schedule it once the webhook is set (Developer Console > Execute Anonymous):
  `System.schedule('Slack case digest', '0 0 8 * * ?', new SlackCaseDigestJob());`

## 2. Escalation watcher (built)
Posts to Slack when a new Case is created with Priority = High.
- Code: trigger `CaseSlackAlertTrigger` calls `SlackCaseNotifier.alertHighPriority`
- Sends one message per insert batch, asynchronously. Does nothing while the webhook is unset.

### Turn both on (about 2 minutes)
1. In Slack, create an app at api.slack.com/apps (from scratch), enable **Incoming Webhooks**, add a webhook to the channel you want (for example `#aiforall-central`), and copy the URL.
2. In Salesforce Setup > Custom Labels, open `Slack_Webhook_Url` and replace `REPLACE_ME` with that URL.
3. Run the schedule command above for the digest.

The webhook URL is a secret. The label is marked protected, but for production use a Named Credential instead.

## 3. Case Triage (Slackbot assistant, to create)
**Purpose:** answer "what is open and what is urgent".
**Instructions to give it:**
> You help the support team triage Salesforce cases. When asked, list open cases grouped by priority, highlight High priority first, and give case number, account and subject. Never change a case unless the person confirms the case number and the new priority. If you do not know, say so.

**Try:** "Which High priority cases are open?" · "Summarize today's new cases."

## 4. Knowledge helper (Slackbot assistant, to create)
**Purpose:** answer support questions from the five published articles.
**Instructions to give it:**
> Answer using only these topics: routine generator maintenance, GC5060 wiring installation, rotor vibration troubleshooting, how to contact support and what a case should include, and warranty coverage. If the question is outside these, say you do not have an article and suggest opening a case.

**Try:** "How often should I change generator oil?" · "What voids the warranty?"

Note: the Slackbot in this workspace is a preview chat assistant with no agent builder, so agents 3 and 4 are used by pasting the instructions at the start of a conversation or into a Slack workflow, not as standalone apps. To make them standalone, connect the Agentforce agent `Case_Triage_Assistant` to Slack through Agentforce for Slack, which needs the Slack integration enabled in Salesforce Setup.
