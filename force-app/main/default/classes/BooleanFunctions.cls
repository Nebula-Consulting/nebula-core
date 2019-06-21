/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-31
 * @description Some base functions
 */

global class BooleanFunctions {

    global class IsNull implements BooleanFunction {
        global Boolean isTrueFor(Object o) {
            return o == null;
        }
    }

    global class IsNotNull implements BooleanFunction {
        global Boolean isTrueFor(Object o) {
            return o != null;
        }
    }

    global class IsNot implements BooleanFunction {

        private BooleanFunction booleanFunction;

        global IsNot(BooleanFunction booleanFunction) {
            this.booleanFunction = booleanFunction;
        }

        global Boolean isTrueFor(Object o) {
            return !booleanFunction.isTrueFor(o);
        }
    }

    global class IsAll implements BooleanFunction {

        private List<BooleanFunction> booleanFunctions;

        global IsAll(List<BooleanFunction> booleanFunctions) {
            this.booleanFunctions = booleanFunctions;
        }

        global Boolean isTrueFor(Object o) {
            for(BooleanFunction thisBooleanFunction : booleanFunctions) {
                if(!thisBooleanFunction.isTrueFor(o)) {
                    return false;
                }
            }
            return true;
        }
    }

    global class IsAny implements BooleanFunction {

        private List<BooleanFunction> booleanFunctions;

        global IsAny(List<BooleanFunction> booleanFunctions) {
            this.booleanFunctions = booleanFunctions;
        }

        global Boolean isTrueFor(Object o) {
            for(BooleanFunction thisBooleanFunction : booleanFunctions) {
                if(thisBooleanFunction.isTrueFor(o)) {
                    return true;
                }
            }
            return false;
        }
    }

    global class IsInSObjectIndex implements BooleanFunction {
        private SObjectIndex theIndex;

        global IsInSObjectIndex(SObjectIndex theIndex) {
            this.theIndex = theIndex;
        }

        global Boolean isTrueFor(Object o) {
            return theIndex.get((SObject)o) != null;
        }
    }

    global class IsTriggerChanged extends TriggerContextBooleanFunction {

        private SObjectField field;

        global IsTriggerChanged(SObjectField field) {
            this.field = field;
        }

        global override Boolean isTrueFor(SObject oldRecord, SObject newRecord) {
            return oldRecord == null || oldRecord.get(field) != newRecord.get(field);
        }
    }

    global class IsSObjectFieldEqual implements BooleanFunction{

        private SObjectField field;
        private Object value;

        global IsSObjectFieldEqual(SObjectField field, Object value) {
            this.field = field;
            this.value = value;
        }

        global Boolean isTrueFor(Object o) {
            return ((SObject)o).get(field) == value;
        }
    }
}