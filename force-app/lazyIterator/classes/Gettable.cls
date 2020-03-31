/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 18/10/2019
 * @description Map-like objects that you can call get() on e.g. Map, SObjectIndex, SObject
 */

global interface Gettable {
    Object get(Object key);
    Gettable setDefaultIfMissing(Object defaultIfMissing);
}