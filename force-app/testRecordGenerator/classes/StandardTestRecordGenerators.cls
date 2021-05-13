/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 22/11/2019
 * @description Read the JSON static resource to create Test_Record_Generator__mdt and Test_Record_Generator_Field__mdt
 * for standard objects. Results are emailed to the current user. Beware, this will overwrite existing definitions if
 * they have the same name
 */

global without sharing class StandardTestRecordGenerators {

    private class StandardTestRecordGenerator {
        Test_Record_Generator__mdt generator;
        List<Test_Record_Generator_Field__mdt> fields;
    }

    @TestVisible
    private Map<String, StandardTestRecordGenerator> allStandardGenerators;

    global StandardTestRecordGenerators() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'standard_test_record_generators_json' LIMIT 1];

        allStandardGenerators = (Map<String, StandardTestRecordGenerator>)JSON.deserialize(
                sr.Body.toString(),
                Map<String, StandardTestRecordGenerator>.class);
    }

    global StandardTestRecordGenerators deploy(SObjectType sObjectType) {
        return deploy(sObjectType.getDescribe().getName());
    }

    global StandardTestRecordGenerators deploy(String name) {
        Metadata.Operations.enqueueDeployment(
                getDeployContainerFor(name),
                new EmailResultsMetadataDeployCallback(UserInfo.getUserEmail())
        );
        return this;
    }

    public Metadata.DeployContainer getDeployContainerFor(String name) {
        Assertion.is(
                String.format('No standard metadata generators found for {0}. Existing definitions are: {1}',
                        new List<String>{ name, String.join(new List<String>(allStandardGenerators.keySet()), ',') }))
                .that(allStandardGenerators.containsKey(name));
        return getDeployContainerFor(allStandardGenerators.get(name));
    }

    private Metadata.DeployContainer getDeployContainerFor(StandardTestRecordGenerator standardTestRecordGenerator) {
        return (Metadata.DeployContainer)new LazySObjectIterator(standardTestRecordGenerator.fields)
                .mapValues(new DeployableMetadataFromSObject())
                .mapValues(new AddReferenceToGenerator(standardTestRecordGenerator.generator))
                .prepend(new DeployableMetadataFromSObject().call(standardTestRecordGenerator.generator))
                .reduce(new AddToDeployContainer(),  new Metadata.DeployContainer());
    }

    private class AddReferenceToGenerator implements Function {

        private Test_Record_Generator__mdt generator;
        private String generatorFieldName;

        public AddReferenceToGenerator(Test_Record_Generator__mdt generator) {
            this.generator = generator;
            this.generatorFieldName = Test_Record_Generator_Field__mdt.Test_Record_Generator__c.getDescribe().getName();
        }

        public Object call(Object o) {
            Metadata.CustomMetadata thisFieldMetadata = (Metadata.CustomMetadata)o;

            Metadata.CustomMetadataValue parentReferenceField = new Metadata.CustomMetadataValue();
            parentReferenceField.field = generatorFieldName;
            parentReferenceField.value = generator.DeveloperName;
            thisFieldMetadata.values.add(parentReferenceField);

            return thisFieldMetadata;
        }
    }

    private class AddToDeployContainer implements AccumulatorFunction {
        public Object nextValue(Object valueSoFar, Object thisValue) {
            ((Metadata.DeployContainer)valueSoFar).addMetadata((Metadata.Metadata)thisValue);
            return valueSoFar;
        }
    }
}