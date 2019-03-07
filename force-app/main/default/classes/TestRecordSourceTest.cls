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
            testRecords.getObject(Account.SObjectType).withInsert();
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
            testRecords.getObject(Account.SObjectType).withInsert();
        } catch (ClassNotFoundException e) {
            String message = e.getMessage();
            System.assert(message.contains(className));
            return;
        }
        System.assert(false, 'Should have thrown exception');
    }

    @IsTest
    static void setMetadata() {
        TestRecordSource testRecords = new TestRecordSource();
        String accountName = 'Some wacky thing not in the metadata';

        testRecords.setMetadata(
                new Account(Name = accountName),
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        Priority__c = 0,
                        SObject__c = 'Account'
                )
        );

        Account result = (Account)testRecords.getObject(Account.SObjectType).withoutInsert();

        System.assertEquals(accountName, result.Name);
    }
}