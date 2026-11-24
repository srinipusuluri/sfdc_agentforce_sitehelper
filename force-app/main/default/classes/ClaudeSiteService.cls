/**
 * Entry point for the public Experience Cloud site. It exposes ONE agent (kb-answer) and accepts no record Id.
 * Grant the guest user profile access to this class only, never to ClaudeAgentService.
 */
public with sharing class ClaudeSiteService {
    @AuraEnabled
    public static String askKnowledge(String question) {
        if (String.isBlank(question) || question.length() > 300) {
            throw fail('Please ask a question of up to 300 characters.');
        }
        try {
            return ClaudeAgentClient.call('kb-answer', question.trim(), null);
        } catch (Exception e) {
            // Log for admins, show visitors a generic message. Never expose internal detail to a guest.
            System.debug(LoggingLevel.ERROR, 'Claude site call failed: ' + e.getTypeName());
            throw fail('The assistant is unavailable right now. Please try again.');
        }
    }

    private static AuraHandledException fail(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }
}
