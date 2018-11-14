/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/11/2018
 * @description (if required)
 */

public with sharing class SObjectIndexLeaf implements SObjectIndexI {

    private List<SObject> objects;

    public SObjectIndexLeaf() {
        objects = new List<SObject>();
    }

    public void put(SObject newObj) {
        objects.add(newObj);
    }
    public List<SObject> getAll(Object objVal) {
        return objects;
    }
    public List<SObject> values() {
        return objects;
    }
    public Set<Id> remove(SObject spec) {
        Set<Id> rval = new Set<Id>();
        for(integer i=objects.size()-1; i >= 0; i--) {
            if(objects[i] == spec) {
                if(objects[i].id != null) {
                    rval.add(objects[i].id);
                }
                objects.remove(i);
            }
        }
        return rval;
    }
    public Set<Id> remove(Map<String, Object> spec) {
        Set<Id> rval = new Set<Id>();

        for(SObject thiSObject : objects) {
            rval.add(thiSObject.Id);
        }
        objects = new List<SObject>();
        return rval;
    }
    public Set<String> keySet(String field) {
        return new Set<String>();
    }
    public SObjectIndexI deepClone() {
        SObjectIndexLeaf rval = new SObjectIndexLeaf();

        rval.objects = objects.deepClone(true, true, true);
        return rval;
    }
}