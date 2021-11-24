/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 27/04/2021
 * @description Unlike System.assert, these methods throw catchable exceptions and have a fluent interface
 */

global class Assertion {

    public static DescribedAssertion is {get {
        return new DescribedAssertion(null);
    } set;}

    public static DescribedAssertion is(String description) {
        return new DescribedAssertion(description);
    }

    public class DescribedAssertion {

        private String description;

        private DescribedAssertion(String description) {
            this.description = description;
        }

        public Assertable that(Object actual) {
            return new Assertable(actual, toString());
        }

        public AssertableString that(String actual) {
            return new AssertableString(actual, toString());
        }

        public void that(Boolean shouldBeTrue) {
            if(!shouldBeTrue) {
                throw new AssertionException(toString() + 'Expected to be true');
            }
        }

        public override String toString() {
            return description == null ? '' : '[' + description + '] ';
        }
    }

    public class Assertable {

        private Object actual;
        private String description;

        private Assertable(Object actual, String description) {
            this.actual = actual;
            this.description = description;
        }

        public Assertable equals(Object expected) {
            if(actual != expected) {
                throw new AssertionException(actual, expected, description + 'Expected: ' + expected + ', Actual: ' + actual);
            }
            return this;
        }
    }

    public class AssertableString {

        private String actual;
        private String description;

        private AssertableString(String actual, String description) {
            this.actual = actual;
            this.description = description;
        }

        public AssertableString equalsIgnoreCase(String expected) {
            if(!actual.equalsIgnoreCase(expected)) {
                throw new AssertionException(actual, expected, description + 'Expected (case insensitive): ' + expected + ', Actual: ' + actual);
            }
            return this;
        }
        public AssertableString equals(Object expected) {
            if(!actual.equals(expected)) {
                throw new AssertionException(actual, expected, description + 'Expected (case sensitive): ' + expected + ', Actual: ' + actual);
            }
            return this;
        }
    }
}