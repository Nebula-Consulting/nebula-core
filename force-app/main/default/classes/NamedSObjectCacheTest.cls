/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 */

@IsTest
private class NamedSObjectCacheTest {

    static TestRecordSource testRecordSource = new TestRecordSource();

    static {
        testRecordSource.addTemporaryMetadataFromInstance(new Account(Name = 'Test Account'), -1000);
    }

    static Account testAccount = (Account)testRecordSource.getRecord(Account.SObjectType).withInsert();

    // Can't know if a record type actually exists and can't insert one, so nothing to assert
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void recordType() {
        NamedSObjectCache.getRecordType(Contact.SObjectType, 'Supplier');
    }

    @IsTest
    public static void basic() {
        Account result = (Account)new NamedSObjectCache(Account.SObjectType, testAccount.Name).getObject();

        System.assertEquals(testAccount.Id, result.Id);

        Integer nQueries = Limits.getQueries();

        result = (Account)new NamedSObjectCache(Account.SObjectType, testAccount.Name).setNameField(Account.Name).getObject();

        System.assertEquals(nQueries, Limits.getQueries());
    }

    @IsTest
    public static void extraField() {
        Account result = (Account)new NamedSObjectCache(Account.SObjectType, testAccount.Name).setExtraFields(new Set<String>{'LastModifiedById'}).getObject();

        System.assertEquals(testAccount.Id, result.Id);
        System.assertEquals(UserInfo.getUserId(), result.LastModifiedById);
    }

    @IsTest
    public static void doesNotExist() {
        String accountNameToQuery = testAccount.Name + '1';
        Account result = (Account)new NamedSObjectCache(Account.SObjectType, accountNameToQuery).getObject();

        System.assertEquals(null, result);

        Integer nQueries = Limits.getQueries();

        result = (Account)new NamedSObjectCache(Account.SObjectType, accountNameToQuery).getObject();

        System.assertEquals(nQueries, Limits.getQueries());
    }
    @IsTest
    public static void andClause() {
        Account result = (Account)new NamedSObjectCache(Account.SObjectType, testAccount.Name).setAndClause('Id != NULL').getObject();

        System.assertEquals(testAccount.Id, result.Id);
    }
}