@IsTest
private class ClaudeTriageQueueableTest {
    private static Integer calls = 0;
    private static String lastBody;

    private class Mock implements HttpCalloutMock {
        Integer status;
        Mock(Integer status) {
            this.status = status;
        }
        public HttpResponse respond(HttpRequest req) {
            calls++;
            lastBody = req.getBody();
            HttpResponse res = new HttpResponse();
            res.setStatusCode(status);
            res.setBody('{"answer":"done"}');
            return res;
        }
    }

    @TestSetup
    static void makeCase() {
        SlackCaseNotifier.webhookOverride = 'REPLACE_ME'; // keep the Slack alert trigger quiet
        insert new Case(Subject = 'Generator down', Status = 'New', Priority = 'Medium');
    }

    @IsTest
    static void callsTheTriageAgentForTheCase() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new Mock(200));
        Test.startTest();
        System.enqueueJob(new ClaudeTriageQueueable(c.Id));
        Test.stopTest();
        Assert.areEqual(1, calls);
        Assert.isTrue(lastBody.contains('case-triage'));
    }

    @IsTest
    static void aFailureDoesNotThrow() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new Mock(500));
        Test.startTest();
        System.enqueueJob(new ClaudeTriageQueueable(c.Id));
        Test.stopTest();
        Assert.areEqual(1, calls);
    }

    @IsTest
    static void aNewHighPriorityCaseStartsOneTriageJob() {
        SlackCaseNotifier.webhookOverride = 'REPLACE_ME';
        Test.setMock(HttpCalloutMock.class, new Mock(200));
        Test.startTest();
        insert new List<Case>{
            new Case(Subject = 'Urgent', Status = 'New', Priority = 'High'),
            new Case(Subject = 'Routine', Status = 'New', Priority = 'Low')
        };
        Test.stopTest();
        Assert.areEqual(1, calls); // only the High priority Case
    }
}
