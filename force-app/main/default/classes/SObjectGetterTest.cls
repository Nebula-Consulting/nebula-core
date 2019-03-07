/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */

@IsTest
private class SObjectGetterTest {

    static TestRecordSource testRecordSource = new TestRecordSource();
    static TestRecordSource testRecordSource2 = new TestRecordSource();

    @IsTest
    public static void basic() {
        Account togAccount = (Account) testRecordSource.getObject(Account.SObjectType).withInsert();
        Account childAccount = (Account) testRecordSource2.getObject(Account.SObjectType).withInsert();
        childAccount.ParentId = togAccount.Id;
        insert childAccount;

        Account queriedAccount = [SELECT Id, Name, Parent.Name, Industry FROM Account WHERE Id = :togAccount.Id];

        System.assertEquals(queriedAccount.Parent.Name, String.valueOf(SObjectGetter.get(queriedAccount, 'Parent.Name')));
        System.assertEquals(queriedAccount.Name, SObjectGetter.get(queriedAccount, 'Name'));
        System.assertEquals(null, SObjectGetter.get(queriedAccount, 'Industry'));
    }

    @IsTest
    public static void relationIsNullPartWay() {
        Account togAccount = (Account) testRecordSource.getObject(Account.SObjectType).withInsert();

        Account queriedAccount = [SELECT Id, Name, Parent.Name FROM Account WHERE Id = :togAccount.Id];

        System.assertEquals(null, String.valueOf(SObjectGetter.get(queriedAccount, 'Parent.Name')));
    }
}