/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/09/2020
 * @description Gets the left value from a Pair
 */

global virtual class Left implements Function {

    global Object call(Object o) {
        return ((Pair)o).left();
    }
}