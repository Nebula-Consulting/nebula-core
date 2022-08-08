/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/11/2021
 * @description An expectation for mocking callouts
 */

global class HttpExpectation {

    private BooleanFunction endpointMatcher;
    private BooleanFunction bodyVerification;
    private HttpMethod method;
    private HttpResponse response;

    global HttpExpectation(String endpointRegex, HttpMethod method) {
        this(new IsRegexMatch(endpointRegex), method);
    }

    global HttpExpectation(BooleanFunction endPointMatcher, HttpMethod method) {
        this.endpointMatcher = endPointMatcher;
        this.method = method;
        this.response = new HttpResponse();
        this.response.setStatusCode(200);
    }

    global HttpExpectation setResponseStatusCode(Integer statusCode) {
        response.setStatusCode(statusCode);
        return this;
    }

    global HttpExpectation setResponseBody(String body) {
        response.setBody(body);
        return this;
    }

    global HttpExpectation setResponseHeader(String key, String value) {
        response.setHeader(key, value);
        return this;
    }

    global HttpExpectation setBodyVerification(BooleanFunction bodyVerification) {
        this.bodyVerification = bodyVerification;
        return this;
    }

    global HttpResponse respond(HttpRequest request) {
        String endpoint = request.getEndpoint();
        System.assert(endpointMatcher.isTrueFor(endpoint), 'Unexpected endpoint ' + endpoint);
        System.assertEquals(method.name, request.getMethod());
        System.assert(bodyVerification == null || bodyVerification.isTrueFor(request.getBody()));
        return response;
    }
}