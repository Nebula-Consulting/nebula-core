/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/09/2020
 * @description Expects to be called on an Iterator<Object>. Returns next() if available, else defaultObject
 */
global class FirstOrDefault implements Function {

    private Object defaultObject;

    global FirstOrDefault(Object defaultObject) {
        this.defaultObject = defaultObject;
    }

    global Object call(Object o) {
        Iterator<Object> iterator = (Iterator<Object>)o;
        return iterator.hasNext() ? iterator.next() : defaultObject;
    }
}