/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 */

@IsTest
private class NamedSObjectCacheTest {

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // Can't know if this actually exists, so nothing to assert
    @IsTest
    static void testBehavior() {
        NamedSObjectCache.getRecordType(Contact.SObjectType, 'Supplier');
    }
}