/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/02/2020
 */

@IsTest
private class SObjectsFromIndexTest {

    private static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);

    private static List<Account> accounts = new List<Account>{
            new Account(Id = accountIdGenerator.next(), Industry = 'SASS', Name = 'Nebula Consulting'),
            new Account(Id = accountIdGenerator.next(), Industry = 'SASS', Name = 'Salesforce'),
            new Account(Id = accountIdGenerator.next(), Industry = 'Everything', Name = 'ACME')
    };

    private static SObjectIndex sObjectIndex = new SObjectIndex(Account.Industry).putAll(accounts);

    @IsTest
    static void fetchOnString() {
        List<Object> industries = new List<Object> {'Everything', 'SASS'};

        List<Account> result = new LazyIterator(industries)
                .expand(new SObjectsFromIndex(sObjectIndex))
                .toList(new List<Account>());

        System.assertEquals(accounts[2].Id, result[0].Id);
        System.assertEquals(accounts[0].Id, result[1].Id);
        System.assertEquals(accounts[1].Id, result[2].Id);
    }

    @IsTest
    static void fetchOnSObject() {
        List<Object> industries = new List<Object> {new Account(Industry = 'Everything'), new Account(Industry = 'SASS')};

        List<Account> result = new LazyIterator(industries)
                .expand(new SObjectsFromIndex(sObjectIndex))
                .toList(new List<Account>());

        System.assertEquals(accounts[2].Id, result[0].Id);
        System.assertEquals(accounts[0].Id, result[1].Id);
        System.assertEquals(accounts[1].Id, result[2].Id);
    }
}