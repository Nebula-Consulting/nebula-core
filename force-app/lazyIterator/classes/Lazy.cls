/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 02/04/2020
 * @description A convenience constructor for LazyIterator, making it a bit shorter than using "new"
 */

public with sharing class Lazy {
    public static LazyIterator iterator(Object iteratorOrIterable) {
        return new LazyIterator(iteratorOrIterable);
    }
}