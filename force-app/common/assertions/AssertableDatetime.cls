/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 29/11/2021
 * @description A Datetime that can be asserted in various ways, for use with Assertion
 */
global class AssertableDatetime {

    public Datetime actual {get; private set;}
    private String description;

    global AssertableDatetime(Datetime actual, String description) {
        this.actual = actual;
        this.description = description;
    }

    /**
     * @description Begins a tolerance-based datetime assertion
     * @param tolerance The tolerance value (call minutes() or seconds() to set units)
     * @return AssertableDateTimeWithin instance for continuing the assertion
     */
    global AssertableDateTimeWithin isWithin(Integer tolerance) {
        return new AssertableDateTimeWithin(this, tolerance);
    }

    /**
     * @description Asserts that the datetime equals the expected value
     * @param expected The expected datetime value
     * @return This AssertableDatetime instance for method chaining
     */
    global AssertableDatetime equals(Datetime expected) {
        if(actual != expected) {
            throw new AssertionException(actual, expected, description + 'Expected : ' + expected + ', Actual: ' + actual);
        }
        return this;
    }

    global class AssertableDateTimeWithin {

        private Long tolerance;
        private AssertableDatetime parent;

        global AssertableDateTimeWithin(AssertableDatetime parent, Long tolerance) {
            this.tolerance = tolerance;
            this.parent = parent;
        }

        /**
         * @description Sets the tolerance units to minutes
         * @return This AssertableDateTimeWithin instance for method chaining
         */
        global AssertableDateTimeWithin minutes() {
            tolerance *= 1000 * 60;
            return this;
        }

        /**
         * @description Sets the tolerance units to seconds
         * @return This AssertableDateTimeWithin instance for method chaining
         */
        global AssertableDateTimeWithin seconds() {
            tolerance *= 1000;
            return this;
        }

        /**
         * @description Completes the tolerance assertion against another datetime
         * @param other The datetime to compare against
         * @return The parent AssertableDatetime instance
         */
        global AssertableDatetime of(Datetime other) {
            if(Math.abs(parent.actual.getTime()-other.getTime()) > tolerance) {
                throw new AssertionException(
                        parent.actual,
                        tolerance,
                        parent.description + 'Expected : ' + parent.actual + ' to be within ' + tolerance + 'ms of ' + other);
            }
            return parent;
        }
    }
}