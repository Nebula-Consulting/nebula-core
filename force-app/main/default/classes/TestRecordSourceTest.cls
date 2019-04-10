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
    static void noMatchingVariant() {
        String variantName = 'My Variant';
        testRecordSource = new TestRecordSource();
        testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Priority__c = 0,
                        SObject__c = 'Account',
                        Variant__c = variantName
                ));

        try {
            testRecordSource.getRecord(Account.SObjectType).withInsert();
        } catch (ClassNotFoundException e) {
            String message = e.getMessage();
            System.assert(message.contains('No Test_Record_Generator__mdt found'));
            System.assert(message.contains('variantName'));
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

    @IsTest
    static void withoutInsert() {
        String accountName = 'Test Account';
        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = accountName), -1000);

        Test.startTest();
        Account result = (Account)testRecordSource.getRecord(Account.SObjectType).withoutInsert();
        Test.stopTest();

        System.assertEquals(accountName, result.Name);
    }

    @IsTest
    static void withoutInsertMultiple() {
        String accountName = 'Test Account';
        Test_Record_Generator__mdt recordGeneratorMetadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        Priority__c = 0,
                        SObject__c = 'Account'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
            new Test_Record_Generator_Field__mdt(
                    Test_Record_Generator__c = recordGeneratorMetadata.Id,
                    Field__c = 'Name',
                    Value__c = accountName,
                    Apex_Class__c = TestFieldFunctions.AppendRandomNumber.class.getName()
            )
        });

        List<Account> results = testRecordSource.getRecord(Account.SObjectType).withoutInsert(2);

        System.assertEquals(2, results.size());
        System.assertNotEquals(results[0].Name, results[1].Name);
        System.assert(results[0].Name.startsWith(accountName));
        System.assert(results[1].Name.startsWith(accountName));
    }

    @IsTest
    static void withInsertMultiple() {
        String accountName = 'Test Account';
        Test_Record_Generator__mdt recordGeneratorMetadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        Priority__c = 0,
                        SObject__c = 'Account'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = recordGeneratorMetadata.Id,
                        Field__c = 'Name',
                        Value__c = accountName,
                        Apex_Class__c = TestFieldFunctions.AppendRandomNumber.class.getName()
                )
        });

        List<Account> results = testRecordSource.getRecord(Account.SObjectType).withInsert(2);

        System.assertEquals(2, results.size());
        System.assertNotEquals(results[0].Name, results[1].Name);
        System.assert(results[0].Name.startsWith(accountName));
        System.assert(results[1].Name.startsWith(accountName));
    }
}