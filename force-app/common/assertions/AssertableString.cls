/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 29/11/2021
 * @description A String that can be asserted in various ways, for use with Assertion
 */

global class AssertableString {

    private String actual;
    private String description;

    global AssertableString(String actual, String description) {
        this.actual = actual;
        this.description = description;
    }

    global AssertableString equalsIgnoreCase(String expected) {
        if(!actual.equalsIgnoreCase(expected)) {
            throw new AssertionException(actual, expected, description + 'Expected (case insensitive): ' + expected + ', Actual: ' + actual);
        }
        return this;
    }

    global AssertableString equals(Object expected) {
        if(!actual.equals(expected)) {
            throw new AssertionException(actual, expected, description + 'Expected (case sensitive): ' + expected + ', Actual: ' + actual);
        }
        return this;
    }

    global AssertableString contains(String expected) {
        if(!actual.contains(expected)) {
            throw new AssertionException(actual, expected, description + 'Expected: ' + expected + ' to be contained in: ' + actual);
        }
        return this;
    }
}