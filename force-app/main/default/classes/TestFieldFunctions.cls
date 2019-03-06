/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 * @description Some standard implementations of TestFieldFunction
 */

global class TestFieldFunctions {

    global class AppendRandomNumber implements TestFieldFunction {
        global Object getValue(TestRecordSource parentRecordSource, Object value) {
            return value == null ? value : (value + String.valueOf(Math.random()));
        }
    }

    global class CreateRecord implements TestFieldFunction {

        global String sObjectType;
        global String variant;

        global Object getValue(TestRecordSource parentRecordSource, Object value) {
            SObject targetInstance = (SObject)TypeLoader.getType((String)sObjectType).newInstance();
            return parentRecordSource.getObjectWithInsert(
                    targetInstance.getSObjectType(),
                    variant
            ).Id;
        }
    }

    global class GetRecordTypeId implements TestFieldFunction {

        global String sObjectType;
        global String developerName;

        global Object getValue(TestRecordSource parentRecordSource, Object value) {
            return NamedSObjectCache.getRecordType(
                    sObjectType,
                    developerName
            ).Id;
        }
    }

}