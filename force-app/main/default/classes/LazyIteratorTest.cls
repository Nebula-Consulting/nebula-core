/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 */

@IsTest
private class LazyIteratorTest {

    private static List<Account> accounts = new List<Account>{
            new Account(NumberOfEmployees = 1),
            new Account(NumberOfEmployees = 2),
            new Account(NumberOfEmployees = 3),
            new Account(NumberOfEmployees = 4),
            new Account(NumberOfEmployees = 5)
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
        List<Account> result = (List<Account>)new LazySObjectIterator(accounts.iterator())
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

    @IsTest static void forEach() {
        new LazySObjectIterator(accounts.iterator())
                .filter(new NumberOfEmployeesIsOdd())
                .forEach(new SumNumberOfEmployees());

        System.assertEquals(1 + 3 + 5, totalEmployees);
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

    @IsTest static void triggerContextVersion() {
        List<Account> newAccounts = accounts.deepClone();
        newAccounts[1].NumberOfEmployees += 10;
        newAccounts[3].NumberOfEmployees += 10;

        new LazyTriggerContextPairIterator(new TriggerContextIterator(accounts, newAccounts))
                .filter(new NumberOfEmployeesChanged())
                .mapValues(new TriggerContextPair.NewRecordFromPair())
                .forEach(new SumNumberOfEmployees());

        System.assertEquals(12 + 14, totalEmployees);
    }

    @IsTest static void triggerContextMapping() {
        List<Account> newAccounts = accounts.deepClone();
        newAccounts[1].NumberOfEmployees += 10;
        newAccounts[3].NumberOfEmployees += 10;

        List<Account> result = (List<Account>)new LazyTriggerContextPairIterator(accounts, newAccounts)
                .filter(new NumberOfEmployeesChanged())
                .mapValues(new TriggerContextPair.NewRecordFromPair())
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(12, result[0].NumberOfEmployees);
        System.assertEquals(14, result[1].NumberOfEmployees);
    }

    @IsTest static void fieldFromSObject() {
        List<Decimal> numberOfEmployeesList = (List<Decimal>)new LazySObjectIterator(accounts.iterator())
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

    private class SumNumberOfEmployees implements Function{
        public Object call(Object o) {
            return totalEmployees += ((Account)o).NumberOfEmployees;
        }
    }

    private class NumberOfEmployeesChanged extends TriggerContextBooleanFunction {
        public override Boolean isTrueFor(SObject oldRecord, SObject newRecord) {
            return ((Account)oldRecord).NumberOfEmployees != ((Account)newRecord).NumberOfEmployees;
        }
    }
}