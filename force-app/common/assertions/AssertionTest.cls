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

    @IsTest
    static void datetimeEquals() {

        Assertion.is.that(Datetime.newInstance(2021, 11, 29, 15, 15, 1)).equals(Datetime.newInstance(2021, 11, 29, 15, 15, 1));

        try {
            Assertion.is.that(Datetime.now()).equals(Datetime.now().addMinutes(1));
        } catch (AssertionException e) {
            return;
        }

        System.assert(false, 'Should have thrown exception');
    }

    @IsTest
    static void datetimeWithin() {

        Assertion.is.that(Datetime.now()).isWithin(5).minutes().of(Datetime.now().addMinutes(4));
        Assertion.is.that(Datetime.now()).isWithin(5).seconds().of(Datetime.now().addSeconds(4));

        AssertionException assertionException;

        try {
            Assertion.is.that(Datetime.now()).isWithin(4).minutes().of(Datetime.now().addMinutes(5));
        } catch (AssertionException e) {
            assertionException = e;
        } finally {
            System.assertNotEquals(null, assertionException, 'Should have thrown exception');
        }

        try {
            Assertion.is.that(Datetime.now()).isWithin(4).seconds().of(Datetime.now().addSeconds(5));
        } catch (AssertionException e) {
            assertionException = e;
        } finally {
            System.assertNotEquals(null, assertionException, 'Should have thrown exception');
        }

    }

    @IsTest
    static void datetimeWithinNegative() {

        Assertion.is.that(Datetime.now()).isWithin(5).minutes().of(Datetime.now().addMinutes(4));
        Assertion.is.that(Datetime.now()).isWithin(5).seconds().of(Datetime.now().addSeconds(-4));

        AssertionException assertionException;
        try {
            Assertion.is.that(Datetime.now()).isWithin(4).minutes().of(Datetime.now().addMinutes(-5));
        } catch (AssertionException e) {
            assertionException = e;
        } finally {
            System.assertNotEquals(null, assertionException, 'Should have thrown exception');
        }

        try {
            Assertion.is.that(Datetime.now()).isWithin(4).seconds().of(Datetime.now().addSeconds(-5));
        } catch (AssertionException e) {
            assertionException = e;
        } finally {
            System.assertNotEquals(null, assertionException, 'Should have thrown exception');
        }
    }
}