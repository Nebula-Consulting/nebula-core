/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 */

@IsTest
private class LazyIteratorTest {

    private static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);

    private static List<Account> accounts = new List<Account>{
            new Account(NumberOfEmployees = 1, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 2, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 3, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 4, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 5, ParentId = accountIdGenerator.next())
    };

    @IsTest
    static void filter() {
        Account result = (Account)new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIsOdd())
                .next();

        System.assertEquals(1, result.NumberOfEmployees);
    }

    @IsTest
    static void filterNoResult() {
        Iterator<Object> filteredIterator = new LazySObjectIterator(new List<Account>().iterator())
                .filter(new NumberOfEmployeesIsOdd());

        System.assert(!filteredIterator.hasNext());

        try {
            filteredIterator.next();
        } catch (NoSuchElementException e) {
            return;
        }
        System.assert(false, 'Should have thrown NoSuchElementException');
    }

    @IsTest
    static void filterToList() {
        List<Account> result = new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIsOdd())
                .toList(new List<Account>());

        System.assertEquals(3, result.size(), result);
        System.assertEquals(1, result[0].NumberOfEmployees);
        System.assertEquals(3, result[1].NumberOfEmployees);
        System.assertEquals(5, result[2].NumberOfEmployees);
    }

    @IsTest static void filterAndMap() {
        List<Account> result = (List<Account>)new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIsOdd())
                .mapValues(new DoubleNumberOfEmployeesMapping())
                .toList(new List<Account>());

        System.assertEquals(3, result.size(), result);
        System.assertEquals(2, result[0].NumberOfEmployees);
        System.assertEquals(6, result[1].NumberOfEmployees);
        System.assertEquals(10, result[2].NumberOfEmployees);
    }

    @IsTest static void filterWithMapInFilter() {
        List<Account> result = (List<Account>)new LazySObjectIterator(accounts.iterator())
                .filter(new FieldFromSObject(Account.NumberOfEmployees), new IsEqual(1))
                .mapValues(new DoubleNumberOfEmployeesMapping())
                .toList(new List<Account>());

        System.assertEquals(1, result.size(), result);
        System.assertEquals(2, result[0].NumberOfEmployees);
    }

    @IsTest static void doubleFilter() {
        List<Account> result = (List<Account>)new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIsOdd())
                .filter(new IsUniqueOn(new FieldFromSObject(Account.Name)))
                .toList(new List<Account>());

        System.assertEquals(1, result.size(), result);
        System.assertEquals(accounts[0].ParentId, result[0].ParentId);
    }

    @IsTest static void uniquePrimitives() {
        List<Integer> result = (List<Integer>)new LazyIterator(new List<Object>{1, 2, 1, 3, 3})
                .filter(new IsUnique())
                .toList(new List<Integer>());

        System.assertEquals(3, result.size(), result);
        System.assertEquals(1, result[0]);
        System.assertEquals(2, result[1]);
        System.assertEquals(3, result[2]);
    }

    @IsTest static void forEach() {
        new LazySObjectIterator(accounts.iterator())
                .filter(new IsNot(new NumberOfEmployeesIsOdd()))
                .forEach(new SumNumberOfEmployees());

        System.assertEquals(2 + 4, totalEmployees);
    }

    @IsTest static void reduceWithFunction() {
        Decimal reduceTotal = (Decimal)new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIsOdd())
                .reduce(new SumNumberOfEmployeesAccumulator(), 0);

        System.assertEquals(1 + 3 + 5, reduceTotal);
    }

    @IsTest static void reduceWithObject() {
        SumNumberOfEmployeesAccumulatorObject reduceTotal = (SumNumberOfEmployeesAccumulatorObject)new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIsOdd())
                .reduce(new SumNumberOfEmployeesAccumulatorObject());

        System.assertEquals(1 + 3 + 5, reduceTotal.accumulatorValue);
    }

    @IsTest static void firstOrDefault() {
        String defaultName = 'Default Result';
        Account result = (Account)new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIs(10))
                .firstOrDefault(new Account(Name = defaultName));

        System.assertEquals(defaultName, result.Name);

        result = (Account)new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIs(3))
                .firstOrDefault(new Account(Name = defaultName));

        System.assertEquals(null, result.Name);
        System.assertEquals(3, result.NumberOfEmployees);
    }

    @IsTest static void fieldFromSObject() {
        List<Decimal> numberOfEmployeesList = (List<Decimal>)new LazySObjectIterator(accounts)
                .mapValues(new FieldFromSObject(Account.NumberOfEmployees))
                .toList(new List<Decimal>());

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].NumberOfEmployees, numberOfEmployeesList[i]);
        }
    }

    @IsTest static void fieldFromSObjectString() {
        List<Decimal> numberOfEmployeesList = (List<Decimal>)new LazySObjectIterator(accounts.iterator())
                .mapValues(new FieldFromSObjectString(Account.NumberOfEmployees.getDescribe().getName()))
                .toList(new List<Decimal>());

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].NumberOfEmployees, numberOfEmployeesList[i]);
        }
    }

    @IsTest static void fieldFromSObjectSetId() {
        Set<Id> parentIdSet = (Set<Id>)new LazySObjectIterator(accounts)
                .mapValues(new FieldFromSObject(Account.ParentId))
                .toSet(new Set<Id>());

        for(Integer i=0; i < accounts.size(); i++) {
            System.assert(parentIdSet.contains(accounts[i].ParentId));
        }
    }

    @IsTest static void defaultIfEmptyNotEmpty() {
        List<Integer> data = new List<Integer>{45, 89};
        Integer defaultValue = 99;

        List<Integer> result = (List<Integer>)new LazyIterator((List<Object>)data)
                .setDefaultIfEmpty(defaultValue)
                .toList(new List<Integer>());

        System.assertEquals(data.size(), result.size());
        for(Integer i=0; i < data.size(); i++) {
            System.assertEquals(data[i], result[i]);
        }
    }

    @IsTest static void defaultIfEmptyEmpty() {
        Integer defaultValue = 99;

        List<Integer> result = (List<Integer>)new LazyIterator((List<Object>)new List<Integer>())
                .setDefaultIfEmpty(defaultValue)
                .toList(new List<Integer>());

        System.assertEquals(1, result.size());
        System.assertEquals(defaultValue, result[0]);
    }

    @IsTest static void take() {
        LazySObjectIterator accountIterator = new LazySObjectIterator(accounts);
        List<Account> result = (List<Account>)accountIterator
                .take(3)
                .toList(new List<Account>());

        System.assertEquals(3, result.size());
        for(Integer i=0; i < 3; i++) {
            System.assertEquals(accounts[i], result[i]);
        }
        List<Account> result2 = (List<Account>)accountIterator
                .toList(new List<Account>());

        System.assertEquals(accounts.size()-3, result2.size());
        for(Integer i=0; i < result2.size(); i++) {
            System.assertEquals(accounts[result.size() + i], result2[i]);
        }
    }

    @IsTest static void append() {
        List<Integer> result = (List<Integer>)new LazyIterator(new List<Object>{0, 1, 2})
                .append(new LazyIterator(new List<Object>{3, 4, 5}))
                .toList( new List<Integer>());

        for(Integer i=0; i < 6; i++) {
            System.assertEquals(i, result[i]);
        }
    }

    @IsTest static void appendSingle() {
        List<Integer> result = (List<Integer>)new LazyIterator(new List<Object>{0, 1, 2})
                .append(3)
                .toList( new List<Integer>());

        for(Integer i=0; i < 4; i++) {
            System.assertEquals(i, result[i]);
        }
    }

    @IsTest static void prepend() {
        List<Integer> result = (List<Integer>)new LazyIterator(new List<Object>{3, 4, 5})
                .prepend(new LazyIterator(new List<Object>{0, 1, 2}))
                .toList( new List<Integer>());

        for(Integer i=0; i < 6; i++) {
            System.assertEquals(i, result[i]);
        }
    }

    @IsTest static void prependSingle() {
        List<Integer> result = (List<Integer>)new LazyIterator(new List<Object>{1, 2, 3})
                .prepend(0)
                .toList( new List<Integer>());

        for(Integer i=0; i < 4; i++) {
            System.assertEquals(i, result[i]);
        }
    }

    @IsTest static void iterateOnNull() {
        Object o = null;
        LazyIterator it = new LazyIterator(o);

        System.assert(!it.hasNext());
        try {
            it.next();
        } catch(NoSuchElementException e) {
            return;
        }
        System.assert(false, 'Expected a NoSuchElementException');
    }

    @IsTest
    static void observeParentIds() {
        Set<Id> results = new Set<Id>();

        Test.startTest();
        List<Account> unchanged = new LazySObjectIterator(accounts)
                .observeValuesT(new Composition(new FieldFromSObject(Account.ParentId)).compose(new AddTo(results)))
                .toList();
        Test.stopTest();

        System.assertEquals(accounts.size(), results.size());
        for(Integer i=0; i < accounts.size(); i++) {
            System.assert(results.contains(accounts[i].ParentId));
            System.assertEquals(accounts[i], unchanged[i]);
        }
    }

    @IsTest
    static void observeFilteredParentIds() {
        Set<Id> results = new Set<Id>();

        Test.startTest();
        List<Account> unchanged = new LazySObjectIterator(accounts)
                .observeValues(new NumberOfEmployeesIsOdd(), new Composition(new FieldFromSObject(Account.ParentId)).compose(new AddTo(results)))
                .toSObjectIterator()
                .toList();
        Test.stopTest();

        for(Integer i=0; i < accounts.size(); i++) {
            if(Math.mod(accounts[i].NumberOfEmployees, 2) == 1) {
                System.assert(results.contains(accounts[i].ParentId));
            }
            System.assertEquals(accounts[i], unchanged[i]);
        }
    }

    private class NumberOfEmployeesIs implements BooleanFunction {
        private Integer target;

        public NumberOfEmployeesIs(Integer target) {
            this.target = target;
        }

        public Boolean isTrueFor(Object testObject) {
            return ((Account)testObject).NumberOfEmployees == target;
        }
    }

    private class NumberOfEmployeesIsOdd implements BooleanFunction {
        public Boolean isTrueFor(Object testObject) {
            return Math.mod(((Account)testObject).NumberOfEmployees, 2) == 1;
        }
    }

    private class DoubleNumberOfEmployeesMapping implements Function {
        public Object call(Object input) {
            ((Account)input).NumberOfEmployees *= 2;
            return input;
        }
    }

    private static Integer totalEmployees = 0;

    private class SumNumberOfEmployees implements VoidFunction {
        public void call(Object o) {
            totalEmployees += ((Account)o).NumberOfEmployees;
        }
    }

    private class SumNumberOfEmployeesAccumulator implements AccumulatorFunction {
        public Object nextValue(Object accumulatorValue, Object currentValue) {
            return (Decimal)accumulatorValue + ((Account)currentValue).NumberOfEmployees;
        }
    }

    private class SumNumberOfEmployeesAccumulatorObject implements VoidFunction {

        public Decimal accumulatorValue = 0;

        public void call(Object currentValue) {
            accumulatorValue += ((Account)currentValue).NumberOfEmployees;
        }
    }
}