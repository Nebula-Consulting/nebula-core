/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 */

@IsTest
private class TestRecordSourceTest {

    @IsTest
    static void noMatchingMetadata() {
        TestRecordSource testRecords = new TestRecordSource(new List<Test_Record_Generator__mdt>());

        try {
            testRecords.getObjectWithInsert(Account.SObjectType);
        } catch (ClassNotFoundException e) {
            String message = e.getMessage();
            System.assert(message.contains('No Test_Record_Generator__mdt found'));
            return;
        }
        System.assert(false, 'Should have thrown exception');
    }

    @IsTest
    static void noApexClassImplementation() {
        String className = 'noSuchClass';
        TestRecordSource testRecords = new TestRecordSource(new List<Test_Record_Generator__mdt>{
                new Test_Record_Generator__mdt(
                        Apex_Class__c = className,
                        Priority__c = 0,
                        SObject__c = 'Account'
                )
        });

        try {
            testRecords.getObjectWithInsert(Account.SObjectType);
        } catch (ClassNotFoundException e) {
            String message = e.getMessage();
            System.assert(message.contains(className));
            return;
        }
        System.assert(false, 'Should have thrown exception');
    }
}