/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 * @description Generates a record for TestRecords by using the Parameters__c field of Test_Record_Generator__mdt to
 * define constants or functions for each field
 */

global class TestMetadataRecordGenerator extends TestRecordGenerator {

    public class FieldValueGenerator {

        private TestRecords parentHierarchy;
        private Map<String, Object> fieldConfig;

        public FieldValueGenerator(TestRecords parentHierarchy, Map<String, Object> fieldConfig) {
            this.parentHierarchy = parentHierarchy;
            this.fieldConfig = fieldConfig;
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
                return fieldConfig.get('value');
            } else {
                TestFieldFunction testFieldFunction = ((TestFieldFunction) fieldFunctionClass.newInstance());
                return testFieldFunction.getValue(parentHierarchy, (Map<String, Object>)valueFunction.get('parameters'));
            }
        }
    }

    global override SObject getObjectNoInsert(Map<String, Object> params) {
        Map<String, Object> metaObjectDescription = (Map<String, Object>)JSON.deserializeUntyped(metadata.Parameters__c);

        Map<String, Object> concreteObjectDescription = new Map<String, Object>();

        for(String thisFieldName : metaObjectDescription.keySet()) {
            FieldValueGenerator thisFieldValueGenerator = new FieldValueGenerator(
                    parentHierarchy,
                    (Map<String, Object>) metaObjectDescription.get(thisFieldName)
            );

            concreteObjectDescription.put(thisFieldName, thisFieldValueGenerator.getValue());
        }

        return (SObject)JSON.deserialize(JSON.serialize(concreteObjectDescription), TypeLoader.getType(metadata.SObject__c));
    }
}
