/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 27/04/2021
 */

@IsTest
private class AssertionTest {

    @IsTest
    static void equals() {
        Assertion.is.that(1).equals(1);

        String description = '1 should equal 2';
        try {
            Assertion.is(description).that(1).equals(2);
        } catch (AssertionException e) {
            String message = e.getMessage();
            System.assert(message.contains(description), 'Expected description to contain ' + '"' + description + '", got' + message);
            return;
        }

        System.assert(false, 'Should have thrown exception');
    }

    @IsTest
    static void that() {

        Assertion.is.that(true);

        try {
            Assertion.is.that(false);
        } catch (AssertionException e) {
            return;
        }

        System.assert(false, 'Should have thrown exception');
    }

    @IsTest
    static void stringIgnoreCase() {

        Assertion.is.that('a').equalsIgnoreCase('A');

        try {
            Assertion.is.that('a').equalsIgnoreCase('b');
        } catch (AssertionException e) {
            return;
        }

        System.assert(false, 'Should have thrown exception');
    }
}