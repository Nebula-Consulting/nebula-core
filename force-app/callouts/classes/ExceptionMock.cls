/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-24
 * @description Mock for HTTP callouts that throws an exception instead of returning a response
 */
global class ExceptionMock implements HttpCalloutMock {

    private Exception toThrow;

    global ExceptionMock(Exception toThrow) {
        this.toThrow = toThrow;
    }

    global ExceptionMock() {
        this(new NullPointerException());
    }

    /**
     * @description Throws the configured exception instead of returning a response
     * @param request The incoming HttpRequest (ignored)
     * @return Never returns, always throws exception
     */
    global HttpResponse respond(HttpRequest request) {
        throw toThrow;
    }
}