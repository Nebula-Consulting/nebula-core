/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/11/2018
 * @description For implementing SObjectIndex with the Composite Pattern
 */

public interface SObjectIndexI {

    void put(SObject newObj);
    List<SObject> getAll(Object objVal);
    List<SObject> getAll(SObject spec);
    List<SObject> getAll(Map<String, Object> spec);
    List<SObject> values();
    Set<Id> remove(SObject spec);
    Set<Id> remove(Map<String, Object> spec);
    Set<String> keySet(String field);
    SObjectIndexI deepClone();

}