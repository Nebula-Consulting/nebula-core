/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 18/10/2019
 */

@IsTest
private class GetTest {
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
        Get sObjectIndexGet = new Get(theIndex);

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].Id, ((Account)sObjectIndexGet.call(accounts[i].Name)).Id);
        }
    }

    @IsTest
    static void mapGet() {
        Map<Id, Account> theMap = new Map<Id, Account>(accounts);
        Get sObjectIndexGet = new Get(theMap);

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(accounts[i].Name, ((Account)sObjectIndexGet.call(accounts[i].Id)).Name);
        }
    }

    @IsTest
    static void sObjectGet() {
        Get sObjectGet = new Get(accounts[0]);

        System.assertEquals(accounts[0].Name, sObjectGet.call('Name'));
        System.assertEquals(accounts[0].Id, sObjectGet.call('Id'));
    }
}