/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2020
 */
global virtual class ListTuple implements Tuple {

    private List<Object> entries;
    global static NewInstance newInstance = new NewListTuple();

    global ListTuple(Object o1, Object o2) {
        entries = new List<Object>{o1, o2};
    }

    global ListTuple(List<Object> entries) {
        this.entries = entries.clone();
    }

    global Object get(Integer n) {
        return entries[n];
    }

    global Integer size() {
        return entries.size();
    }

    global Iterator<Object> iterator() {
        return entries.iterator();
    }

    private class NewListTuple implements NewInstance {
        public Object newInstance(List<Object> parameters) {
            return new ListTuple(parameters);
        }
    }
}