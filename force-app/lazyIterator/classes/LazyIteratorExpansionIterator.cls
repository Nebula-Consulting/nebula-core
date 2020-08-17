/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 20/07/2020
 * @description Allows you to flatten a list of iterables by using LazyIterator on each one
 */

global class LazyIteratorExpansionIterator implements ExpansionIterator {
    global Iterator<Object> setValue(Object value) {
        return new LazyIterator(value);
    }
}