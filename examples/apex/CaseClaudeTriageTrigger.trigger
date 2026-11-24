/**
 * Example, not deployed by default. Starts one triage job for each new High priority Case.
 * Salesforce allows 50 enqueueJob calls per transaction, so large data loads need a different path
 * (a Platform Event or a scheduled batch).
 */
trigger CaseClaudeTriageTrigger on Case(after insert) {
    Integer started = 0;
    for (Case c : Trigger.new) {
        // A Queueable may enqueue only one more job, and batch or future contexts must not start many.
        if (c.Priority == 'High' && started < 40 && !System.isBatch() && !System.isFuture() && !System.isQueueable()) {
            System.enqueueJob(new ClaudeTriageQueueable(c.Id));
            started++;
        }
    }
}
