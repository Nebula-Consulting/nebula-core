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

    private List<SObject> remove() {
        List<SObject> returnVal = objects;
        objects = new List<SObject>();
        return returnVal;
    }

    public List<SObject> remove(SObject spec) {
        return remove();
    }
    public List<SObject> remove(Map<String, Object> spec) {
        return remove();
    }
    public Set<String> keySet(String field) {
        return new Set<String>();
    }
}