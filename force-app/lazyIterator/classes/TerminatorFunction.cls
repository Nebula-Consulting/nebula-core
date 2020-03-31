/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description A function on a LazyIterator that returns results instead of another LazyIterator
 */

global interface TerminatorFunction {
    void call();
    TerminatorFunction setIterator(LazyIterator iterator);
    Object getResult();
}