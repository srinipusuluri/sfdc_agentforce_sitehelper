@IsTest
private class ClaudeAgentServiceTest {
    // Static, because the platform does not hand back the mock instance's own state.
    private static String lastBody;

    // The Case trigger posts to Slack for High priority Cases. Keep it out of these tests.
    private static void quietSlack() {
        SlackCaseNotifier.webhookOverride = 'REPLACE_ME';
    }

    private class Mock implements HttpCalloutMock {
        Integer status;
        String body;
        Mock(Integer status, String body) {
            this.status = status;
            this.body = body;
        }
        public HttpResponse respond(HttpRequest req) {
            lastBody = req.getBody();
            HttpResponse res = new HttpResponse();
            res.setStatusCode(status);
            res.setBody(body);
            return res;
        }
    }

    @IsTest
    static void summarizesAVisibleCase() {
        quietSlack();
        Case c = new Case(Subject = 'Generator down', Status = 'New', Priority = 'Medium');
        insert c;
        Mock m = new Mock(200, '{"answer":"Short summary"}');
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        String out = ClaudeAgentService.ask('case-summary', 'Summarize', c.Id);
        Test.stopTest();
        Assert.areEqual('Short summary', out);
        Assert.isTrue(lastBody.contains('case-summary'));
        Assert.isTrue(lastBody.contains(c.Id));
    }

    @IsTest
    static void rejectsBadInputBeforeAnyCallout() {
        quietSlack();
        Case c = new Case(Subject = 'x', Status = 'New');
        insert c;
        Test.setMock(HttpCalloutMock.class, new Mock(200, '{"answer":"no"}'));
        for (List<Object> args : new List<List<Object>>{
            new List<Object>{ 'unknown', 'q', c.Id },
            new List<Object>{ 'case-triage', 'q', c.Id }, // writes, so not callable from the record page
            new List<Object>{ 'case-summary', '', c.Id },
            new List<Object>{ 'case-summary', 'q'.repeat(1001), c.Id },
            new List<Object>{ 'case-summary', 'q', null },
            new List<Object>{ 'case-summary', 'q', UserInfo.getUserId() }
        }) {
            try {
                ClaudeAgentService.ask((String) args[0], (String) args[1], (Id) args[2]);
                Assert.fail('Expected an AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isNotNull(e.getMessage());
            }
        }
    }

    @IsTest
    static void hidesServiceErrorsFromTheUser() {
        quietSlack();
        Case c = new Case(Subject = 'x', Status = 'New');
        insert c;
        Test.setMock(HttpCalloutMock.class, new Mock(500, 'internal stack trace'));
        Test.startTest(); // Test.startTest() starts a fresh transaction context, which allows a callout after the insert
        try {
            ClaudeAgentService.ask('case-summary', 'Summarize', c.Id);
            Assert.fail('Expected an AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isFalse(e.getMessage().contains('stack trace'));
            Assert.isTrue(e.getMessage().contains('unavailable'));
        }
        Test.stopTest();
    }

    @IsTest
    static void siteServiceAsksOnlyTheKnowledgeAgent() {
        quietSlack();
        Mock m = new Mock(200, '{"answer":"Change the oil every 100 hours."}');
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        String out = ClaudeSiteService.askKnowledge('How often should I change the oil?');
        Test.stopTest();
        Assert.isTrue(out.contains('100 hours'));
        Assert.isTrue(lastBody.contains('kb-answer'));
        try {
            ClaudeSiteService.askKnowledge('q'.repeat(301));
            Assert.fail('Expected an AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage());
        }
    }

    @IsTest
    static void siteServiceHidesServiceErrors() {
        quietSlack();
        Test.setMock(HttpCalloutMock.class, new Mock(500, 'internal stack trace'));
        Test.startTest();
        try {
            ClaudeSiteService.askKnowledge('What is covered by the warranty?');
            Assert.fail('Expected an AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isFalse(e.getMessage().contains('stack trace'));
            Assert.isTrue(e.getMessage().contains('unavailable'));
        }
        Test.stopTest();
    }

    private class ThrowingMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Read timed out: internal host detail');
        }
    }

    @IsTest
    static void aTimeoutIsReportedGenerically() {
        quietSlack();
        Case c = new Case(Subject = 'x', Status = 'New', Priority = 'Medium');
        insert c;
        Test.setMock(HttpCalloutMock.class, new ThrowingMock());
        Test.startTest();
        try {
            ClaudeAgentService.ask('case-summary', 'Summarize', c.Id);
            Assert.fail('Expected an AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isFalse(e.getMessage().contains('internal host detail'));
            Assert.isTrue(e.getMessage().contains('unavailable'));
        }
        try {
            ClaudeSiteService.askKnowledge('What is covered by the warranty?');
            Assert.fail('Expected an AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isFalse(e.getMessage().contains('internal host detail'));
        }
        Test.stopTest();
    }
}
