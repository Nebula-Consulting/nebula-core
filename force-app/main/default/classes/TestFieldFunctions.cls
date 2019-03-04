/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 * @description Some standard implementations of TestFieldFunction
 */

public class TestFieldFunctions {

    public class AppendRandomNumber implements TestFieldFunction {
        public Object getValue(TestRecords parentHierarchy, Map<String, Object> parameters) {
            String value = (String)parameters.get('value');
            return value == null ? value : (value + String.valueOf(Math.random()));
        }
    }

    public class CreateRecord implements TestFieldFunction {
        public Object getValue(TestRecords parentHierarchy, Map<String, Object> parameters) {
            SObject targetInstance = (SObject)TypeLoader.getType((String)parameters.get('sObject')).newInstance();
            return parentHierarchy.getObjectWithInsert(
                    targetInstance.getSObjectType(),
                    (String)parameters.get('variant')
            ).Id;
        }
    }
}