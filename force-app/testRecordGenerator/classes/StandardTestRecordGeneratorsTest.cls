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
}