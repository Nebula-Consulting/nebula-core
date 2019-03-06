/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 * @description Generates a record for TestRecords by using the Parameters__c field of Test_Record_Generator__mdt to
 * define constants or functions for each field
 */

global class TestMetadataRecordGenerator extends TestRecordGenerator {

    public class ValueFunction {
        public String apexClass;
        public Map<String, Object> parameters;

        public  ValueFunction(String apexClass, Map<String, Object> parameters) {
            this.apexClass = apexClass;
            this.parameters = parameters;
        }
    }

    public class FieldValueGenerator {

        private TestRecordSource parentRecordSource;
        private Test_Record_Generator_Field__mdt fieldMetadata;
        private DescribeFieldResult fieldDescribe;

        public FieldValueGenerator(TestRecordSource parentRecordSource, Test_Record_Generator_Field__mdt fieldMetadata, DescribeFieldResult fieldDescribe) {
            this.parentRecordSource = parentRecordSource;
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

        private Object getSimpleValue() {
            switch on fieldDescribe.getType() {
                when DATE {
                    return JSON.deserialize('"' + fieldMetadata.Value__c + '"', Date.class);
                }
                when DATETIME {
                    return JSON.deserialize('"' + fieldMetadata.Value__c + '"', Datetime.class);
                }
                when DOUBLE, CURRENCY, LONG, INTEGER, PERCENT {
                    return Decimal.valueOf(fieldMetadata.Value__c);
                }
                when BOOLEAN {
                    return Boolean.valueOf(fieldMetadata.Value__c);
                }
                when else {
                    return fieldMetadata.Value__c;
                }
            }
        }

        public Object getValue() {
            Object returnValue = getSimpleValue();

            if (fieldMetadata.Apex_Class__c != null) {
                Type fieldFunctionClass = getFieldFunctionClass();
                TestFieldFunction testFieldFunction = (TestFieldFunction)TypeLoader.getInstance(
                        fieldFunctionClass,
                        fieldMetadata.Apex_Class_Parameters__c);
                return testFieldFunction.getValue(parentRecordSource, fieldMetadata.Value__c);
            }
            return returnValue;
        }
    }

    global override SObject getObjectNoInsert(Map<String, Object> params) {
        Map<String, Object> concreteObjectDescription = new Map<String, Object>();
        Type sObjectClass = TypeLoader.getType(metadata.SObject__c);
        Map<String, SObjectField> fields = ((SObject)sObjectClass.newInstance()).getSObjectType().getDescribe().fields.getMap();

        for(Test_Record_Generator_Field__mdt thisFieldMetadata : metadata.Test_Record_Generator_Fields__r) {
            FieldValueGenerator thisFieldValueGenerator = new FieldValueGenerator(
                    parentRecordSource,
                    thisFieldMetadata,
                    fields.get(thisFieldMetadata.Field__c).getDescribe()
            );

            concreteObjectDescription.put(thisFieldMetadata.Field__c, thisFieldValueGenerator.getValue());
        }

        return (SObject)JSON.deserialize(JSON.serialize(concreteObjectDescription), sObjectClass);
    }
}
