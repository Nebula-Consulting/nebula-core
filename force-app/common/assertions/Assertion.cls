/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 27/04/2021
 * @description Unlike System.assert, these methods throw catchable exceptions and have a fluent interface
 */
global class Assertion {

    global static DescribedAssertion is {get {
        return new DescribedAssertion(null);
    } set;}

    global static DescribedAssertion is(String description) {
        return new DescribedAssertion(description);
    }

    global class DescribedAssertion {

        private String description;

        private DescribedAssertion(String description) {
            this.description = description;
        }

        global Assertable that(Object actual) {
            return new Assertable(actual, toString());
        }

        global AssertableString that(String actual) {
            return new AssertableString(actual, toString());
        }

        global AssertableDatetime that(Datetime actual) {
            return new AssertableDatetime(actual, toString());
        }

        global void that(Boolean shouldBeTrue) {
            if(!shouldBeTrue) {
                throw new AssertionException(toString() + 'Expected to be true');
            }
        }

        global override String toString() {
            return description == null ? '' : '[' + description + '] ';
        }
    }

    global class Assertable {

        private Object actual;
        private String description;

        private Assertable(Object actual, String description) {
            this.actual = actual;
            this.description = description;
        }

        global Assertable equals(Object expected) {
            if(actual != expected) {
                throw new AssertionException(actual, expected, description + 'Expected: ' + expected + ', Actual: ' + actual);
            }
            return this;
        }
    }

}