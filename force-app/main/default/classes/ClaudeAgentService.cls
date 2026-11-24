/**
 * Entry point for LWCs on internal record pages. The agent runs in AWS as an integration user,
 * so this class decides whether the CURRENT user may use it for THIS record.
 */
public with sharing class ClaudeAgentService {
    // Read-only agents only. 'case-triage' writes a comment, so it is NOT listed here.
    // It runs from a background job (see examples/apex), never from a button a user can press.
    @TestVisible
    private static final Set<String> RECORD_AGENTS = new Set<String>{ 'case-summary' };
    private static final String GENERIC = 'The assistant is unavailable right now. Please try again.';

    @AuraEnabled
    public static String ask(String agent, String question, Id recordId) {
        if (!RECORD_AGENTS.contains(agent)) {
            throw fail('Unknown assistant.');
        }
        if (String.isBlank(question) || question.length() > 1000) {
            throw fail('Please enter 1 to 1000 characters.');
        }
        if (recordId == null || recordId.getSObjectType() != Case.SObjectType) {
            throw fail('This assistant works on a Case.');
        }
        // The user must be able to see the Case. Without this check the integration user's wider
        // access would let anyone summarize any Case Id.
        List<Case> visible = [SELECT Id FROM Case WHERE Id = :recordId WITH USER_MODE LIMIT 1];
        if (visible.isEmpty()) {
            throw fail('You do not have access to this Case.');
        }
        try {
            return ClaudeAgentClient.call(agent, question, recordId);
        } catch (Exception e) {
            // Timeouts, bad JSON and service errors all end here. Log for admins, show users a generic message.
            System.debug(LoggingLevel.ERROR, 'Claude agent call failed: ' + e.getTypeName());
            throw fail(GENERIC);
        }
    }

    private static AuraHandledException fail(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message); // without this, getMessage() returns a generic system string
        return e;
    }
}
