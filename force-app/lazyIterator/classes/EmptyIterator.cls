/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 29/04/2020
 * @description An iterator representing no data/results
 */
global class EmptyIterator implements Iterator<Object> {

    private static EmptyIterator instance;

    private EmptyIterator() {}

    global static EmptyIterator getInstance() {
        if(instance == null) {
            instance = new EmptyIterator();
        }
        return instance;
    }

    global Boolean hasNext() {
        return false;
    }

    global Object next() {
        throw new NoSuchElementException();
    }
}