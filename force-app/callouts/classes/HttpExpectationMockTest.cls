/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/11/2021
 */

@IsTest
private class HttpExpectationMockTest {

    private static HttpExpectationMock theMock = new HttpExpectationMock().setAsNebulaApiMock();

    @IsTest
    static void getWithRegexEndpoint() {
        HttpRequest request = new HttpRequest();
        request.setMethod(HttpMethod.HTTP_GET.name);
        request.setEndpoint('https://foo.com/bar');

        theMock.expect(new HttpExpectation('https://foo.*/bar', HttpMethod.HTTP_GET)
                .setResponseBody('baz')
        );

        Test.startTest();
        HttpResponse response = new Http().send(request);
        Test.stopTest();

        System.assert(theMock.isEmpty());
        System.assertEquals('baz', response.getBody());
    }

    @IsTest
    static void putWithBodyVerification() {
        theMock.setAsTestMock(); // Same as Nebula API mock in this case, but for coverage

        HttpRequest request = new HttpRequest();
        request.setMethod(HttpMethod.HTTP_PUT.name);
        request.setEndpoint('https://foo.com/bar');
        request.setBody('baz');

        theMock.expect(new HttpExpectation('https://foo.com/bar', HttpMethod.HTTP_PUT)
                .setResponseStatusCode(201)
                .setBodyVerification(new IsEqual('baz'))
        );

        Test.startTest();
        HttpResponse response = new Http().send(request);
        Test.stopTest();

        System.assert(theMock.isEmpty());
        System.assertEquals(201, response.getStatusCode());
        System.assertEquals('', response.getBody());
    }
}