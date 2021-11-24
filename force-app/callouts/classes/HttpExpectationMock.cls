/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/11/2021
 * @description A generic mock for HTTP Callouts
 */

global class HttpExpectationMock implements HttpCalloutMock {

    private List<HttpExpectation> expectations = new List<HttpExpectation>();

    global HttpExpectationMock setAsNebulaApiMock() {
        NebulaApi.setMock(this);
        return this;
    }

    global HttpExpectationMock setAsTestMock() {
        Test.setMock(HttpCalloutMock.class, this);
        return this;
    }

    global HttpExpectationMock expect(HttpExpectation thisExpectation) {
        expectations.add(thisExpectation);
        return this;
    }

    global HttpResponse respond(HttpRequest request) {
        System.assert(!expectations.isEmpty(), 'More callouts than expected, HttpExpectationMock ran out of expectations');
        return expectations.remove(0).respond(request);
    }

    global Boolean isEmpty() {
        return expectations.isEmpty();
    }
}