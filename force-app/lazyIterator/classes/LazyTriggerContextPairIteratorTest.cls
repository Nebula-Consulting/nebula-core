/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/09/2020
 */

@IsTest
private class LazyTriggerContextPairIteratorTest {

    private static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);

    private static List<Account> oldAccounts = new List<Account>{
            new Account(NumberOfEmployees = 1, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 2, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 3, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 4, ParentId = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 5, ParentId = accountIdGenerator.next())
    };

    @IsTest static void fieldChanged() {
        List<Account> newAccounts = oldAccounts.deepClone();
        newAccounts[1].NumberOfEmployees += 10;
        newAccounts[3].NumberOfEmployees += 10;

        new LazyTriggerContextPairIterator(new TriggerContextIterator(oldAccounts, newAccounts))
                .filterT(new IsFieldChangedInTrigger(Account.NumberOfEmployees))
                .newRecords()
                .forEach(new SumNumberOfEmployees());

        System.assertEquals(12 + 14, totalEmployees);
    }

    @IsTest static void copyOldFieldValueToNewField() {
        List<Account> newAccounts = oldAccounts.deepClone();
        newAccounts[1].ParentId = accountIdGenerator.next();
        newAccounts[3].ParentId = accountIdGenerator.next();

        List<Account> results = new LazyTriggerContextPairIterator(oldAccounts, newAccounts)
                .filterT(new IsFieldChangedInTrigger(Account.ParentId))
                .mapNewFromOld(Account.Description, Account.ParentId)
                .newRecords()
                .toList();

        System.assertEquals(oldAccounts[1].ParentId, results[0].Description);
        System.assertEquals(oldAccounts[3].ParentId, results[1].Description);
    }

    @IsTest static void copyOldFieldValueToNewFunction() {
        List<Account> newAccounts = oldAccounts.deepClone();
        newAccounts[1].ParentId = accountIdGenerator.next();
        newAccounts[3].ParentId = accountIdGenerator.next();

        List<Account> results = new LazyTriggerContextPairIterator(oldAccounts, newAccounts)
                .filterT(new IsFieldChangedInTrigger(Account.ParentId))
                .mapNewFromOld(Account.Description, Account.ParentId, new StringFormat('Prior Parent Id: {0}'))
                .newRecords()
                .toList();

        System.assertEquals('Prior Parent Id: ' + oldAccounts[1].ParentId, results[0].Description);
        System.assertEquals('Prior Parent Id: ' + oldAccounts[3].ParentId, results[1].Description);
    }

    @IsTest static void bothRecords() {
        List<Account> newAccounts = new List<Account>{
                new Account(NumberOfEmployees = 1, ParentId = accountIdGenerator.next()),
                new Account(NumberOfEmployees = 2, ParentId = accountIdGenerator.next()),
                new Account(NumberOfEmployees = 3, ParentId = accountIdGenerator.next()),
                new Account(NumberOfEmployees = 4, ParentId = accountIdGenerator.next()),
                new Account(NumberOfEmployees = 5, ParentId = accountIdGenerator.next())
        };

        List<Account> result = (List<Account>)new LazyTriggerContextPairIterator(oldAccounts, newAccounts)
                .bothRecords()
                .toList();

        for(Integer i=0; i < oldAccounts.size(); i++) {
            System.assertEquals(oldAccounts[i].ParentId, result[i*2].ParentId);
            System.assertEquals(newAccounts[i].ParentId, result[i*2+1].ParentId);
        }
    }

    @IsTest static void newRecords() {
        List<Account> newAccounts = oldAccounts.deepClone();
        newAccounts[1].NumberOfEmployees += 10;
        newAccounts[3].NumberOfEmployees += 10;

        List<Account> result = (List<Account>)new LazyTriggerContextPairIterator(oldAccounts, newAccounts)
                .filterT(new IsFieldChangedInTrigger(Account.NumberOfEmployees))
                .newRecords()
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(12, result[0].NumberOfEmployees);
        System.assertEquals(14, result[1].NumberOfEmployees);
    }

    @IsTest static void filterBecameTrue() {
        List<Account> newAccounts = oldAccounts.deepClone();
        newAccounts[1].NumberOfEmployees = 10;
        newAccounts[3].NumberOfEmployees = 10;

        List<Account> result = new LazyTriggerContextPairIterator(oldAccounts, newAccounts)
                .filterBecameTrue(new IsEqual(Account.NumberOfEmployees, 10))
                .newRecords()
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(10, result[0].NumberOfEmployees);
        System.assertEquals(10, result[1].NumberOfEmployees);
    }

    @IsTest static void filterBecameTrueNoOldList() {
        List<Account> newAccounts = oldAccounts.deepClone();
        newAccounts[1].NumberOfEmployees = 10;
        newAccounts[3].NumberOfEmployees = 10;

        List<Account> result = new LazyTriggerContextPairIterator(null, newAccounts)
                .filterBecameTrue(new IsEqual(Account.NumberOfEmployees, 10))
                .newRecords()
                .toList(new List<Account>());

        System.assertEquals(2, result.size());
        System.assertEquals(10, result[0].NumberOfEmployees);
        System.assertEquals(10, result[1].NumberOfEmployees);
    }

    @IsTest
    static void filterBecameFalse() {
        List<Account> oldList = new List<Account>{
                new Account(Name = 'Acme'),
                new Account(Name = 'Acme'),
                null,
                new Account(Name = 'Not Acme')
        };

        List<Account> newList = new List<Account> {
                new Account(Id = accountIdGenerator.next(), Name = 'Not Acme'),
                new Account(Id = accountIdGenerator.next(), Name = 'Acme'),
                new Account(Id = accountIdGenerator.next(), Name = 'Not Acme'),
                new Account(Id = accountIdGenerator.next(), Name = 'Acme')
        };

        List<Account> result = new LazyTriggerContextPairIterator(oldList, newList)
                .filterBecameFalse(new IsSObjectFieldEqual(Account.Name, 'Acme'))
                .newRecords()
                .toList();

        System.assertEquals(1, result.size());
        System.assertEquals(newList[0].Id, result[0].Id);
    }

    @IsTest
    static void filterBecameFalseNullOldValues() {
        List<Account> oldList = new List<Account>{
                new Account(Name = 'Acme'),
                new Account(),
                null,
                new Account(Name = 'Not Null')
        };

        List<Account> newList = new List<Account> {
                new Account(Id = accountIdGenerator.next(), Name = 'Not Acme'),
                new Account(Id = accountIdGenerator.next(), Name = 'Acme'),
                new Account(Id = accountIdGenerator.next(), Name = 'Not Acme'),
                new Account(Id = accountIdGenerator.next())
        };

        List<Account> result = new LazyTriggerContextPairIterator(oldList, newList)
                .filterBecameFalse(new IsSObjectFieldEqual(Account.Name, null))
                .newRecords()
                .toList();

        System.assertEquals(1, result.size());
        System.assertEquals(newList[1].Id, result[0].Id);
    }

    private static Integer totalEmployees = 0;

    private class SumNumberOfEmployees implements VoidFunction {
        public void call(Object o) {
            totalEmployees += ((Account)o).NumberOfEmployees;
        }
    }
}