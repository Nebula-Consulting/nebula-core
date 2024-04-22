/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2020
 */
global interface Tuple extends Iterable<Object> {
    Object get(Integer n);
    Integer size();
}