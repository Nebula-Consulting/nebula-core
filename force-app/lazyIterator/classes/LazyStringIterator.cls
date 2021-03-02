/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 28/11/2019
 * @description String-typed version of LazyIterator
 */

global class LazyStringIterator extends LazyIterator {

    global LazyStringIterator(Object iterableOrIterator) {
        super(iterableOrIterator);
    }
}