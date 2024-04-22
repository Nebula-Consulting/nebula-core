/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/11/2021
 * @description HTTP methods - note that each entry is prefixed with HTTP so that HTTP_DELETE works (delete by itself is
 * a reserved word). This is a class instead of an enum so that we can have custom values that match the strings expected
 * by HtttpRequest
 */
global class HttpMethod {

    global static HttpMethod HTTP_POST = new HttpMethod('POST');
    global static HttpMethod HTTP_GET = new HttpMethod('GET');
    global static HttpMethod HTTP_PUT = new HttpMethod('PUT');
    global static HttpMethod HTTP_PATCH = new HttpMethod('PATCH');
    global static HttpMethod HTTP_DELETE = new HttpMethod('DELETE');

    global String name {get; private set;}

    private HttpMethod(String label) {
        this.name = label;
    }

    global override String toString() {
        return name;
    }
}