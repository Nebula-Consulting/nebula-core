/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-07
 */

@IsTest
private class TestFieldFunctionsTest {

    private static TestRecordSource testRecordSource = new TestRecordSource();
    private static String accountName = 'Test Account';

    @IsTest
    static void appendRandomNumber() {
        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'Name',
                        Apex_Class__c = TestFieldFunctions.AppendRandomNumber.class.getName(),
                        Value__c = accountName
                )
        });

        Account result = (Account)testRecordSource.getRecord(Account.SObjectType).withoutInsert();

        System.assert(result.Name.contains(accountName));
        System.assert(result.Name.length() > accountName.length(), result.Name);
    }

    @IsTest
    static void now() {
        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'EmailMessage'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'FirstOpenedDate',
                        Apex_Class__c = TestFieldFunctions.Now.class.getName()
                )
        });

        EmailMessage result = (EmailMessage)testRecordSource.getRecord(EmailMessage.SObjectType).withoutInsert();

        Datetime target = Datetime.now();
        System.assert(result.FirstOpenedDate > target.addMinutes(-1) && result.FirstOpenedDate < target.addMinutes(1) );
    }

    @IsTest
    static void nowModified() {
        Integer addDays = 1;
        Integer addMinutes = 60;

        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'EmailMessage'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'FirstOpenedDate',
                        Apex_Class__c = TestFieldFunctions.Now.class.getName(),
                        Apex_Class_Parameters__c = JSON.serialize(new Map<String, Object>{
                                'addDays' => addDays,
                                'addMinutes' => addMinutes
                        })
                )
        });

        EmailMessage result = (EmailMessage)testRecordSource.getRecord(EmailMessage.SObjectType).withoutInsert();

        Datetime target = Datetime.now().addMinutes(addMinutes).addDays(addDays);
        System.assert(result.FirstOpenedDate > target.addMinutes(-1) && result.FirstOpenedDate < target.addMinutes(1) );
    }

    @IsTest
    static void createRecord() {
        // Create a standard variant of Account
        appendRandomNumber();

        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account',
                        Variant__c = 'With Parent'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'Name',
                        Apex_Class__c = TestFieldFunctions.AppendRandomNumber.class.getName(),
                        Value__c = accountName
                ),
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'ParentId',
                        Apex_Class__c = TestFieldFunctions.CreateRecord.class.getName(),
                        Apex_Class_Parameters__c = '{"sObjectType": "Account"}'
                )
        });

        Account testAccount = (Account)testRecordSource
                .getRecord(Account.SObjectType)
                .asVariant('With Parent')
                .withInsert();

        Account parent = [SELECT Id FROM Account WHERE Id != :testAccount.Id];

        System.assertEquals(parent.Id, testAccount.ParentId);
    }

    @IsTest
    static void createRecordWithParameterVariant() {
        // Create a standard variant of Account
        appendRandomNumber();

        Test_Record_Generator__mdt metadataWithParent = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account',
                        Variant__c = 'With Parent'
                ));
        Test_Record_Generator__mdt metadataAsAcme = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account',
                        Variant__c = 'ACME'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadataWithParent.Id,
                        Field__c = 'Name',
                        Apex_Class__c = TestFieldFunctions.AppendRandomNumber.class.getName(),
                        Value__c = accountName
                ),
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadataWithParent.Id,
                        Field__c = 'ParentId',
                        Apex_Class__c = TestFieldFunctions.CreateRecord.class.getName(),
                        Apex_Class_Parameters__c = '{"sObjectType": "Account", "variantParameter": "parentVariant"}'
                )
        });
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadataAsAcme.Id,
                        Field__c = 'Name',
                        Value__c = 'ACME'
                )
        });

        Account testAccount = (Account)testRecordSource
                .getRecord(Account.SObjectType)
                .asVariant('With Parent')
                .useParameters(new Map<String, Object>{'parentVariant' => 'ACME'})
                .withInsert();

        Account parent = [SELECT Id, Name FROM Account WHERE Id != :testAccount.Id];

        System.assertEquals(parent.Id, testAccount.ParentId);
        System.assertEquals('ACME', parent.Name);
    }

    @IsTest
    static void increment() {
        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'NumberOfEmployees',
                        Apex_Class__c = TestFieldFunctions.Increment.class.getName(),
                        Apex_Class_Parameters__c = '{"increment": 1, "accumulator": 0}',
                        Value__c = '0'
                )
        });
        Integer nAccounts = 5;
        List<Account> results = testRecordSource.getRecord(Account.SObjectType).withoutInsert(nAccounts);

        System.assertEquals(nAccounts, results.size());
        for(Integer i=0; i < nAccounts; i++) {
            System.assertEquals(i, results[i].NumberOfEmployees);
        }
    }

    @IsTest
    static void readParameterByName() {
        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'Name',
                        Apex_Class__c = TestFieldFunctions.ReadParameter.class.getName()
                )
        });

        Account result = (Account)testRecordSource
                .getRecord(Account.SObjectType)
                .useParameters(new Map<String, Object>{'Name' => accountName})
                .withoutInsert();

        System.assertEquals(accountName, result.Name);
    }

    @IsTest
    static void readParameterByCustomName() {
        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'Name',
                        Apex_Class__c = TestFieldFunctions.ReadParameter.class.getName(),
                        Apex_Class_Parameters__c = '{"parameterName": "AccountName"}'
                )
        });

        Account result = (Account)testRecordSource
                .getRecord(Account.SObjectType)
                .useParameters(new Map<String, Object>{'AccountName' => accountName})
                .withoutInsert();

        System.assertEquals(accountName, result.Name);
    }
}