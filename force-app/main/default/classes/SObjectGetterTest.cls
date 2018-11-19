/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */

@IsTest
private class SObjectGetterTest {

    static TestObjectGenerator tog = new TestObjectGenerator();

    @IsTest
    public static void basic() {
        Account togAccount = tog.getAccount();
        Contact togContact = tog.getContact();

        SObject queriedContact = [SELECT Id, LastName, Account.Name, FirstName FROM Contact WHERE Id = :togContact.Id];

        System.assertEquals(togAccount.Name, String.valueOf(SObjectGetter.get(queriedContact, 'Account.Name')));
        System.assertEquals(togContact.LastName, SObjectGetter.get(queriedContact, 'LastName'));
        System.assertEquals(null, SObjectGetter.get(queriedContact, 'FirstName'));
        System.assertEquals(null, String.valueOf(SObjectGetter.get(queriedContact, 'FirstName')));
    }

    @IsTest
    public static void relationIsNullPartWay() {
        Contact togContact = tog.getContact();
        togContact.AccountId = null;
        update togContact;

        SObject queriedContact = [SELECT Id, LastName, Account.Name, FirstName FROM Contact WHERE Id = :togContact.Id];

        System.assertEquals(null, String.valueOf(SObjectGetter.get(queriedContact, 'Account.Name')));
    }
}