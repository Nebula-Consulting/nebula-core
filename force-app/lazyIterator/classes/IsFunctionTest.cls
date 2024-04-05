/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 25/09/2019
 */

@IsTest
private class IsFunctionTest {

    static nebc.TestIdGenerator accountIdGenerator = new nebc.TestIdGenerator(Account.SObjectType);
    static nebc.TestIdGenerator eventIdGenerator = new nebc.TestIdGenerator(Event.SObjectType);

    static List<Account> accounts = new List<Account> {
            new Account(Id = accountIdGenerator.next(), Name = 'Account One', NumberOfEmployees = 0),
            new Account(Id = accountIdGenerator.next(), Name = 'Account Two', NumberOfEmployees = 1)
    };

    static List<Event> events = new List<Event> {
            new Event(Id = eventIdGenerator.next(), ActivityDate = Date.today(), RecurrenceEndDateOnly = Date.today().addDays(1)),
            new Event(Id = eventIdGenerator.next(), ActivityDate = Date.today(), RecurrenceEndDateOnly = Date.today().addDays(-1)),
            new Event(Id = eventIdGenerator.next(), ActivityDate = Date.today(), RecurrenceEndDateOnly = Date.today())
    };

    @IsTest
    static void lessThanDirect() {
        List<Integer> result = (List<Integer>)new LazyIterator(new List<Object>{0, 1, 2, 3, 4, 5})
                .filter(new IsLessThan(3))
                .toList(new List<Integer>());

        System.assertEquals(3, result.size());
        System.assertEquals(0, result[0]);
        System.assertEquals(1, result[1]);
        System.assertEquals(2, result[2]);
    }

    @IsTest
    static void lessThanSObjectFields() {
        List<Event> result = new LazySObjectIterator(events)
                .filterT(new IsLessThan(Event.ActivityDate, Event.RecurrenceEndDateOnly))
                .toList();

        System.assertEquals(1, result.size());
        System.assertEquals(events[0].Id, result[0].Id);

    }

    @IsTest
    static void lessThanConstant() {
        List<Account> result = new LazySObjectIterator(accounts)
                .filter(new IsLessThan(new FieldFromSObject(Account.NumberOfEmployees), 1))
                .toList(new List<Account>());

        System.assertEquals(1, result.size());
        System.assertEquals(accounts[0].Id, result[0].Id);
    }

    @IsTest
    static void lessThanFunction() {
        List<Account> result = new LazySObjectIterator(accounts)
                .filter(new IsLessThan(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{1, 2})))
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(accounts[0].Id, result[0].Id);
        System.assertEquals(accounts[1].Id, result[1].Id);

        result = new LazySObjectIterator(accounts)
                .filter(new IsLessThan(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{0, 2})))
                .toList(new List<Account>());

        System.assertEquals(1, result.size());
        System.assertEquals(accounts[1].Id, result[0].Id);

        result = new LazySObjectIterator(accounts)
                .filter(new IsLessThan(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{0, 0})))
                .toList(new List<Account>());

        System.assertEquals(0, result.size());
    }

    @IsTest
    static void greaterThanFunction() {
        List<Account> result = new LazySObjectIterator(accounts)
                .filter(new IsGreaterThan(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{-1, 0})))
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(accounts[0].Id, result[0].Id);
        System.assertEquals(accounts[1].Id, result[1].Id);

        result = new LazySObjectIterator(accounts)
                .filter(new IsGreaterThan(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{1, 0})))
                .toList(new List<Account>());

        System.assertEquals(1, result.size());
        System.assertEquals(accounts[1].Id, result[0].Id);

        result = new LazySObjectIterator(accounts)
                .filter(new IsGreaterThan(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{1, 1})))
                .toList(new List<Account>());

        System.assertEquals(0, result.size());
    }

    @IsTest
    static void greaterThanSObjectFields() {
        List<Event> result = new LazySObjectIterator(events)
                .filterT(new IsGreaterThan(Event.ActivityDate, Event.RecurrenceEndDateOnly))
                .toList();

        System.assertEquals(1, result.size());
        System.assertEquals(events[1].Id, result[0].Id);

    }

    @IsTest
    static void equalFunction() {
        List<Account> result = new LazySObjectIterator(accounts)
                .filter(new IsEqual(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{0, 1})))
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(accounts[0].Id, result[0].Id);
        System.assertEquals(accounts[1].Id, result[1].Id);

        result = new LazySObjectIterator(accounts)
                .filter(new IsEqual(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{1, 1})))
                .toList(new List<Account>());

        System.assertEquals(1, result.size());
        System.assertEquals(accounts[1].Id, result[0].Id);

        result = new LazySObjectIterator(accounts)
                .filter(new IsEqual(new FieldFromSObject(Account.NumberOfEmployees), new LazyIterator(new List<Object>{2, 2})))
                .toList(new List<Account>());

        System.assertEquals(0, result.size());
    }

    @IsTest
    static void equalSObjectFields() {
        List<Event> result = new LazySObjectIterator(events)
                .filterT(new IsEqual(Event.ActivityDate, Event.RecurrenceEndDateOnly))
                .toList();

        System.assertEquals(1, result.size());
        System.assertEquals(events[2].Id, result[0].Id);
    }

}