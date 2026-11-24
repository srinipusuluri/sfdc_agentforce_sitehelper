/**
 * Schedulable job that posts the daily case digest to Slack.
 * Schedule: System.schedule('Slack case digest', '0 0 8 * * ?', new SlackCaseDigestJob());
 */
public with sharing class SlackCaseDigestJob implements Schedulable, Database.AllowsCallouts {
    public void execute(SchedulableContext sc) {
        SlackCaseNotifier.sendAsync(SlackCaseNotifier.buildDigest());
    }
}
