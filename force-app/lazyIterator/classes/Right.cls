/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/09/2020
 * @description Gets the right value from a 2-Tuple
 */
global virtual class Right implements Function {

    global Object call(Object o) {
        return ((Tuple)o).get(1);
    }
}