/**
 * Posts Case summaries to Slack through an incoming webhook.
 * The webhook URL lives in the protected custom label Slack_Webhook_Url.
 * While the label still says REPLACE_ME, nothing is sent.
 */
public with sharing class SlackCaseNotifier {
    @TestVisible
    private static String webhookOverride;

    private static String webhookUrl() {
        String url = webhookOverride != null ? webhookOverride : Label.Slack_Webhook_Url;
        return (String.isBlank(url) || url == 'REPLACE_ME') ? null : url;
    }

    public static String buildDigest() {
        List<AggregateResult> rows = [
            SELECT Priority p, COUNT(Id) n FROM Case WHERE IsClosed = FALSE GROUP BY Priority
        ];
        Map<String, Integer> counts = new Map<String, Integer>{ 'High' => 0, 'Medium' => 0, 'Low' => 0 };
        for (AggregateResult r : rows) {
            counts.put((String) r.get('p'), (Integer) r.get('n'));
        }
        return ':clipboard: *Daily case digest*\n' +
            ':red_circle: High: ' + counts.get('High') + '\n' +
            ':large_orange_circle: Medium: ' + counts.get('Medium') + '\n' +
            ':large_green_circle: Low: ' + counts.get('Low');
    }

    public static String buildAlert(List<Case> cases) {
        List<String> lines = new List<String>();
        for (Case c : cases) {
            lines.add('• ' + c.CaseNumber + ' - ' + c.Subject);
        }
        return ':rotating_light: *New High priority case(s)*\n' + String.join(lines, '\n');
    }

    public static void send(String text) {
        String url = webhookUrl();
        if (url == null) {
            return;
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String, String>{ 'text' => text }));
        new Http().send(req);
    }

    @future(callout=true)
    public static void sendAsync(String text) {
        send(text);
    }

    public static void alertHighPriority(List<Case> cases) {
        List<Case> high = new List<Case>();
        for (Case c : cases) {
            if (c.Priority == 'High') {
                high.add(c);
            }
        }
        if (!high.isEmpty() && webhookUrl() != null && !System.isFuture() && !System.isBatch()) {
            sendAsync(buildAlert(high));
        }
    }
}
