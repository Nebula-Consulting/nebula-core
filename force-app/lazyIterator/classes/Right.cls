/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/09/2020
 * @description Gets the right value from a Pair
 */

global virtual class Right implements Function {

    global Object call(Object o) {
        return ((Pair)o).right();
    }
}