/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description (if required)
 */

public class ForkManager {

    private LazyIterator iterator;
    public static List<ForkIterator> forkIterators = new List<ForkIterator>();
    private List<TerminatorFunction> terminatorFunctions;

    public ForkManager(LazyIterator iterator, List<TerminatorFunction> terminatorFunctions) {
        this.iterator = iterator;
        this.terminatorFunctions = terminatorFunctions;
    }

    public List<Object> getResults() {
        while(iterator.hasNext()) {
            Object peek = iterator.next();
            for(ForkIterator thisForkIterator : forkIterators) {
                thisForkIterator.setIterator(new SingletonIterator(peek));
            }
            for(TerminatorFunction thisTerminatorFunction : terminatorFunctions) {
                thisTerminatorFunction.call();
            }
        }
        return new LazyIterator((List<Object>)terminatorFunctions)
                .mapValues(new GetResultFromTerminatorFunction())
                .toList(new List<Object>());
    }

    private class GetResultFromTerminatorFunction implements Function {
        public Object call(Object o) {
            return ((TerminatorFunction)o).getResult();
        }
    }
}