/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 19/11/2018
 * @description Null-safe serialiser that calls String.valueOf()
 */

global class StringValueOfSerializer implements Serializer {
    global String serialize(Object o) {
        return String.valueOf(o);
    }
}