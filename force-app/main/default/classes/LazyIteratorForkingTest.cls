/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 */

@IsTest
private class LazyIteratorForkingTest {

    static List<Integer> data = new List<Integer> {1, 2, 3, 4, 5};

    @IsTest static void forkingForEach() {
        List<Object> odds = new List<Object>();
        List<Object> evens = new List<Object>();

        new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new ForEach(new AddToList(odds))),
                new ForkIterator().filter(new IsNot(new IsOdd())).postpone(new ForEach(new AddToList(evens)))
        );

        System.assertEquals(1, odds[0]);
        System.assertEquals(3, odds[1]);
        System.assertEquals(5, odds[2]);
        System.assertEquals(2, evens[0]);
        System.assertEquals(4, evens[1]);
    }

    @IsTest static void forkingForEachUneven() {
        List<Object> odds = new List<Object>();
        List<Object> all = new List<Object>();

        new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new ForEach(new AddToList(odds))),
                new ForkIterator().filter(new IsAlwaysTrue()).postpone(new ForEach(new AddToList(all)))
        );

        System.assertEquals(1, odds[0]);
        System.assertEquals(3, odds[1]);
        System.assertEquals(5, odds[2]);
        for(Integer i=0; i < 5; i++) {
            System.assertEquals(i+1, all[i]);
        }
    }

    @IsTest static void forkingToList() {
        List<Object> results = new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new ToList(new List<Integer>())),
                new ForkIterator().filter(new IsNot(new IsOdd())).postpone(new ToList(new List<Integer>()))
        );

        System.assertEquals(2, results.size());
        System.assert(ForkManager.forkIterators.isEmpty());

        List<Integer> odds = (List<Integer>)results[0];
        List<Integer> evens = (List<Integer>)results[1];

        System.assertEquals(1, odds[0]);
        System.assertEquals(3, odds[1]);
        System.assertEquals(5, odds[2]);
        System.assertEquals(2, evens[0]);
        System.assertEquals(4, evens[1]);
    }

    @IsTest static void sequentialForks() {
        forkingToList();
        List<Object> results = new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new ToList(new List<Integer>())),
                new ForkIterator().filter(new IsNot(new IsOdd())).postpone(new ToList(new List<Integer>()))
        );

        System.assertEquals(2, results.size());
        System.assert(ForkManager.forkIterators.isEmpty());

        List<Integer> odds = (List<Integer>)results[0];
        List<Integer> evens = (List<Integer>)results[1];

        System.assertEquals(1, odds[0]);
        System.assertEquals(3, odds[1]);
        System.assertEquals(5, odds[2]);
        System.assertEquals(2, evens[0]);
        System.assertEquals(4, evens[1]);
    }

    @IsTest static void forkingToListUneven() {
        List<Object> results = new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new ToList(new List<Integer>())),
                new ForkIterator().filter(new IsAlwaysTrue()).postpone(new ToList(new List<Integer>()))
        );

        List<Integer> odds = (List<Integer>)results[0];
        List<Integer> all = (List<Integer>)results[1];

        System.assertEquals(1, odds[0]);
        System.assertEquals(3, odds[1]);
        System.assertEquals(5, odds[2]);
        for(Integer i=0; i < 5; i++) {
            System.assertEquals(i+1, all[i]);
        }
    }

    @IsTest static void forkingReduce() {
        List<Object> results = new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new Reduce(new SumIntegers(), 0)),
                new ForkIterator().filter(new IsNot(new IsOdd())).postpone(new Reduce(new SumIntegers(), 0))
        );

        System.assertEquals(1 + 3 + 5, results[0]);
        System.assertEquals(2 + 4, results[1]);
    }

    @IsTest static void forkingReduceUneven() {
        List<Object> results = new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new Reduce(new SumIntegers(), 0)),
                new ForkIterator().filter(new IsAlwaysTrue()).postpone(new Reduce(new SumIntegers(), 0))
        );

        System.assertEquals(1 + 3 + 5, results[0]);
        System.assertEquals(1 + 2 + 3 + 4 + 5, results[1]);
    }

    @IsTest static void forkingReduceObject() {
        List<Object> results = new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new Reduce(new SumIntegersToSelf())),
                new ForkIterator().filter(new IsNot(new IsOdd())).postpone(new Reduce(new SumIntegersToSelf()))
        );

        System.assertEquals(1 + 3 + 5, ((SumIntegersToSelf)results[0]).total);
        System.assertEquals(2 + 4, ((SumIntegersToSelf)results[1]).total);
    }

    @IsTest static void forkingReduceObjectUneven() {
        List<Object> results = new LazyIterator((List<Object>)data).fork(
                new ForkIterator().filter(new IsOdd()).postpone(new Reduce(new SumIntegersToSelf())),
                new ForkIterator().filter(new IsAlwaysTrue()).postpone(new Reduce(new SumIntegersToSelf()))
        );

        System.assertEquals(1 + 3 + 5, ((SumIntegersToSelf)results[0]).total);
        System.assertEquals(1 + 2 + 3 + 4 + 5, ((SumIntegersToSelf)results[1]).total);
    }

    private class IsOdd implements BooleanFunction {
        public Boolean isTrueFor(Object o) {
            return Math.mod(((Integer)o), 2) == 1;
        }
    }

    private class IsAlwaysTrue implements BooleanFunction {
        public Boolean isTrueFor(Object o) {
            return true;
        }
    }

    private class AddToList implements VoidFunction {

        private List<Object> theList;

        public AddToList(List<Object> theList) {
            this.theList = theList;
        }

        public void call(Object o) {
            theList.add(o);
        }
    }

    private class SumIntegers implements AccumulatorFunction {
        public Object nextValue(Object accumulatorValue, Object currentValue) {
            return (Integer)accumulatorValue + (Integer)currentValue;
        }
    }

    private class SumIntegersToSelf implements VoidFunction {

        public Integer total = 0;

        public void call(Object o) {
            total += (Integer)o;
        }
    }

    private class NestedFork implements VoidFunction {
        public void call(Object o) {
            new LazyIterator(new SingletonIterator(o)).fork(
                    new ForkIterator().postpone(new ForEach(new SumIntegersToSelf())),
                    new ForkIterator().postpone(new ForEach(new SumIntegersToSelf()))
            );
        }
    }
}