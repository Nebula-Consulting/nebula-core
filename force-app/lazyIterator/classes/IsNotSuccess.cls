/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/09/2020
 * @description For filtering DatabaseResult objects by .isSuccess()
 */

global class IsNotSuccess implements BooleanFunction {
    global Boolean isTrueFor(Object o) {
        return !((DatabaseResult)o).isSuccess();
    }
}