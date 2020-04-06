/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description Represents no result from a function (rather than null which could be a database value)
 */

global class NoResult {

    global final static NoResult NO_RESULT = new NoResult();

    private NoResult() {}
}