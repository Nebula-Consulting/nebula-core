/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description Manages a single call to LazyIterator.fork() by sharing out the data from the underlying iterator to
 * each of the forks via a ForkIterator, and calling each of the terminator functions
 */

global class ForkManager {

    private LazyIterator iterator;
    public static List<ForkIterator> forkIterators = new List<ForkIterator>();
    @TestVisible
    private List<TerminatorFunction> terminatorFunctions;

    public ForkManager(LazyIterator iterator) {
        this.iterator = iterator;
        this.terminatorFunctions = new List<TerminatorFunction>();
    }

    global ForkManager addFork(TerminatorFunction terminatorFunction) {
        terminatorFunctions.add(terminatorFunction);
        return this;
    }

    global List<Object> toList(List<Object> toFill) {
        return evaluateForks().toList(toFill);
    }

    public ForkManager(LazyIterator iterator, List<TerminatorFunction> terminatorFunctions) {
        this.iterator = iterator;
        this.terminatorFunctions = terminatorFunctions;
    }

    global LazyIterator evaluateForks() {
        System.assertEquals(terminatorFunctions.size(), forkIterators.size(), Label.LazyIterator_Nested_Forking_Error);

        iterator.forEach(new IterateTerminatorFunctions(terminatorFunctions));

        forkIterators.clear();

        return new LazyIterator((List<Object>)terminatorFunctions)
                .mapValues(new GetResultFromTerminatorFunction());
    }

    private class IterateTerminatorFunctions implements VoidFunction {

        private List<TerminatorFunction> terminatorFunctions;

        public IterateTerminatorFunctions(List<TerminatorFunction> terminatorFunctions) {
            this.terminatorFunctions = terminatorFunctions;
        }

        public void call(Object o) {
            for(ForkIterator thisForkIterator : forkIterators) {
                thisForkIterator.setIterator(new SingletonIterator(o));
            }
            for(TerminatorFunction thisTerminatorFunction : terminatorFunctions) {
                thisTerminatorFunction.call();
            }
        }
    }

    private class GetResultFromTerminatorFunction implements Function {
        public Object call(Object o) {
            return ((TerminatorFunction)o).getResult();
        }
    }
}