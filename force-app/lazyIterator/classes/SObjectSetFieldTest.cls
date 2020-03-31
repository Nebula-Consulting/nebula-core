/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-16
 */

@IsTest
private class SObjectSetFieldTest {

    @IsTest
    static void testBehavior() {
        List<Account> results = new LazySObjectIterator(new List<Account>{new Account(), new Account()})
                .mapValues(new SObjectSetField(Account.Name, 'ACME'))
                .mapValues(new SObjectSetField(Account.Industry, 'Everything'))
                .toList(new List<Account>());

        System.assertEquals(2, results.size());
        for(Integer i=0; i < results.size(); i++) {
            System.assertEquals('ACME', results[i].Name);
            System.assertEquals('Everything', results[i].Industry);
        }
    }
}