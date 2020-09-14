/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/09/2020
 */

@IsTest
private class LazyTriggerContextPairIteratorTest {

    private static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);

    private static List<Account> accounts = new List<Account>{
            new Account(NumberOfEmployees = 1, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 2, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 3, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 4, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 5, ParentId = accountIdGenerator.next())
    };

    @IsTest static void fieldChanged() {
        List<Account> newAccounts = accounts.deepClone();
        newAccounts[1].NumberOfEmployees += 10;
        newAccounts[3].NumberOfEmployees += 10;

        new LazyTriggerContextPairIterator(new TriggerContextIterator(accounts, newAccounts))
                .filterT(new IsFieldChangedInTrigger(Account.NumberOfEmployees))
                .newRecords()
                .forEach(new SumNumberOfEmployees());

        System.assertEquals(12 + 14, totalEmployees);
    }

    @IsTest static void bothRecords() {
        List<Account> newAccounts = new List<Account>{
        new Account(NumberOfEmployees = 1, ParentId = accountIdGenerator.next()),
        new Account(NumberOfEmployees = 2, ParentId = accountIdGenerator.next()),
        new Account(NumberOfEmployees = 3, ParentId = accountIdGenerator.next()),
        new Account(NumberOfEmployees = 4, ParentId = accountIdGenerator.next()),
        new Account(NumberOfEmployees = 5, ParentId = accountIdGenerator.next())
                };

        List<Account> result = (List<Account>)new LazyTriggerContextPairIterator(accounts, newAccounts)
                .bothRecords()
                .toList();

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].ParentId, result[i*2].ParentId);
            System.assertEquals(newAccounts[i].ParentId, result[i*2+1].ParentId);
        }
    }

    @IsTest static void newRecords() {
        List<Account> newAccounts = accounts.deepClone();
        newAccounts[1].NumberOfEmployees += 10;
        newAccounts[3].NumberOfEmployees += 10;

        List<Account> result = (List<Account>)new LazyTriggerContextPairIterator(accounts, newAccounts)
                .filterT(new IsFieldChangedInTrigger(Account.NumberOfEmployees))
                .newRecords()
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(12, result[0].NumberOfEmployees);
        System.assertEquals(14, result[1].NumberOfEmployees);
    }

    @IsTest static void filterBecameTrue() {
        List<Account> newAccounts = accounts.deepClone();
        newAccounts[1].NumberOfEmployees = 10;
        newAccounts[3].NumberOfEmployees = 10;

        List<Account> result = new LazyTriggerContextPairIterator(accounts, newAccounts)
                .filterBecameTrue(new IsEqual(Account.NumberOfEmployees, 10))
                .newRecords()
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(10, result[0].NumberOfEmployees);
        System.assertEquals(10, result[1].NumberOfEmployees);
    }

    private static Integer totalEmployees = 0;

    private class SumNumberOfEmployees implements VoidFunction {
        public void call(Object o) {
            totalEmployees += ((Account)o).NumberOfEmployees;
        }
    }
}