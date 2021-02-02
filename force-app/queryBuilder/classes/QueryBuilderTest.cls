/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 */

@IsTest
private class QueryBuilderTest {

    private static TestRecordSource testRecordSource = new TestRecordSource();
    static {
        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = 'Test Account'), -1000);
    }
    private static Account testAccount = (Account) testRecordSource.getRecord(Account.SObjectType).withInsert();

    @IsTest
    public static void addFieldsSetString() {
        Test.startTest();
        String query = new QueryBuilder(Account.SObjectType)
                .addFields(new Set<String> {'Name'})
                .setWhereClause('Id != null')
                .setOrderByClause('CreatedDate')
                .setPaginationClause('LIMIT 10')
                .getQuery();

        List<Account> accounts = Database.query(query);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals(testAccount.Name, accounts[0].Name);
    }

    @IsTest
    public static void addFieldsListString() {
        Test.startTest();
        String query = new QueryBuilder(Account.SObjectType)
                .addFields(new List<String> {'Name'})
                .setWhereClause('Id != null')
                .setOrderByClause('CreatedDate')
                .setPaginationClause('LIMIT 10')
                .getQuery();

        List<Account> accounts = Database.query(query);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals(testAccount.Name, accounts[0].Name);
    }

    @IsTest
    public static void addFieldsSetField() {
        Test.startTest();
        String query = new QueryBuilder(Account.SObjectType)
                .addFields(new Set<SObjectField> {Account.Name})
                .setWhereClause('Id != null')
                .setOrderByClause('CreatedDate')
                .setPaginationClause('LIMIT 10')
                .getQuery();

        List<Account> accounts = Database.query(query);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals(testAccount.Name, accounts[0].Name);
    }

    @IsTest
    public static void addFieldsListField() {
        Test.startTest();
        String query = new QueryBuilder(Account.SObjectType)
                .addFields(new List<SObjectField> {Account.Name})
                .setWhereClause('Id != null')
                .setOrderByClause('CreatedDate')
                .setPaginationClause('LIMIT 10')
                .getQuery();

        List<Account> accounts = Database.query(query);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals(testAccount.Name, accounts[0].Name);
    }

    @IsTest
    public static void allFields() {
        Test.startTest();
        String query = new QueryBuilder('Account')
                .addAllFields()
                .getQuery();

        List<Account> accounts = Database.query(query);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals(testAccount.Name, accounts[0].Name);
    }

    @IsTest
    public static void addFieldString() {
        Test.startTest();
        String query = new QueryBuilder(Account.SObjectType)
                .addField('Name')
                .getQuery();

        List<Account> accounts = Database.query(query);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals(testAccount.Name, accounts[0].Name);
    }

    @IsTest
    public static void withSecurityEnforced() {
        Test.startTest();
        String query = new QueryBuilder(Account.SObjectType)
                .addField(Account.Name)
                .setPaginationClause('LIMIT 1')
                .withSecurityEnforced()
                .getQuery();

        List<Account> accounts = Database.query(query);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals(testAccount.Name, accounts[0].Name);
        System.assert(query.contains('WITH SECURITY_ENFORCED'), 'Should contain WITH SECURITY_ENFORCED, is: ' + query);
    }
}