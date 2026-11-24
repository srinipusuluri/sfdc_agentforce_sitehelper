/**
 * Example, not deployed by default. Runs the case-triage agent for ONE new Case in the background.
 * The agent reads the Case and adds an internal comment. A Queueable is used so the user's save never waits for AWS.
 * One Case per job, because all callouts in a transaction share a 120 second total.
 */
public with sharing class ClaudeTriageQueueable implements Queueable, Database.AllowsCallouts {
    private final Id caseId;

    public ClaudeTriageQueueable(Id caseId) {
        this.caseId = caseId;
    }

    public void execute(QueueableContext context) {
        try {
            ClaudeAgentClient.call('case-triage', 'Triage this new case.', caseId);
        } catch (Exception e) {
            // Triage is a helper. A failure must never break case handling.
            System.debug(LoggingLevel.ERROR, 'Claude triage failed for ' + caseId + ': ' + e.getMessage());
        }
    }
}
