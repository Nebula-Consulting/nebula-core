/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/07/2021
 */

@IsTest
private class AddToTest {

    static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);

    static List<Account> accounts = new List<Account> {
            new Account(Id = accountIdGenerator.next(), Name = 'A'),
            new Account(Id = accountIdGenerator.next(), Name = 'B')
    };

    @IsTest
    static void setString() {
        Set<String> accountNames = new Set<String>();
        new LazySObjectIterator(accounts)
                .get(Account.Name)
                .forEach(new AddTo(accountNames));

        for(Account thisAccount : accounts) {
            System.assert(accountNames.contains(thisAccount.Name));
        }
        System.assertEquals(accounts.size(), accountNames.size());
    }

    @IsTest
    static void setId() {
        Set<Id> accountIds = new Set<Id>();
        new LazySObjectIterator(accounts)
                .get(Account.Id)
                .forEach(new AddTo(accountIds));

        for(Account thisAccount : accounts) {
            System.assert(accountIds.contains(thisAccount.Id));
        }
        System.assertEquals(accounts.size(), accountIds.size());
    }

    @IsTest
    static void listObject() {
        List<Object> accountNames = new List<Object>();
        new LazySObjectIterator(accounts)
                .get(Account.Name)
                .forEach(new AddTo(accountNames));

        for(Account thisAccount : accounts) {
            System.assert(accountNames.contains(thisAccount.Name));
        }
        System.assertEquals(accounts.size(), accountNames.size());
    }

    @IsTest
    static void sObjectIndex() {
        SObjectIndex nameToAccount = new SObjectIndex(Account.Name);
        new LazySObjectIterator(accounts)
                .forEach(new AddTo(nameToAccount));

        for(Account thisAccount : accounts) {
            System.assert(nameToAccount.contains(thisAccount.Name));
        }
    }
}
