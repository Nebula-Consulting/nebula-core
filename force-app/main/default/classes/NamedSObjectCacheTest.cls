/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 */

@IsTest
private class NamedSObjectCacheTest {

    @IsTest
    static void testBehavior() {
        NamedSObjectCache.getRecordType(Contact.SObjectType, 'Supplier');

        // Can't know if this actually exists, so nothing to assert
    }
}