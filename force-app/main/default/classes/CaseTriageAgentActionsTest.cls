@IsTest
private class CaseTriageAgentActionsTest {
    @TestSetup
    static void setup() {
        insert new List<Case>{
            new Case(Subject = 'A', Status = 'New', Priority = 'Low'),
            new Case(Subject = 'B', Status = 'New', Priority = 'High')
        };
    }

    @IsTest
    static void listsAllAndFiltered() {
        CaseTriageListInvocable.Request all = new CaseTriageListInvocable.Request();
        CaseTriageListInvocable.Request high = new CaseTriageListInvocable.Request();
        high.priority = 'High';
        List<CaseTriageListInvocable.Result> res = CaseTriageListInvocable.listOpenCases(
            new List<CaseTriageListInvocable.Request>{ all, high }
        );
        Assert.areEqual(2, res[0].caseCount);
        Assert.areEqual(1, res[1].caseCount);
    }

    @IsTest
    static void setsPriorityAndHandlesBadInput() {
        Case c = [SELECT CaseNumber FROM Case WHERE Subject = 'A'];
        CaseTriageEscalateInvocable.Request ok = new CaseTriageEscalateInvocable.Request();
        ok.caseNumber = c.CaseNumber;
        ok.newPriority = 'High';
        CaseTriageEscalateInvocable.Request badPrio = new CaseTriageEscalateInvocable.Request();
        badPrio.caseNumber = c.CaseNumber;
        badPrio.newPriority = 'Urgent';
        CaseTriageEscalateInvocable.Request missing = new CaseTriageEscalateInvocable.Request();
        missing.caseNumber = '99999999';
        missing.newPriority = 'High';
        List<CaseTriageEscalateInvocable.Result> res = CaseTriageEscalateInvocable.setPriority(
            new List<CaseTriageEscalateInvocable.Request>{ ok, badPrio, missing }
        );
        Assert.isTrue(res[0].message.contains('changed from Low to High'));
        Assert.isTrue(res[1].message.contains('must be'));
        Assert.isTrue(res[2].message.contains('not found'));
        Assert.areEqual('High', [SELECT Priority FROM Case WHERE Id = :c.Id].Priority);
    }
}
