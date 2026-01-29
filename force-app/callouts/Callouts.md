## Making HTTP Callouts with NebulaApi

Nebula Core provides classes to simplify HTTP callouts with consistent error handling and testing support.

### NebulaApi

[NebulaApi](classes/NebulaApi.cls) is an abstract base class that wraps HTTP callouts to provide:
- Consistent error handling (non-2xx responses throw exceptions)
- Total callout time tracking
- Simplified testing with mock support

To use it, extend `NebulaApi` and implement your specific API logic:

```apex
public class MyExternalApi extends NebulaApi {
    
    public MyExternalApi() {
        super('My External Service');
    }
    
    public String getData(String resourceId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:My_Named_Credential/api/resource/' + resourceId);
        request.setMethod('GET');
        
        HttpResponse response = makeCallout(request);
        return response.getBody();
    }
}
```

The `makeCallout` method:
- Throws a `NebulaApiException` if the response status is not in the 2xx range
- Tracks cumulative callout time accessible via `NebulaApi.getTotalCalloutTimeInMs()`
- Wraps connection errors in `NebulaApiException`

### URL Encoding

`NebulaApi` includes a utility method for URL encoding query parameters:

```apex
Map<String, String> params = new Map<String, String>{
    'search' => 'hello world',
    'filter' => 'active=true'
};

String queryString = NebulaApi.urlEncode(params);
// Returns: 'search=hello+world&filter=active%3Dtrue'
```

### Testing Callouts with HttpExpectationMock

[HttpExpectationMock](classes/HttpExpectationMock.cls) provides a flexible way to mock HTTP callouts in tests. You 
define expectations for specific requests, and the mock returns the appropriate response.

```apex
@isTest
static void testCallout() {
    // Set up expectations
    HttpExpectationMock mock = new HttpExpectationMock();
    mock.addExpectation(new HttpExpectation('https://api.example.com/.*', HttpMethod.HTTP_GET)
        .setResponseBody('{"status": "success"}')
        .setResponseStatusCode(200));
    
    NebulaApi.setMock(mock);
    
    // Make the callout - will return the mocked response
    Test.startTest();
    MyExternalApi api = new MyExternalApi();
    String result = api.getData('123');
    Test.stopTest();
    
    System.assertEquals('{"status": "success"}', result);
}
```

### HttpExpectation

[HttpExpectation](classes/HttpExpectation.cls) defines what request to match and what response to return:

```apex
// Basic expectation - matches endpoint regex and HTTP method
HttpExpectation expectation = new HttpExpectation('https://api.example.com/submit', HttpMethod.HTTP_POST);

// Configure the response
expectation
    .setResponseBody('{"id": "12345"}')
    .setResponseStatusCode(201)
    .setResponseHeader('Content-Type', 'application/json');

// Verify request body content with a custom matcher
expectation.setBodyVerification(new IsRegexMatch('.*username.*'));
```

### ExceptionMock

[ExceptionMock](classes/ExceptionMock.cls) is an `HttpCalloutMock` implementation that simply throws an exception. 
This is useful for testing error handling when callouts fail at the connection level:

```apex
@isTest
static void testCalloutFailure() {
    // Mock will throw a CalloutException
    NebulaApi.setMock(new ExceptionMock());
    
    Test.startTest();
    try {
        MyExternalApi api = new MyExternalApi();
        api.getData('123');
        System.assert(false, 'Expected exception');
    } catch (NebulaApiException e) {
        System.assert(e.getMessage().contains('CalloutException'));
    }
    Test.stopTest();
}
```

### Related Classes

- [NebulaApiException](classes/NebulaApiException.cls) - Custom exception for API errors, includes the response body
- [HttpMethod](classes/HttpMethod.cls) - Enum for HTTP methods (GET, POST, PUT, DELETE, etc.)
