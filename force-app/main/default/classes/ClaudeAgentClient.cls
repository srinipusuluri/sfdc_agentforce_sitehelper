/**
 * Calls the Claude agent hosted on AWS. The endpoint and the x-api-key secret live in the
 * Named Credential Claude_Agent_AWS, so neither appears in code.
 */
public with sharing class ClaudeAgentClient {
    public class AgentException extends Exception {
    }

    @TestVisible
    private static final String ENDPOINT = 'callout:Claude_Agent_AWS/';
    private static final Integer TIMEOUT_MS = 100000; // Apex allows up to 120 s per callout

    private class AgentResponse {
        public String answer;
    }

    public static String call(String agent, String question, Id recordId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(TIMEOUT_MS);
        req.setBody(JSON.serialize(new Map<String, Object>{ 'agent' => agent, 'question' => question, 'recordId' => recordId }));

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            // Log the status for admins. Show users a generic message.
            System.debug(LoggingLevel.ERROR, 'Claude agent call failed with status ' + res.getStatusCode());
            throw new AgentException('The assistant is unavailable right now. Please try again.');
        }
        AgentResponse parsed = (AgentResponse) JSON.deserialize(res.getBody(), AgentResponse.class);
        return parsed.answer;
    }
}
