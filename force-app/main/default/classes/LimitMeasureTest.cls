/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 06/08/2018
 */

@IsTest
@SuppressWarnings('PMD.AvoidDmlStatementsInLoops')
private class LimitMeasureTest {

    private static TestRecordSource testRecordSource = new TestRecordSource();

    private static LimitMeasure.DmlStatementsLimitDatum dmlStatementsLimitDatum = new LimitMeasure.DmlStatementsLimitDatum(0);

    private static List<LimitDatum> testLimits = new List<LimitDatum> {
            new LimitMeasure.CalloutLimitDatum(0),
            dmlStatementsLimitDatum,
            new LimitMeasure.SoqlQueriesLimitDatum(0),
            new LimitMeasure.CpuTimeLimitDatum(0)
    };

    private static final Long LESS_THAN_DML_LIMIT = 1; // TOG inserts an Account

    static {
        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = 'Test Account'), -1000);
        testRecordSource.getObject(Account.SObjectType).withInsert();
    }

    @IsTest
    static void dmlStatementsLimit() {
        LimitMeasure limitMeasure = new LimitMeasure(testLimits);

        while(limitMeasure.hasEnoughForAnotherIteration()) {
            insert testRecordSource.getObject(Account.SObjectType).withoutInsert();
        }

        System.assertEquals(Limits.getLimitDmlStatements(), [SELECT COUNT() FROM Account]);
    }

    @IsTest static void dmlStatementsLimitWithHeadroom() {
        Integer headroom = 50;
        dmlStatementsLimitDatum.headroom = headroom;
        LimitMeasure theLimitMeasure = new LimitMeasure(testLimits);

        while(theLimitMeasure.hasEnoughForAnotherIteration()) {
            insert testRecordSource.getObject(Account.SObjectType).withoutInsert();
        }

        System.assertEquals(Limits.getLimitDmlStatements() - headroom, [SELECT COUNT() FROM Account]);

        theLimitMeasure.clear();

        System.assertEquals(Limits.getDmlStatements(), dmlStatementsLimitDatum.lastMeasure);
        System.assertEquals(0, dmlStatementsLimitDatum.costPerIteration);
    }
}