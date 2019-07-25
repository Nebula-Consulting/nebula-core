/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description (if required)
 */

global interface TerminatorFunction {
    void call();
    TerminatorFunction setIterator(LazyIterator iterator);
    Object getResult();
}