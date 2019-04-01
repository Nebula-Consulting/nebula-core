/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */
global inherited sharing class TestRecordSource {

    private static final String GENERATOR_SOBJECT_FIELD = Test_Record_Generator__mdt.SObject__c.getDescribe().getName();
    private static final String GENERATOR_VARIANT_FIELD = Test_Record_Generator__mdt.Variant__c.getDescribe().getName();

    private SObjectIndex generatorMetadata {get {
        if(generatorMetadata == null) {
            generatorMetadata = new SObjectIndex(
                    new List<String>{ GENERATOR_SOBJECT_FIELD, GENERATOR_VARIANT_FIELD})
                    .putAll(
                    [
                            SELECT Apex_Class__c, Priority__c, SObject__c, Variant__c, Parameters__c, DeveloperName
                            FROM Test_Record_Generator__mdt
                            ORDER BY Priority__c DESC
                    ]);
        }
        return generatorMetadata;
    } set;}

    private SObjectIndex generatorFieldMetadata {get {
        if(generatorFieldMetadata == null) {
            generatorFieldMetadata = new SObjectIndex(
                    Test_Record_Generator_Field__mdt.Test_Record_Generator__c.getDescribe().getName())
                    .putAll(
                    [
                            SELECT Test_Record_Generator__c, Field__c, Value__c, Apex_Class__c,
                                    Apex_Class_Parameters__c
                            FROM Test_Record_Generator_Field__mdt
                    ]);
        }
        return generatorFieldMetadata;
    } set;}

    private Map<Id, TestRecordGenerator> generators;

    global TestRecordSource() {
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
            newGenerator.setup(this, thisGeneratorMetadata, generatorFieldMetadata.getAll(thisGeneratorMetadata.Id));
            generators.put(thisGeneratorMetadata.Id, newGenerator);
            return newGenerator;
        }
    }

    global GetBuilder getRecord(SObjectType sObjectType) {
        return new GetBuilder(this, sObjectType);
    }

    global class GetBuilder {
        private TestRecordSource parent;
        private SObjectType sObjectType;
        private String variant;
        private Map<String, Object> parameters;

        private GetBuilder(TestRecordSource parent, SObjectType sObjectType) {
            this.parent = parent;
            this.sObjectType = sObjectType;
        }

        global GetBuilder asVariant(String variant) {
            this.variant = variant;
            return this;
        }

        global GetBuilder useParameters(Map<String, Object> parameters) {
            this.parameters = parameters;
            return this;
        }

        private TestRecordGenerator getGenerator() {
            return parent.getGenerator(sObjectType, variant);
        }

        global SObject withInsert() {
            return getGenerator().getRecordWithInsert(parameters);
        }

        global SObject withoutInsert() {
            return getGenerator().getRecordWithoutInsert(parameters);
        }

        global List<SObject> withoutInsert(Integer numberOfRecords) {
            return getGenerator().getRecordsWithoutInsert(numberOfRecords, parameters);
        }
        global List<SObject> withInsert(Integer numberOfRecords) {
            return getGenerator().getRecordsWithInsert(numberOfRecords, parameters);
        }
    }

    global void setRecordAsVariant(SObject record, String variant) {
        getGenerator(record.getSObjectType(), variant).setRecord(record);
    }
    global void setRecord(SObject record) {
        setRecordAsVariant(record, null);
    }

    private class TestRecordGeneratorPriorityComparator implements Comparator {
        public Integer compare(Object object1, Object object2) {
            Decimal priority1 = ((Test_Record_Generator__mdt)object1).Priority__c;
            Decimal priority2 = ((Test_Record_Generator__mdt)object2).Priority__c;
            if(priority1 == null && priority2 == null) {
                return 0;
            } else if(priority1 == null || priority2 == null) {
                return priority1 == null ? 1 : -1;
            } else {
                return (Integer)(priority1 - priority2);
            }
        }
    }

    private static Integer metadataIdNumber = 1;

    private Id getNextMetadataId() {
        return Test_Record_Generator__mdt.SObjectType.getDescribe().getKeyPrefix()
                + String.valueOf(metadataIdNumber++).leftPad(4, '0')
                + '0'.repeat(8);
    }

    /**
     * Adds a Test_Record_Generator__mdt to this instance without it being in the org. For test TestRecordSource without
     * packaging any metadata records
     *
     * @param metadataRecord
     *
     * @return the metadataRecord, with a made-up Id filled in
     */
    public Test_Record_Generator__mdt addTemporaryMetadata(Test_Record_Generator__mdt metadataRecord) {
        metadataRecord.Id = getNextMetadataId();

        List<Test_Record_Generator__mdt> existingMatches = generatorMetadata.getAll(metadataRecord);
        if(existingMatches.isEmpty()) {
            generatorMetadata.put(metadataRecord);
        } else {
            existingMatches.add(metadataRecord);
            Lists.sort(existingMatches, new TestRecordGeneratorPriorityComparator());
        }
        return metadataRecord;
    }

    /**
     * Like addTemporaryMetadata(Test_Record_Generator__mdt), but for fields
     *
     * @param metadataFields
     */
    public void addTemporaryMetadataFields(List<Test_Record_Generator_Field__mdt> metadataFields) {
        generatorFieldMetadata.putAll(metadataFields);
    }

    /**
     * Like addTemporaryMetadata(Test_Record_Generator__mdt), but makes it easy by allowing taking an example
     * object instead of metadata records
     *
     * @param exampleObject
     * @param priority
     * @return the created Test_Record_Generator__mdt, with a made-up Id
     */
    global Test_Record_Generator__mdt addTemporaryMetadataFromInstance(SObject exampleObject, Decimal priority) {
        Test_Record_Generator__mdt metadataRecordWithId = addTemporaryMetadata(new Test_Record_Generator__mdt(
                Priority__c = priority,
                Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                SObject__c = exampleObject.getSObjectType().getDescribe().getName()
        ));

        generatorFieldMetadata.putAll(getMetadataFields(exampleObject, metadataRecordWithId.Id));
        return metadataRecordWithId;
    }

    private static List<Test_Record_Generator_Field__mdt> getMetadataFields(SObject exampleObject, Id testRecordGeneratorId) {
        Map<String, Object> populatedFields = exampleObject.getPopulatedFieldsAsMap();
        List<Test_Record_Generator_Field__mdt> newFields = new List<Test_Record_Generator_Field__mdt>();
        for(String field : populatedFields.keySet()) {
            newFields.add(new Test_Record_Generator_Field__mdt(
                    Test_Record_Generator__c = testRecordGeneratorId,
                    Field__c = field,
                    Value__c = String.valueOf(populatedFields.get(field))));
        }
        return newFields;
    }

    private static Metadata.CustomMetadataValue getCustomMetadataValue(String field, Object value) {
        Metadata.CustomMetadataValue returnValue = new Metadata.CustomMetadataValue();
        returnValue.field = field;
        returnValue.value = value;
        return returnValue;
    }

    global static void insertMetadataFieldsFromExample(SObject exampleObject, String qualifiedApiName) {
        Metadata.Operations.enqueueDeployment(
                getDeployContainerForMetadataFields(exampleObject, qualifiedApiName),
                new EmailResultsMetadataDeployCallback(UserInfo.getUserEmail()));
    }

    global static Metadata.DeployContainer getDeployContainerForMetadataFields(SObject exampleObject, String qualifiedApiName) {
        List<Test_Record_Generator__mdt> parents = [
                SELECT Id, DeveloperName, MasterLabel, QualifiedApiName
                FROM Test_Record_Generator__mdt
                WHERE QualifiedApiName = :qualifiedApiName];
        System.assertEquals(1, parents.size(),
                'No record found matching qualified API name "' + qualifiedApiName + '"'
        );
        Test_Record_Generator__mdt parent = parents[0];

        List<Test_Record_Generator_Field__mdt> fields = getMetadataFields(exampleObject, null);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();

        for(Test_Record_Generator_Field__mdt thisField : fields) {
            Metadata.CustomMetadata metadataToInsert = new Metadata.CustomMetadata();

            metadataToInsert.fullName = Test_Record_Generator_Field__mdt.SObjectType.getDescribe().getName().removeEnd('__mdt')
                    + '.' + parent.DeveloperName + '_' + thisField.Field__c.replaceAll('__', '_');
            metadataToInsert.label = parent.MasterLabel + ': ' + thisField.Field__c;

            metadataToInsert.values.addAll(new List<Metadata.CustomMetadataValue>{
                    getCustomMetadataValue(
                            Test_Record_Generator_Field__mdt.Test_Record_Generator__c.getDescribe().getName(),
                            parent.QualifiedApiName
                    ),
                    getCustomMetadataValue(
                            Test_Record_Generator_Field__mdt.Field__c.getDescribe().getName(),
                            thisField.Field__c
                    ),
                    getCustomMetadataValue(
                            Test_Record_Generator_Field__mdt.Value__c.getDescribe().getName(),
                            thisField.Value__c
                    )
            });
            mdContainer.addMetadata(metadataToInsert);
        }

        return mdContainer;
    }
}