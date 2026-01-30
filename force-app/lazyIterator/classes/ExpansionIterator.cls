/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 19/05/2020
 * @description For iterables where each item can itself be turned into something iterable. See LazyIterator.expand()
 */
global interface ExpansionIterator {
     Iterator<Object> setValue(Object value);
}