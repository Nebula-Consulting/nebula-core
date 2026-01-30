/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description setValue() is called, then hasNext()/next() ought to act like an iterator. When setValue is called
 * again, the underlying value changes and a new iteration begins
 */
global interface ExpansionFunction extends Iterator<Object> {

    void setValue(Object value);

    Boolean hasNext();
    Object next();
}