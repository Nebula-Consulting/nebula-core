/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/11/2018
 */

public class SObjectIndexLeaf implements SObjectIndexI {

    private List<SObject> objects;

    public SObjectIndexLeaf() {
        objects = new List<SObject>();
    }

    public SObjectIndexI put(SObject newObj) {
        objects.add(newObj);
        return this;
    }
    public List<SObject> getAll(Object key) {
        return objects;
    }
    public List<SObject> values() {
        return objects;
    }
    public Set<Id> remove(SObject spec) {
        Set<Id> returnVal = new Set<Id>();
        for(Integer i=objects.size()-1; i >= 0; i--) {
            if(objects[i] == spec) {
                if(objects[i].Id != null) {
                    returnVal.add(objects[i].Id);
                }
                objects.remove(i);
            }
        }
        return returnVal;
    }
    public Set<Id> remove(Map<String, Object> spec) {
        Set<Id> returnVal = new Set<Id>();

        for(SObject thiSObject : objects) {
            returnVal.add(thiSObject.Id);
        }
        objects = new List<SObject>();
        return returnVal;
    }
    public Set<String> keySet(String field) {
        return new Set<String>();
    }
    public SObjectIndexI deepClone() {
        SObjectIndexLeaf returnVal = new SObjectIndexLeaf();

        returnVal.objects = objects.deepClone(true, true, true);
        return returnVal;
    }
}