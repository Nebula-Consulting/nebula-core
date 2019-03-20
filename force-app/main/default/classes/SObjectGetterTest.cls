/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */

@IsTest
private class SObjectGetterTest {

    static TestRecordSource testRecordSource = new TestRecordSource();
    static TestRecordSource testRecordSource2 = new TestRecordSource();

    static {
        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = 'Test Account'), -1000);
        testRecordSource2.addTemporaryMetadataFromInstance(new Account(Name = 'Test Account'), -1000);
    }

    @IsTest
    public static void basic() {
        Account togAccount = (Account) testRecordSource.getRecord(Account.SObjectType).withInsert();
        Account childAccount = (Account) testRecordSource2.getRecord(Account.SObjectType).withoutInsert();
        childAccount.ParentId = togAccount.Id;
        insert childAccount;

        Account queriedAccount = [SELECT Id, Name, Parent.Name, Industry FROM Account WHERE Id = :togAccount.Id];

        System.assertEquals(queriedAccount.Parent.Name, String.valueOf(SObjectGetter.get(queriedAccount, 'Parent.Name')));
        System.assertEquals(queriedAccount.Name, SObjectGetter.get(queriedAccount, 'Name'));
        System.assertEquals(null, SObjectGetter.get(queriedAccount, 'Industry'));
    }

    @IsTest
    public static void relationIsNullPartWay() {
        Account togAccount = (Account) testRecordSource.getRecord(Account.SObjectType).withInsert();

        Account queriedAccount = [SELECT Id, Name, Parent.Name FROM Account WHERE Id = :togAccount.Id];

        System.assertEquals(null, String.valueOf(SObjectGetter.get(queriedAccount, 'Parent.Name')));
    }
}