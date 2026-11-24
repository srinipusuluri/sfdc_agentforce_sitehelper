@IsTest
private class SlackCaseNotifierTest {
    private class Mock implements HttpCalloutMock {
        public Integer calls = 0;
        public HttpResponse respond(HttpRequest req) {
            calls++;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }

    // Tests must not depend on the org's real webhook label. Pin it in every test.
    private static void withoutWebhook() {
        SlackCaseNotifier.webhookOverride = 'REPLACE_ME';
    }

    @IsTest
    static void digestCountsOpenCasesByPriority() {
        withoutWebhook();
        insert new List<Case>{
            new Case(Subject = 'a', Status = 'New', Priority = 'High'),
            new Case(Subject = 'b', Status = 'New', Priority = 'Low')
        };
        String d = SlackCaseNotifier.buildDigest();
        Assert.isTrue(d.contains('High: 1'));
        Assert.isTrue(d.contains('Low: 1'));
    }

    @IsTest
    static void doesNothingWithoutWebhook() {
        withoutWebhook();
        Mock m = new Mock();
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        insert new Case(Subject = 'c', Status = 'New', Priority = 'High');
        Test.stopTest();
        Assert.areEqual(0, m.calls);
    }

    @IsTest
    static void highPriorityInsertPostsOnce() {
        SlackCaseNotifier.webhookOverride = 'https://hooks.slack.com/services/T/B/X';
        Mock m = new Mock();
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        insert new List<Case>{
            new Case(Subject = 'd', Status = 'New', Priority = 'High'),
            new Case(Subject = 'e', Status = 'New', Priority = 'Low')
        };
        Test.stopTest();
        Assert.areEqual(1, m.calls);
    }

    @IsTest
    static void digestJobPosts() {
        SlackCaseNotifier.webhookOverride = 'https://hooks.slack.com/services/T/B/X';
        Mock m = new Mock();
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        new SlackCaseDigestJob().execute(null);
        Test.stopTest();
        Assert.areEqual(1, m.calls);
    }
}
