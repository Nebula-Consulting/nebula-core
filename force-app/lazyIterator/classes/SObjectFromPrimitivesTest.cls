/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-12
 */

@IsTest
private class SObjectFromPrimitivesTest {

    @IsTest
    static void testBehavior() {
        List<Object> data = new List<Object> {1, 2, 3};

        List<Account> results = new LazyIterator(data)
                .mapValues(new SObjectFromPrimitives(new Account(Name = 'ACME', Industry='Everything'), Account.NumberOfEmployees))
                .toList(new List<Account>());

        for (Integer i = 0; i < data.size(); i++) {
            System.assertEquals('ACME', results[i].Name);
            System.assertEquals('Everything', results[i].Industry);
            System.assertEquals(data[i], results[i].NumberOfEmployees);
        }
    }
}