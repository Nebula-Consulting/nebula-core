/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 */

@IsTest
private class TestRecordSourceTest {

    static TestRecordSource testRecordSource = new TestRecordSource();

    @IsTest
    static void noMatchingMetadata() {
        testRecordSource = new TestRecordSource();

        try {
            testRecordSource.getRecord(Account.SObjectType).withInsert();
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

        testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = className,
                        Priority__c = 0,
                        SObject__c = 'Account'
                ));

        try {
            testRecordSource.getRecord(Account.SObjectType).withInsert();
        } catch (ClassNotFoundException e) {
            String message = e.getMessage();
            System.assert(message.contains(className));
            return;
        }
        System.assert(false, 'Should have thrown exception');
    }

    @IsTest
    static void setMetadata() {
        String accountName = 'Some wacky thing not in the metadata';

        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = accountName), 0);

        Account result = (Account)testRecordSource.getRecord(Account.SObjectType).withoutInsert();

        System.assertEquals(accountName, result.Name);
    }
}