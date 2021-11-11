/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 11/11/2021
 * @description An object that you can put values into e.g. Map, SObject, SObjectIndex
 */

public interface Puttable {
    void put(Object key, Object value);
}