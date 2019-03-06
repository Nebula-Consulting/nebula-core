/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */

@IsTest
private class SObjectGetterTest {

    static TestRecordSource tog = new TestRecordSource();

    @IsTest
    public static void basic() {
        Account togAccount = (Account)tog.getObjectWithInsert(Account.SObjectType);
        Contact togContact = (Contact)tog.getObjectWithInsert(Contact.SObjectType);

        SObject queriedContact = [SELECT Id, LastName, Account.Name, FirstName FROM Contact WHERE Id = :togContact.Id];

        System.assertEquals(togAccount.Name, String.valueOf(SObjectGetter.get(queriedContact, 'Account.Name')));
        System.assertEquals(togContact.LastName, SObjectGetter.get(queriedContact, 'LastName'));
        System.assertEquals(null, SObjectGetter.get(queriedContact, 'FirstName'));
        System.assertEquals(null, String.valueOf(SObjectGetter.get(queriedContact, 'FirstName')));
    }

    @IsTest
    public static void relationIsNullPartWay() {
        Contact togContact = (Contact)tog.getObjectWithInsert(Contact.SObjectType, 'No Account');

        SObject queriedContact = [SELECT Id, LastName, Account.Name, FirstName FROM Contact WHERE Id = :togContact.Id];

        System.assertEquals(null, String.valueOf(SObjectGetter.get(queriedContact, 'Account.Name')));
    }
}