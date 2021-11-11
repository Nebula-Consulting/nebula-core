/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/11/2021
 */

@IsTest
private class GetPutTest {

    @IsTest
    static void sObjectToSObject() {
        Lead testLead = new Lead(FirstName = 'Foo', LastName = 'Bar');
        List<String> fields = new List<String>{'FirstName', 'LastName'};
        Contact result = new Contact();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(testLead)))
                .forEach(new PutTo(result));

        System.assertEquals(testLead.FirstName, result.FirstName);
        System.assertEquals(testLead.LastName, result.LastName);
    }

    @IsTest
    static void mapToSObject() {
        Map<String, Object> inputMap = new Map<String, Object>{ 'FirstName' => 'Foo', 'LastName' => 'Bar'};
        List<String> fields = new List<String>{'FirstName', 'LastName'};
        Contact result = new Contact();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(inputMap)))
                .forEach(new PutTo(result));

        System.assertEquals(inputMap.get('FirstName'), result.FirstName);
        System.assertEquals(inputMap.get('LastName'), result.LastName);
    }

    @IsTest
    static void deepMapToSObject() {
        Map<String, Map<String, Object>> inputMap = new Map<String, Map<String, Object>>{ 'Names' => new Map<String, Object>{'FirstName' => 'Foo', 'LastName' => 'Bar'}};
        List<String> fields = new List<String>{'Names.FirstName', 'Names.LastName'};
        Map<String, String> fieldMap = new Map<String, String>{
                'Names.FirstName' => 'FirstName',
                'Names.LastName' => 'LastName'
        };

        Contact result = new Contact();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(inputMap)))
                .mapValues(new TwoTupleApply(new GetFrom(fieldMap), new IdentityFunction()))
                .forEach(new PutTo(result));

        System.assertEquals(inputMap.get('Names').get('FirstName'), result.FirstName);
        System.assertEquals(inputMap.get('Names').get('LastName'), result.LastName);
    }
}