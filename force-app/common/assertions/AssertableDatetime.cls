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

    global AssertableDateTimeWithin isWithin(Integer tolerance) {
        return new AssertableDateTimeWithin(this, tolerance);
    }

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

        global AssertableDateTimeWithin minutes() {
            tolerance *= 1000 * 60;
            return this;
        }

        global AssertableDateTimeWithin seconds() {
            tolerance *= 1000;
            return this;
        }

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