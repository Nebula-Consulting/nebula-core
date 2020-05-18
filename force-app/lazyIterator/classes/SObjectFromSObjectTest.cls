/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 15/05/2020
 */

@IsTest
private class SObjectFromSObjectTest {

    private static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);

    private static List<Account> accounts = new List<Account>{
            new Account(NumberOfEmployees = 1, Id = accountIdGenerator.next()),
            new Account(NumberOfEmployees = 2, Id = accountIdGenerator.next())
    };

    @IsTest
    static void testBehavior() {
        accounts[1].Parent = accounts[0];

        Test.startTest();
        Account result = (Account)new SObjectFromSObject(Account.ParentId).call(accounts[1]);
        Test.stopTest();

        System.assertEquals(accounts[0].Id, result.Id);
    }
}