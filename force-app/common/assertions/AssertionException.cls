/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 27/04/2021
 */
global class AssertionException extends Exception {

    public Object actual;
    public Object expected;

    global AssertionException(Object actual, Object expected, String message) {
        super.setMessage(message);
        this.actual = actual;
        this.expected = expected;
    }
}