/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-24
 */

global class ExceptionMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        throw new NullPointerException();
    }
}