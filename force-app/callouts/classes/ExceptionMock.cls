/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-24
 */
global class ExceptionMock implements HttpCalloutMock {

    private Exception toThrow;

    global ExceptionMock(Exception toThrow) {
        this.toThrow = toThrow;
    }

    global ExceptionMock() {
        this(new NullPointerException());
    }

    global HttpResponse respond(HttpRequest request) {
        throw toThrow;
    }
}