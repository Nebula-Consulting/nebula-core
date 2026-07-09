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
                .observeValues(new AddTo(accountNames))
                .forEach();

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

    @IsTest
    static void mapObjectObject() {
        Map<Object, Object> accountNameToId = new Map<Object, Object>();
        new LazySObjectIterator(accounts)
                .mapValues(new ToTwoTuple(new FieldFromSObject(Account.Name), new FieldFromSObject(Account.Id)))
                .forEach(new AddTo(accountNameToId));

        for(Account thisAccount : accounts) {
            System.assert(accountNameToId.containsKey(thisAccount.Name));
            System.assertEquals(thisAccount.Id, accountNameToId.get(thisAccount.Name));
        }
        System.assertEquals(accounts.size(), accountNameToId.size());
    }

    @IsTest
    static void mapStringString() {
        Map<Object, Object> accountIdToName = new Map<Object, Object>();
        new LazySObjectIterator(accounts)
                .mapValues(new ToTwoTuple(new FieldFromSObject(Account.Id), new FieldFromSObject(Account.Name)))
                .forEach(new AddTo(accountIdToName));

        for(Account thisAccount : accounts) {
            System.assert(accountIdToName.containsKey(thisAccount.Id));
            System.assertEquals(thisAccount.Name, accountIdToName.get(thisAccount.Id));
        }
        System.assertEquals(accounts.size(), accountIdToName.size());
    }

    @IsTest
    static void mapIdSObject() {
        Map<Object, Object> idToAccount = new Map<Object, Object>();
        new LazySObjectIterator(accounts)
                .mapValues(new ToTwoTuple(new FieldFromSObject(Account.Id), new FieldFromSObject(Account.Name)))
                .forEach(new AddTo(idToAccount));

        for(Account thisAccount : accounts) {
            System.assert(idToAccount.containsKey(thisAccount.Id));
            System.assertEquals(thisAccount.Name, idToAccount.get(thisAccount.Id));
        }
        System.assertEquals(accounts.size(), idToAccount.size());
    }
}
