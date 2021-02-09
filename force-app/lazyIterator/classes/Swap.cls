/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 03/02/2021
 * @description Swaps the order of the items in a 2-tuple
 */

global class Swap implements Function {

    global Object call(Object o) {
        Tuple inputTuple = (Tuple)o;
        return new ListTuple(inputTuple.get(1), inputTuple.get(0));
    }
}