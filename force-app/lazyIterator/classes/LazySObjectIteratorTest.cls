/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 15/05/2020
 */

@IsTest
private class LazySObjectIteratorTest {

    private static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);

    private static List<Account> accounts = new List<Account>{
            new Account(NumberOfEmployees = 1, Id = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 2, Id = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 3, Id = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 4, Id = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 5, Id = accountIdGenerator.next())
    };

    @IsTest
    static void put() {
        List<String> accountNames = new List<String>();
        for(Integer i=0; i < accounts.size(); i++) {
            accountNames.add('ACME ' + i);
        }

        Test.startTest();
        List<Account> results = new LazySObjectIterator(accounts)
                .put(Account.Name, new LazyIterator(accountNames))
                .toList();
        Test.stopTest();

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accountNames[i], results[i].Name);
        }
    }
    @IsTest
    static void putIf() {
        List<String> accountNames = new List<String>();
        for(Integer i=0; i < accounts.size(); i++) {
            accountNames.add('ACME ' + i);
        }
        Integer threshold = 2;

        Test.startTest();
        List<Account> results = new LazySObjectIterator(accounts)
                .putIf(new IsGreaterThan(new FieldFromSObject(Account.NumberOfEmployees), threshold), Account.Name, new LazyIterator(accountNames))
                .toList();
        Test.stopTest();

        for(Integer i=0; i < accounts.size(); i++) {
            if(accounts[i].NumberOfEmployees > threshold) {
                System.assertEquals(accountNames[i-threshold], results[i].Name);
            } else {
                System.assertEquals(null, results[i].Name);
            }
        }
    }

    @IsTest
    static void filterPut() {
        List<String> accountNames = new List<String>();
        for(Integer i=0; i < accounts.size(); i++) {
            accountNames.add('ACME ' + i);
        }
        Integer threshold = 2;

        Test.startTest();
        List<Account> results = new LazySObjectIterator(accounts)
                .filterT(new IsGreaterThan(new FieldFromSObject(Account.NumberOfEmployees), threshold))
                .put(Account.Name, new LazyIterator(accountNames))
                .toList();
        Test.stopTest();

        for(Integer i=0; i < accounts.size(); i++) {
            if(accounts[i].NumberOfEmployees > threshold) {
                System.assertEquals(accountNames[i-threshold], results[i-threshold].Name, results);
            }
        }
    }

    @IsTest
    static void filterMapPut() {
        List<String> accountNames = new List<String>();
        for(Integer i=0; i < accounts.size(); i++) {
            accountNames.add('ACME ' + i);
        }
        Integer threshold = 2;

        Test.startTest();
        List<Account> results = new LazySObjectIterator(accounts)
                .filterT(new FieldFromSObject(Account.NumberOfEmployees), new IsGreaterThan(threshold))
                .put(Account.Name, new LazyIterator(accountNames))
                .toList();
        Test.stopTest();

        for(Integer i=0; i < accounts.size(); i++) {
            if(accounts[i].NumberOfEmployees > threshold) {
                System.assertEquals(accountNames[i-threshold], results[i-threshold].Name, results);
            }
        }
    }

    @IsTest
    static void getList() {
        Test.startTest();
        List<Id> results = (List<Id>)new LazySObjectIterator(accounts)
                .get(Account.Id, new List<Id>());
        Test.stopTest();

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].Id, results[i]);
        }
    }

    @IsTest
    static void getSet() {
        Test.startTest();
        Set<Id> results = new LazySObjectIterator(accounts)
                .get(Account.Id, new Set<Id>());
        Test.stopTest();

        System.assertEquals(accounts.size(), results.size());
        for(Integer i=0; i < accounts.size(); i++) {
            System.assert(results.contains(accounts[i].Id));
        }
    }

    @IsTest
    static void getIterator() {
        Test.startTest();
        List<Id> results = (List<Id>)new LazySObjectIterator(accounts)
                .get(Account.Id)
                .toList(new List<Id>());
        Test.stopTest();

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].Id, results[i]);
        }
    }
}