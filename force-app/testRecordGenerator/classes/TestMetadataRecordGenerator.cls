/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 * @description Generates a record for TestRecords by using the Parameters__c field of Test_Record_Generator__mdt to
 * define constants or functions for each field
 */
global class TestMetadataRecordGenerator extends TestRecordGenerator {

    private Map<SObjectField, FieldValueGenerator> fieldValueGenerators = new Map<SObjectField, FieldValueGenerator>();

    private FieldValueGenerator getGeneratorForField(SObjectField field, Test_Record_Generator_Field__mdt fieldMetadata) {
        FieldValueGenerator result = fieldValueGenerators.get(field);
        if(result == null) {
            result = new FieldValueGenerator(
                    this,
                    fieldMetadata,
                    field.getDescribe()
            );
            fieldValueGenerators.put(field, result);
        }
        return result;
    }

    public override SObject generateRecord() {
        Map<String, Object> concreteObjectDescription = new Map<String, Object>();
        Type sObjectClass = TypeLoader.getType(metadata.SObject__c);
        Map<String, SObjectField> fields = ((SObject)sObjectClass.newInstance()).getSObjectType().getDescribe().fields.getMap();
        Map<String, Blob> fieldToBlobValue = new Map<String, Blob>();

        for(Test_Record_Generator_Field__mdt thisFieldMetadata : metadataFields) {
            SObjectField thisField = fields.get(thisFieldMetadata.Field__c);
            System.assertNotEquals(
                    null,
                    thisField,
                    String.format(
                            'Field "{0}" from metadata "{1}" not found on SObject {2}',
                            new List<String>{thisFieldMetadata.Field__c, metadata.DeveloperName, metadata.SObject__c} )
            );

            FieldValueGenerator thisFieldValueGenerator = getGeneratorForField(thisField, thisFieldMetadata);

            Object value = thisFieldValueGenerator.getValue();
            if(value instanceof Blob) {
                fieldToBlobValue.put(thisFieldMetadata.Field__c, (Blob)value);
            } else {
                concreteObjectDescription.put(thisFieldMetadata.Field__c, value);
            }
        }

        SObject result = (SObject)JSON.deserialize(JSON.serialize(concreteObjectDescription), sObjectClass);
        for(String field : fieldToBlobValue.keySet()) {
            result.put(field, fieldToBlobValue.get(field));
        }
        return result;
    }
    private class FieldValueGenerator {

        private TestRecordGenerator parentGenerator;
        private Test_Record_Generator_Field__mdt fieldMetadata;
        private DescribeFieldResult fieldDescribe;

        public FieldValueGenerator(TestRecordGenerator parentGenerator, Test_Record_Generator_Field__mdt fieldMetadata, DescribeFieldResult fieldDescribe) {
            this.parentGenerator = parentGenerator;
            this.fieldMetadata = fieldMetadata;
            this.fieldDescribe = fieldDescribe;
        }

        private Type getFieldFunctionClass() {
            Type fieldFunctionClass = TypeLoader.getType(fieldMetadata.Apex_Class__c );
            if(fieldFunctionClass == null) {
                throw new ClassNotFoundException('Value function class' + fieldMetadata.Apex_Class__c + ' not found');
            }
            return fieldFunctionClass;
        }

        private TestFieldFunction testFieldFunction { get {
            if(testFieldFunction == null) {
                testFieldFunction = (TestFieldFunction)TypeLoader.getInstance(
                        getFieldFunctionClass(),
                        fieldMetadata.Apex_Class_Parameters__c);
            }
            return testFieldFunction;
        } set;}

        // PMD seems to be wrongly thinking that the switch cases are variable names, so they shouldn't start with
        // capital letters
        @SuppressWarnings('PMD.VariableNamingConventions')
        private Object getSimpleValue() {
            switch on fieldDescribe.getType() {
                when DATE {
                    return fieldMetadata.Value__c == null ? null : JSON.deserialize('"' + fieldMetadata.Value__c + '"', Date.class);
                }
                when DATETIME {
                    return fieldMetadata.Value__c == null ? null : JSON.deserialize('"' + fieldMetadata.Value__c + '"', Datetime.class);
                }
                when DOUBLE, CURRENCY, LONG, INTEGER, PERCENT {
                    return fieldMetadata.Value__c == null ? null : Decimal.valueOf(fieldMetadata.Value__c);
                }
                when BOOLEAN {
                    return fieldMetadata.Value__c == null ? null : Boolean.valueOf(fieldMetadata.Value__c);
                }
                when BASE64 {
                    return fieldMetadata.Value__c == null ? null : Blob.valueOf(fieldMetadata.Value__c);
                }
                when else {
                    return fieldMetadata.Value__c;
                }
            }
        }

        public Object getValue() {
            Object returnValue = getSimpleValue();

            if (fieldMetadata.Apex_Class__c != null) {
                TestFieldFunction thisTestFieldFunction = testFieldFunction
                        .setParentGenerator(parentGenerator);

                System.assertNotEquals(null, thisTestFieldFunction, 'Incorrect implementation of ' + getFieldFunctionClass() + '.setParentGenerator(). Either extend nebc.TestFieldFunctionWithParent, or make sure your implementation returns "this"');
                return testFieldFunction.getValue(fieldDescribe.getName(), returnValue);
            }
            return returnValue;
        }
    }
}
