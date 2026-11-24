/**
 * Agentforce action: change the Priority of a Case identified by its case number.
 */
public with sharing class CaseTriageEscalateInvocable {
    public class Request {
        @InvocableVariable(label='Case Number' description='The case number, e.g. 00001002' required=true)
        public String caseNumber;
        @InvocableVariable(label='New Priority' description='High, Medium or Low' required=true)
        public String newPriority;
    }

    public class Result {
        @InvocableVariable(label='Message' description='Outcome of the update')
        public String message;
    }

    @InvocableMethod(
        label='Set Case Priority'
        description='Sets the priority of a case (High, Medium or Low) using its case number.'
        category='Case Triage'
    )
    public static List<Result> setPriority(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            try {
                if (req.newPriority == null || !new Set<String>{ 'High', 'Medium', 'Low' }.contains(req.newPriority)) {
                    r.message = 'Priority must be High, Medium or Low.';
                } else {
                    List<Case> found = [
                        SELECT Id, Priority FROM Case WHERE CaseNumber = :req.caseNumber WITH USER_MODE LIMIT 1
                    ];
                    if (found.isEmpty()) {
                        r.message = 'Case ' + req.caseNumber + ' was not found.';
                    } else {
                        String old = found[0].Priority;
                        found[0].Priority = req.newPriority;
                        update as user found;
                        r.message = 'Case ' + req.caseNumber + ' priority changed from ' + old + ' to ' + req.newPriority + '.';
                    }
                }
            } catch (Exception e) {
                r.message = 'Could not update case: ' + e.getMessage();
            }
            results.add(r);
        }
        return results;
    }
}
