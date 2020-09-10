/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2020
 */

public virtual class ListTuple implements Tuple {

    private List<Object> entries;

    public ListTuple(Object o1, Object o2) {
        entries = new List<Object>{o1, o2};
    }

    public ListTuple(List<Object> entries) {
        this.entries = entries.clone();
    }

    public Object get(Integer n) {
        return entries[n];
    }

    public Integer size() {
        return entries.size();
    }

    public Iterator<Object> iterator() {
        return entries.iterator();
    }
}