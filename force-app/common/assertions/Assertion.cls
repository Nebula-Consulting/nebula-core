/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 27/04/2021
 * @description Unlike System.assert, these methods throw catchable exceptions and have a fluent interface
 */
global class Assertion {

    /**
     * @description Static property for creating described assertions
     * @return DescribedAssertion instance
     */
    global static DescribedAssertion is {get {
        return new DescribedAssertion(null);
    } set;}

    /**
     * @description Creates a described assertion with a custom description
     * @param description The description for the assertion
     * @return DescribedAssertion instance
     */
    global static DescribedAssertion is(String description) {
        return new DescribedAssertion(description);
    }

    global class DescribedAssertion {

        private String description;

        private DescribedAssertion(String description) {
            this.description = description;
        }

        /**
         * @description Creates an assertion for an Object value
         * @param actual The actual value to assert
         * @return Assertable instance for fluent assertions
         */
        global Assertable that(Object actual) {
            return new Assertable(actual, toString());
        }

        /**
         * @description Creates an assertion for a String value
         * @param actual The actual String value to assert
         * @return AssertableString instance for fluent string assertions
         */
        global AssertableString that(String actual) {
            return new AssertableString(actual, toString());
        }

        /**
         * @description Creates an assertion for a Datetime value
         * @param actual The actual Datetime value to assert
         * @return AssertableDatetime instance for fluent datetime assertions
         */
        global AssertableDatetime that(Datetime actual) {
            return new AssertableDatetime(actual, toString());
        }

        /**
         * @description Asserts that a boolean condition is true
         * @param shouldBeTrue The boolean condition to check
         */
        global void that(Boolean shouldBeTrue) {
            if(!shouldBeTrue) {
                throw new AssertionException(toString() + 'Expected to be true');
            }
        }

        /**
         * @description Returns the string representation with description
         * @return The formatted description
         */
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