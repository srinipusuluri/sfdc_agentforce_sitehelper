trigger CaseSlackAlertTrigger on Case (after insert) {
    SlackCaseNotifier.alertHighPriority(Trigger.new);
}
