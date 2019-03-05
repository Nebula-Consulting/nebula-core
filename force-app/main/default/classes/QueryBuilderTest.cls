/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 */

@IsTest
private class QueryBuilderTest {

    private static TestRecords testRecordGenerator = new TestRecords();
    private static Account testAccount = (Account)testRecordGenerator.getObjectWithInsert(Account.SObjectType);

    @IsTest
    public static void queryFields() {
        Test.startTest();
        String query = new QueryBuilder('Account')
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
}