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

        private TestRecordSource parentHierarchy;
        private Map<String, Object> fieldConfig;
        private DescribeFieldResult fieldDescribe;

        public FieldValueGenerator(TestRecordSource parentHierarchy, Map<String, Object> fieldConfig, DescribeFieldResult fieldDescribe) {
            this.parentHierarchy = parentHierarchy;
            this.fieldConfig = fieldConfig;
            this.fieldDescribe = fieldDescribe;
        }

        private Map<String, Object> valueFunction { get { return (Map<String, Object>)fieldConfig.get('valueFunction');} set; }

        private Type getFieldFunctionClass() {
            Type fieldFunctionClass = null;
            if(valueFunction != null) {
                String valueFunctionClassName = (String)valueFunction.get('apexClass');
                fieldFunctionClass = TypeLoader.getType(valueFunctionClassName);
                if(fieldFunctionClass == null) {
                    throw new ClassNotFoundException('Value function class' + valueFunctionClassName + ' not found');
                }
            }
            return fieldFunctionClass;
        }

        public Object getValue() {
            Type fieldFunctionClass = getFieldFunctionClass();

            if (fieldFunctionClass == null) {
                switch on fieldDescribe.getType() {
                    when DATE {
                        return JSON.deserialize('"' + fieldConfig.get('value') + '"', Date.class);
                    }
                    when DATETIME {
                        return JSON.deserialize('"' + fieldConfig.get('value') + '"', Datetime.class);
                    }
                    when else {
                        return fieldConfig.get('value');
                    }
                }

            } else {
                TestFieldFunction testFieldFunction = ((TestFieldFunction) fieldFunctionClass.newInstance());
                return testFieldFunction.getValue(parentHierarchy, (Map<String, Object>)valueFunction.get('parameters'));
            }
        }
    }

    global override SObject getObjectNoInsert(Map<String, Object> params) {
        Map<String, Object> metaObjectDescription = (Map<String, Object>)JSON.deserializeUntyped(metadata.Parameters__c);

        Map<String, Object> concreteObjectDescription = new Map<String, Object>();

        Type sObjectClass = TypeLoader.getType(metadata.SObject__c);
        Map<String, SObjectField> fields = ((SObject)sObjectClass.newInstance()).getSObjectType().getDescribe().fields.getMap();

        for(String thisFieldName : metaObjectDescription.keySet()) {
            FieldValueGenerator thisFieldValueGenerator = new FieldValueGenerator(
                    parentHierarchy,
                    (Map<String, Object>) metaObjectDescription.get(thisFieldName),
                    fields.get(thisFieldName).getDescribe()
            );

            concreteObjectDescription.put(thisFieldName, thisFieldValueGenerator.getValue());
        }

        return (SObject)JSON.deserialize(JSON.serialize(concreteObjectDescription), sObjectClass);
    }
}
