/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2020
 * @description Expects the argument to be an Iterator<Object>, calls hasNext() on it
 */

global class HasNext implements BooleanFunction {
    global Boolean isTrueFor(Object o) {
        return ((Iterator<Object>)o).hasNext();
    }
}