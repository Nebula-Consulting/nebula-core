/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2020
 * @description Expects the argument to be an Iterator<Object>, calls next() on it
 */
global class Next implements Function {
    global Object call(Object o) {
        return ((Iterator<Object>)o).next();
    }
}