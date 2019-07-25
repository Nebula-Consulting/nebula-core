/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 */

public class SingletonIterator implements Iterator<Object> {

    private Boolean hasNext = true;
    private Object value;

    public SingletonIterator(Object value) {
        this.value = value;
    }

    public Boolean hasNext() {
        if(hasNext) {
            hasNext = false;
            return true;
        } else {
            return false;
        }
    }

    public Object next() {
        return value;
    }

}