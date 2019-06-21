/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class IsNull implements BooleanFunction {

    global Boolean isTrueFor(Object o) {
        return o == null;
    }
}