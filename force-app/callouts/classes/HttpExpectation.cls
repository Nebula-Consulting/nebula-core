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

    /**
     * @description Creates an expectation with endpoint regex matching and HTTP method
     * @param endpointRegex Regular expression to match the endpoint URL
     * @param method The expected HTTP method
     */
    global HttpExpectation(String endpointRegex, HttpMethod method) {
        this(new IsRegexMatch(endpointRegex), method);
    }

    /**
     * @description Creates an expectation with custom endpoint matcher and HTTP method
     * @param endPointMatcher BooleanFunction to match the endpoint
     * @param method The expected HTTP method
     */
    global HttpExpectation(BooleanFunction endPointMatcher, HttpMethod method) {
        this.endpointMatcher = endPointMatcher;
        this.method = method;
        this.response = new HttpResponse();
        this.response.setStatusCode(200);
    }

    /**
     * @description Sets the HTTP status code for the mock response
     * @param statusCode The status code to return
     * @return This HttpExpectation instance for method chaining
     */
    global HttpExpectation setResponseStatusCode(Integer statusCode) {
        response.setStatusCode(statusCode);
        return this;
    }

    /**
     * @description Sets the response body for the mock response
     * @param body The response body content
     * @return This HttpExpectation instance for method chaining
     */
    global HttpExpectation setResponseBody(String body) {
        response.setBody(body);
        return this;
    }

    /**
     * @description Sets a response header for the mock response
     * @param key The header name
     * @param value The header value
     * @return This HttpExpectation instance for method chaining
     */
    global HttpExpectation setResponseHeader(String key, String value) {
        response.setHeader(key, value);
        return this;
    }

    /**
     * @description Sets a function to verify the request body content
     * @param bodyVerification BooleanFunction to validate the request body
     * @return This HttpExpectation instance for method chaining
     */
    global HttpExpectation setBodyVerification(BooleanFunction bodyVerification) {
        this.bodyVerification = bodyVerification;
        return this;
    }

    /**
     * @description Generates the HTTP response for the given request, verifying expectations
     * @param request The HttpRequest to validate and respond to
     * @return The configured HttpResponse
     */
    global HttpResponse respond(HttpRequest request) {
        String endpoint = request.getEndpoint();
        System.assert(endpointMatcher.isTrueFor(endpoint), 'Unexpected endpoint ' + endpoint);
        System.assertEquals(method.name, request.getMethod());
        System.assert(bodyVerification == null || bodyVerification.isTrueFor(request.getBody()));
        return response;
    }
}