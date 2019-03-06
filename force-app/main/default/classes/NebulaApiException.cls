/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-06
 */

global virtual class NebulaApiException extends Exception {

    global HttpResponse response {get; private set;}

    global NebulaApiException(String message, HttpResponse response) {
        this(message);
        this.response = response;
    }
}