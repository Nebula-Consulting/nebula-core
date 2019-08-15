/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-15
 */

global class IsUnique implements BooleanFunction {

    private Set<Object> seen = new Set<Object>();

    global Boolean isTrueFor(Object o) {
        if(seen.contains(o)) {
            return false;
        } else {
            seen.add(o);
            return true;
        }
    }
}