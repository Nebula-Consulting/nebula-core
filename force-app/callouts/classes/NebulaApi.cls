/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-06
 * @description Wraps up callouts so that they return consistently return errors via an Exception i.e. HTTP outside
 * 200-299 will throw an Exception. Also tracks total callout time
 */

global abstract class NebulaApi {

    global static Long getTotalCalloutTimeInMs() {
        return totalCalloutTimeInMs;
    }

    private static Long totalCalloutTimeInMs = 0;

    // Make the callout and throw exceptions for errors
    // If no exception is thrown, then the return value is
    // Status 200-299

    global String endpointName;

    global NebulaApi(String endpoint) {
        this.endpointName = endpoint;
    }

    global virtual HttpResponse makeCallout(HttpRequest request) {
        Http httpConnection = new Http();
        HttpResponse response;
        try {
            Long nowMs = Datetime.now().getTime();
            response = httpConnection.send(request);
            totalCalloutTimeInMs += Datetime.now().getTime() - nowMs;
        } catch(Exception e) {
            throw new NebulaApiException(e);
        }

        if(!(response.getStatusCode() >= 200 && response.getStatusCode() < 300)) {
            throw new NebulaApiException(
                    'Error status code from ' + endpointName + ' (' + response.getStatusCode() + '): ' + response.getBody(),
                    response
            );
        }
        return response;
    }

    global static String urlEncode(Map<String, String> values) {
        String returnVal = '';
        for(String thisKey : values.keySet()) {
            String thisValue = values.get(thisKey);
            returnVal += '&' + EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(thisValue == null ? '' : thisValue, 'UTF-8');
        }
        return returnVal.removeStart('&');
    }

    global static void setMock(HttpCalloutMock theMock) {
        Test.setMock(HttpCalloutMock.class, theMock);
    }
}