/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-31
 * @description Some base functions
 */

global class BooleanFunctions {

    global IsNull isNull {get {
        if (isNull == null) {
            isNull = new IsNull();
        }
        return isNull;
    } private set; }

    global IsNotNull isNotNull {get {
        if (isNotNull == null) {
            isNotNull = new IsNotNull();
        }
        return isNotNull;
    } private set; }

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

    global class IsBoth implements BooleanFunction {

        private BooleanFunction booleanFunction1;
        private BooleanFunction booleanFunction2;

        global IsBoth(BooleanFunction booleanFunction1, BooleanFunction booleanFunction2) {
            this.booleanFunction1 = booleanFunction1;
            this.booleanFunction2 = booleanFunction2;
        }

        global Boolean isTrueFor(Object o) {
            return booleanFunction1.isTrueFor(o) && booleanFunction2.isTrueFor(o);
        }
    }

    global class IsEither implements BooleanFunction {

        private BooleanFunction booleanFunction1;
        private BooleanFunction booleanFunction2;

        global IsEither(BooleanFunction booleanFunction1, BooleanFunction booleanFunction2) {
            this.booleanFunction1 = booleanFunction1;
            this.booleanFunction2 = booleanFunction2;
        }

        global Boolean isTrueFor(Object o) {
            return booleanFunction1.isTrueFor(o) || booleanFunction2.isTrueFor(o);
        }
    }
}