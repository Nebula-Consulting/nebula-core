/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 18/10/2019
 */

@IsTest
private class GetFromTest {
    private static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);

    private static List<Account> accounts = new List<Account>{
            new Account(Name = 'Company 1', Id = accountIdGenerator.next()),
            new Account(Name = 'Company 2', Id = accountIdGenerator.next()),
            new Account(Name = 'Company 3', Id = accountIdGenerator.next()),
            new Account(Name = 'Company 4', Id = accountIdGenerator.next()),
            new Account(Name = 'Company 5', Id = accountIdGenerator.next())
    };

    @IsTest
    static void sObjectIndex() {
        SObjectIndex theIndex = new SObjectIndex(Account.Name).putAll(accounts);
        GetFrom sObjectIndexGet = new GetFrom(theIndex);

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].Id, ((Account)sObjectIndexGet.call(accounts[i].Name)).Id);
        }

        System.assertEquals(NoResult.NO_RESULT, sObjectIndexGet.call(accountIdGenerator.next()));
    }

    @IsTest
    static void mapGet() {
        Map<Id, Account> theMap = new Map<Id, Account>(accounts);
        GetFrom mapGet = new GetFrom(theMap);

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].Name, ((Account) mapGet.call(accounts[i].Id)).Name);
        }
        System.assertEquals(NoResult.NO_RESULT, mapGet.call(accountIdGenerator.next()));
    }

    @IsTest
    static void sObjectGet() {
        GetFrom sObjectGet = new GetFrom(accounts[0]);

        System.assertEquals(accounts[0].Name, sObjectGet.call('Name'));
        System.assertEquals(accounts[0].Id, sObjectGet.call('Id'));
    }

    @IsTest
    static void jsonObjectGet() {
        GetFrom jsonGet = new GetFrom(new Map<String, Object> { 'a' => 'b', 'c' => new Map<String, Object> { 'd' => 'e' }})
            .setDefaultIfMissing('foo');

        System.assertEquals('b', jsonGet.call('a'));
        System.assertEquals('e', jsonGet.call('c.d'));
        System.assertEquals('foo', jsonGet.call('noSuchKey'));
    }

    @IsTest
    static void jsonObjectGetAsObject() {
        GetFrom jsonGet = new GetFrom((Object)new Map<String, Object> { 'a' => 'b', 'c' => new Map<String, Object> { 'd' => 'e' }});

        System.assertEquals('b', jsonGet.call('a'));
        System.assertEquals('e', jsonGet.call('c.d'));
    }

    @IsTest
    static void noMatchAsObject() {

        try {
            new GetFrom(1);
        } catch (IllegalArgumentException e) {
            String message = e.getMessage();
            System.assert(message.contains('GetFrom constructed with invalid type'), message);
            return;
        }

        System.assert(false, 'Should have thrown exception');
    }
}