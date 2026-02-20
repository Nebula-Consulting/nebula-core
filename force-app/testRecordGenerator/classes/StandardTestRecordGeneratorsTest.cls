/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 27/11/2019
 */

@IsTest
private class StandardTestRecordGeneratorsTest {

    @IsTest
    static void testBehavior() {
        StandardTestRecordGenerators standardTestRecordGenerators = new StandardTestRecordGenerators();

        Test.startTest();
        Metadata.DeployContainer result = standardTestRecordGenerators.getDeployContainerFor(Product2.SObjectType.getDescribe().getName());
        Test.stopTest();

        List<Metadata.Metadata> resultMetadata = result.getMetadata();
        System.assertEquals(2, resultMetadata.size());

        Metadata.CustomMetadata testRecordGeneratorMetadata = (Metadata.CustomMetadata)resultMetadata[0];
        System.assertEquals('nebc__Test_Record_Generator.Product', testRecordGeneratorMetadata.fullName);
        List<Metadata.CustomMetadataValue> testRecordGeneratorMetadataValues = testRecordGeneratorMetadata.values;
        System.assertEquals(3, testRecordGeneratorMetadataValues.size());
        Metadata.CustomMetadata testRecordGeneratorFieldMetadata = (Metadata.CustomMetadata)resultMetadata[1];
        System.assertEquals('nebc__Test_Record_Generator_Field.Product_Name', testRecordGeneratorFieldMetadata.fullName);
    }

    @IsTest
    static void noSuchObject() {
        StandardTestRecordGenerators standardTestRecordGenerators = new StandardTestRecordGenerators();

        Test.startTest();
        try {
            standardTestRecordGenerators.getDeployContainerFor('Nope');
        } catch (AssertionException e) {
            return;
        }
        Test.stopTest();

        System.assert(false, 'Should have thrown an exception');
    }

    @IsTest
    static void jsonSupplied() {
        String testProductJson = '{\n' +
                '    "Product2": {\n' +
                '        "generator": {\n' +
                '            "MasterLabel": "Product",\n' +
                '            "DeveloperName": "Product",\n' +
                '            "nebc__Apex_Class__c": "nebc.TestMetadataRecordGenerator",\n' +
                '            "nebc__Priority__c": 0,\n' +
                '            "nebc__SObject__c": "Product2"\n' +
                '        },\n' +
                '        "fields": [\n' +
                '            {\n' +
                '                "MasterLabel": "Product: Name",\n' +
                '                "DeveloperName": "Product_Name",\n' +
                '                "nebc__Field__c": "Name",\n' +
                '                "nebc__Value__c": "Test Product"\n' +
                '            },\n' +
                '            {\n' +
                '                "MasterLabel": "Product: IsActive",\n' +
                '                "DeveloperName": "Product_IsActive",\n' +
                '                "nebc__Field__c": "IsActive",\n' +
                '                "nebc__Value__c": "false"\n' +
                '            }\n' +
                '        ]\n' +
                '    }\n' +
                '}';

        Test.startTest();
        Metadata.DeployContainer result = new StandardTestRecordGenerators(testProductJson).getDeployContainerFor('Product2');
        Test.stopTest();

        List<Metadata.Metadata> resultMetadata = result.getMetadata();
        Assert.areEqual(3, resultMetadata.size());
    }

    @IsTest
    static void standardTestRecordFieldOverride() {
        Map<String, String> fieldsToOverride = new Map<String, String>{'LanguageLocaleKey' => 'en_GB'};

        StandardTestRecordGenerators standardTestRecordGenerators = new StandardTestRecordGenerators();

        Test.startTest();
        Metadata.DeployContainer result = standardTestRecordGenerators.getDeployContainerFor(User.SObjectType.getDescribe().getName(), fieldsToOverride);
        Test.stopTest();

        List<Metadata.Metadata> resultMetadata = result.getMetadata();
        System.assertEquals(13, resultMetadata.size());

        for (Metadata.Metadata metadata : resultMetadata) {
            if (metadata.fullName == 'nebc__Test_Record_Generator_Field.User_Language_Locale_Key') {
                Metadata.CustomMetadata testRecordGeneratorMetadata = (Metadata.CustomMetadata) metadata;
                List<Metadata.CustomMetadataValue> testRecordGeneratorMetadataValues = testRecordGeneratorMetadata.values;

                for (Metadata.CustomMetadataValue metadataValue : testRecordGeneratorMetadataValues) {
                    if (metadataValue.field == 'nebc__value__c') {
                        Assert.areEqual(fieldsToOverride.get(fieldsToOverride.keySet().iterator().next()), metadataValue.value);
                    }
                }
            }
        }
    }
}