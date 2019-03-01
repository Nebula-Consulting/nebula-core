/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */
public inherited sharing class TestRecords {

    private static final String GENERATOR_SOBJECT_FIELD = Test_Record_Generator__mdt.SObject__c.getDescribe().getName();
    private static final String GENERATOR_VARIANT_FIELD = Test_Record_Generator__mdt.Variant__c.getDescribe().getName();

    private SObjectIndex generatorMetadata {get {
        if(generatorMetadata == null) {
            generatorMetadata = new SObjectIndex(
                    new List<String>{ GENERATOR_SOBJECT_FIELD, GENERATOR_VARIANT_FIELD})
                    .putAll(
                    [
                            SELECT Apex_Class__c, Priority__c, SObject__c, Variant__c, Parameters__c
                            FROM Test_Record_Generator__mdt
                            ORDER BY Priority__c ASC
                    ]);
        }
        return generatorMetadata;
    } set;}

    private Map<Id, TestRecordGenerator> generators;

    public TestRecords() {
        generators = new Map<Id, TestRecordGenerator>();
    }

    private TestRecordGenerator getGenerator(SObjectType objectType, String variant) {
        Test_Record_Generator__mdt thisGeneratorMetadata = (Test_Record_Generator__mdt) generatorMetadata.get(
                new Map<String, Object>{
                        GENERATOR_SOBJECT_FIELD => objectType.getDescribe().getName(),
                        GENERATOR_VARIANT_FIELD => variant
                });
        if(thisGeneratorMetadata == null) {
            throw new ClassNotFoundException(
                    'No Test_Record_Generator__mdt found for '
                            + objectType.getDescribe().getName()
                            + (variant != null ? ', variant: ' + variant : ''));
        } else {
            return getGenerator(thisGeneratorMetadata);
        }
    }

    private TestRecordGenerator getGenerator(Test_Record_Generator__mdt thisGeneratorMetadata) {
        TestRecordGenerator returnGenerator = generators.get(thisGeneratorMetadata.Id);
        if(returnGenerator == null) {
            returnGenerator = createGenerator(thisGeneratorMetadata);
        }
        return returnGenerator;
    }

    private TestRecordGenerator createGenerator(Test_Record_Generator__mdt thisGeneratorMetadata) {
        Type generatorType = TypeLoader.getType(thisGeneratorMetadata.Apex_Class__c);
        if (generatorType == null) {
            throw new ClassNotFoundException('No matching class found for ' + thisGeneratorMetadata.Apex_Class__c +
                    '. Check that it is global and that the namespace is included.');
        } else {
            TestRecordGenerator newGenerator = (TestRecordGenerator)TypeLoader.getInstance(generatorType, thisGeneratorMetadata.Parameters__c);
            newGenerator.parentTestRecords = this;
            generators.put(thisGeneratorMetadata.Id, newGenerator);
            return newGenerator;
        }
    }

    public SObject getObjectNoInsert(SObjectType objectType) {
        return getObjectNoInsert(objectType, null, null);
    }
    public SObject getObjectNoInsert(SObjectType objectType, String variant) {
        return getObjectNoInsert(objectType, variant, null);
    }
    public SObject getObjectNoInsert(SObjectType objectType, String variant, Map<String, Object> params) {
        return getGenerator(objectType, variant).getObjectNoInsert(params);
    }

    public SObject getObjectWithInsert(SObjectType objectType) {
        return getObjectWithInsert(objectType, null, null);
    }
    public SObject getObjectWithInsert(SObjectType objectType, String variant) {
        return getObjectWithInsert(objectType, variant, null);
    }
    public SObject getObjectWithInsert(SObjectType objectType, String variant, Map<String, Object> params) {
        return getGenerator(objectType, variant).getObjectWithInsert(params);
    }
}