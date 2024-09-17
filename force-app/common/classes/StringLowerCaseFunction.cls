/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-02-28
 * @description If the argument is a not-null String, returns it in lower case. Otherwise returns the given argument
 */
global class StringLowerCaseFunction implements Function {
    public Object call(Object o) {
        return (o == null || !(o instanceof String)) ? o : (Object)((String)o).toLowerCase();
    }
}