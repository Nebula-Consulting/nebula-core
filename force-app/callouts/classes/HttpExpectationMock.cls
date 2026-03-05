/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/11/2021
 * @description A generic mock for HTTP Callouts
 */
global class HttpExpectationMock implements HttpCalloutMock {

    private List<HttpExpectation> expectations = new List<HttpExpectation>();

    /**
     * @description Registers this mock as the HTTP mock for NebulaApi callouts
     * @return This HttpExpectationMock instance for method chaining
     */
    global HttpExpectationMock setAsNebulaApiMock() {
        NebulaApi.setMock(this);
        return this;
    }

    /**
     * @description Registers this mock as the test HTTP callout mock
     * @return This HttpExpectationMock instance for method chaining
     */
    global HttpExpectationMock setAsTestMock() {
        Test.setMock(HttpCalloutMock.class, this);
        return this;
    }

    /**
     * @description Adds an expected HTTP request/response pair to the mock
     * @param thisExpectation The HttpExpectation defining the expected request and response
     * @return This HttpExpectationMock instance for method chaining
     */
    global HttpExpectationMock expect(HttpExpectation thisExpectation) {
        expectations.add(thisExpectation);
        return this;
    }

    /**
     * @description Responds to an HTTP request with the next expected response
     * @param request The incoming HttpRequest
     * @return The configured HttpResponse from the next expectation
     */
    global HttpResponse respond(HttpRequest request) {
        System.assert(!expectations.isEmpty(), 'More callouts than expected, HttpExpectationMock ran out of expectations');
        return expectations.remove(0).respond(request);
    }

    /**
     * @description Checks if all expectations have been consumed
     * @return True if no expectations remain, false otherwise
     */
    global Boolean isEmpty() {
        return expectations.isEmpty();
    }
}