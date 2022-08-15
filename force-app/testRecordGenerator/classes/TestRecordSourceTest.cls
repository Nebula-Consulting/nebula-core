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
            testRecordSource.getRecord(Lead.SObjectType).withInsert();
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
            testRecordSource.getRecord(Account.SObjectType).asVariant('Not ' + variantName).withInsert();
        } catch (ClassNotFoundException e) {
            String message = e.getMessage();
            System.assert(message.contains('No Test_Record_Generator__mdt found'));
            System.assert(message.contains(variantName));
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
    static void inheritanceFromNoVariant() {
        String accountName = 'Some wacky thing not in the metadata';
        String accountDescription = 'A description';
        String variantName = 'Derived Account';

        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = accountName), 0);
        Test_Record_Generator__mdt recordGeneratorMetadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        Priority__c = 0,
                        SObject__c = 'Account',
                        Variant__c = variantName
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = recordGeneratorMetadata.Id,
                        Field__c = 'Description',
                        Value__c = accountDescription
                )
        });

        Account result = (Account)testRecordSource.getRecord(Account.SObjectType).asVariant(variantName).withoutInsert();

        System.assertEquals(accountName, result.Name);
        System.assertEquals(accountDescription, result.Description);
    }
    @IsTest
    static void inheritanceTwoLevels() {
        String accountName = 'Some wacky thing not in the metadata';
        String accountDescription = 'A description';
        String accountWebsite = 'https://www.salesforce.com';
        String variantName = 'Derived Account';
        String variantName2 = 'Derived Account 2';

        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = accountName), 0);
        Test_Record_Generator__mdt recordGeneratorMetadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        Priority__c = 0,
                        SObject__c = 'Account',
                        Variant__c = variantName
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = recordGeneratorMetadata.Id,
                        Field__c = 'Description',
                        Value__c = accountDescription
                )
        });
        Test_Record_Generator__mdt recordGeneratorMetadata2 = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        Priority__c = 0,
                        SObject__c = 'Account',
                        Variant__c = variantName2,
                        Inherits_From_Variant__c = variantName
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = recordGeneratorMetadata2.Id,
                        Field__c = 'Website',
                        Value__c = accountWebsite
                )
        });

        Account result = (Account)testRecordSource.getRecord(Account.SObjectType).asVariant(variantName2).withoutInsert();

        System.assertEquals(accountWebsite, result.Website);
        System.assertEquals(accountDescription, result.Description);
        System.assertEquals(accountName, result.Name);
    }

    @IsTest
    static void variantNoBase() {
        String accountDescription = 'A description';
        String variantName = 'Derived Account';

        Test_Record_Generator__mdt recordGeneratorMetadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        Priority__c = 0,
                        SObject__c = 'Account',
                        Variant__c = variantName
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = recordGeneratorMetadata.Id,
                        Field__c = 'Description',
                        Value__c = accountDescription
                )
        });

        Account result = (Account)testRecordSource.getRecord(Account.SObjectType).asVariant(variantName).withoutInsert();

        System.assertEquals(accountDescription, result.Description);
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
    static void withoutInsertPutValue() {
        String accountName = 'Test Account';
        String accountDescription = 'Widgets';

        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = accountName), -1000);

        Test.startTest();
        Account result = (Account)testRecordSource.getRecord(Account.SObjectType)
                .put(Account.Description, accountDescription)
                .withoutInsert();
        Test.stopTest();

        System.assertEquals(accountName, result.Name);
        System.assertEquals(accountDescription, result.Description);
    }

    @IsTest
    static void withoutInsertPutValueMultiple() {
        String accountName = 'Test Account';
        String accountDescription = 'Widgets';

        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = accountName), -1000);

        Test.startTest();
        Account result = (Account)testRecordSource.getRecord(Account.SObjectType)
                .put(Account.Description, accountDescription)
                .withoutInsert(1)[0];
        Test.stopTest();

        System.assertEquals(accountName, result.Name);
        System.assertEquals(accountDescription, result.Description);
    }

    @IsTest
    static void recordInsertFailure() {
        testRecordSource.addTemporaryMetadataFromInstance(new Account(), null);

        Test.startTest();
        try {
            testRecordSource.getRecord(Account.SObjectType).withInsert();
        } catch (TestRecordGeneratorException e) {
            return;
        }
        Test.stopTest();
        System.assert(false, 'Should have thrown exception');
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
    @IsTest
    static void asVariantAfterPut() {
        String accountName = 'Some wacky thing not in the metadata';
        String accountDescription = 'A description';
        String accountStreet = '123 Lane';
        String variantName = 'Derived Account';

        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = accountName), 0);
        Test_Record_Generator__mdt recordGeneratorMetadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        Priority__c = 0,
                        SObject__c = 'Account',
                        Variant__c = variantName
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = recordGeneratorMetadata.Id,
                        Field__c = 'Description',
                        Value__c = accountDescription
                )
        });

        Account result = (Account)testRecordSource.getRecord(Account.SObjectType)
                .put(Account.BillingStreet, accountStreet)
                .asVariant(variantName)
                .withoutInsert();

        System.assertEquals(accountName, result.Name);
        System.assertEquals(accountDescription, result.Description);
        System.assertEquals(accountStreet, result.BillingStreet);
    }
}