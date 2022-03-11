/**
 * @author paulk@nebulaconsulting.co.uk
 * @date 11/03/2022
 */

@IsTest
private class TestIdGeneratorTest {

    @IsTest static void singleId() {

        TestIdGenerator testIdGenerator = new TestIdGenerator(Contact.SObjectType);
        System.assert(testIdGenerator.next() != null);
        System.assertEquals(true, testIdGenerator.hasNext());

    }

    @IsTest static void largeNumberOfIds() {

        TestIdGenerator testIdGenerator = new TestIdGenerator(Contact.SObjectType);
        for (Integer i = 0; i < 10001; i++) {
            testIdGenerator.next();
        }
        System.assert(testIdGenerator.next() != null);

    }
}