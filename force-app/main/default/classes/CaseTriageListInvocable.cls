/**
 * Agentforce action: list open (non-closed) Cases, optionally filtered by priority.
 * Runs in user mode so the agent only sees what the running user can see.
 */
public with sharing class CaseTriageListInvocable {
    private static final Integer MAX_ROWS = 10;

    public class Request {
        @InvocableVariable(label='Priority' description='Optional: High, Medium or Low. Leave blank for all open cases.')
        public String priority;
    }

    public class Result {
        @InvocableVariable(label='Summary' description='Human-readable list of the matching open cases')
        public String summary;
        @InvocableVariable(label='Case Count')
        public Integer caseCount;
    }

    @InvocableMethod(
        label='List Open Cases'
        description='Returns up to 10 open cases (newest first), optionally filtered by priority.'
        category='Case Triage'
    )
    public static List<Result> listOpenCases(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            String prio = String.isBlank(req.priority) ? null : req.priority.trim();
            List<Case> cases;
            if (prio == null) {
                cases = [
                    SELECT CaseNumber, Subject, Status, Priority, Account.Name
                    FROM Case
                    WHERE IsClosed = FALSE
                    WITH USER_MODE
                    ORDER BY CreatedDate DESC
                    LIMIT :MAX_ROWS
                ];
            } else {
                cases = [
                    SELECT CaseNumber, Subject, Status, Priority, Account.Name
                    FROM Case
                    WHERE IsClosed = FALSE AND Priority = :prio
                    WITH USER_MODE
                    ORDER BY CreatedDate DESC
                    LIMIT :MAX_ROWS
                ];
            }
            List<String> lines = new List<String>();
            for (Case c : cases) {
                lines.add(
                    c.CaseNumber + ' | ' + c.Priority + ' | ' + c.Status + ' | ' +
                    (c.Account.Name == null ? 'No account' : c.Account.Name) + ' | ' + c.Subject
                );
            }
            Result r = new Result();
            r.caseCount = cases.size();
            r.summary = cases.isEmpty() ? 'No open cases found.' : String.join(lines, '\n');
            results.add(r);
        }
        return results;
    }
}
