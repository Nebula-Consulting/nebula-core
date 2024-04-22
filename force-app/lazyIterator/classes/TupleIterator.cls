/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2020
 * @description For iterating over a tuple of iterators. Stops when the first iterator returns hasNext()=false
 */
global class TupleIterator implements Iterator<Tuple> {

    private Tuple iterators;
    private NewInstance tupleType;

    global TupleIterator(List<Iterator<Object>> iterators) {
        this.iterators = new ListTuple(iterators);
        this.tupleType = ListTuple.newInstance;
    }

    global TupleIterator(List<Iterator<Object>> iterators, NewInstance tupleType) {
        this.iterators = new ListTuple(iterators);
        this.tupleType = tupleType;
    }

    global Boolean hasNext() {
        return new LazyIterator(iterators)
                .filter(new IsNot(new HasNext()))
                .firstOrDefault(NoResult.NO_RESULT) == NoResult.NO_RESULT;
    }

    global Tuple next() {
        return (Tuple)tupleType.newInstance(
                new LazyIterator(iterators)
                        .mapValues(new Next())
                        .toList(new List<Object>())
        );
    }
}