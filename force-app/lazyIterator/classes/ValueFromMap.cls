/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 16/11/2022
 * @description Get a value from a Map<String, Object> (note that we cannot fully generalise to all maps without access
 * to generic types)
 */

global class ValueFromMap implements Function {

    private final String key;

    global ValueFromMap(String key) {
        this.key = key;
    }

    global Object call(Object o) {
        return ((Map<String, Object>)o).get(key);
    }
}