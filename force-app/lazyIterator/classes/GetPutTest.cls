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

        Test.startTest();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(testLead)))
                .forEach(new PutTo(result));
        Test.stopTest();

        System.assertEquals(testLead.FirstName, result.FirstName);
        System.assertEquals(testLead.LastName, result.LastName);
    }

    @IsTest
    static void mapToSObject() {
        Map<String, Object> inputMap = new Map<String, Object>{ 'FirstName' => 'Foo', 'LastName' => 'Bar'};
        List<String> fields = new List<String>{'FirstName', 'LastName'};
        Contact result = new Contact();

        Test.startTest();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(inputMap)))
                .forEach(new PutTo(result));
        Test.stopTest();

        System.assertEquals(inputMap.get('FirstName'), result.FirstName);
        System.assertEquals(inputMap.get('LastName'), result.LastName);
    }

    @IsTest
    static void mapToDeepSObject() {
        Map<String, Object> inputMap = new Map<String, Object>{ 'FirstName' => 'Foo', 'LastName' => 'Bar', 'Company' => 'ACME'};
        List<String> fields = new List<String>{'FirstName', 'LastName', 'Company'};
        Map<String, String> fieldMap = new Map<String, String>{
                'FirstName' => 'FirstName',
                'LastName' => 'LastName',
                'Company' => 'Account.Name'
        };

        Contact result = new Contact();

        Test.startTest();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(inputMap)))
                .mapValues(new TwoTupleMapValues(new GetFrom(fieldMap), new IdentityFunction()))
                .forEach(new PutTo(result));
        Test.stopTest();

        System.assertEquals(inputMap.get('FirstName'), result.FirstName);
        System.assertEquals(inputMap.get('LastName'), result.LastName);
        System.assertEquals(inputMap.get('Company'), result.Account.Name);
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

        Test.startTest();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(inputMap)))
                .mapValues(new TwoTupleMapValues(new GetFrom(fieldMap), new IdentityFunction()))
                .forEach(new PutTo(result));
        Test.stopTest();

        System.assertEquals(inputMap.get('Names').get('FirstName'), result.FirstName);
        System.assertEquals(inputMap.get('Names').get('LastName'), result.LastName);
    }

    @IsTest
    static void sObjectToMap() {
        Lead testLead = new Lead(FirstName = 'Foo', LastName = 'Bar');
        List<String> fields = new List<String>{'FirstName', 'LastName'};
        Map<String, Object> result = new Map<String, Object>();

        Test.startTest();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(testLead)))
                .forEach(new PutTo(result));
        Test.stopTest();

        System.assertEquals(testLead.FirstName, result.get('FirstName'));
        System.assertEquals(testLead.LastName, result.get('LastName'));
    }

    @IsTest
    static void sObjectToDeepMap() {
        Lead testLead = new Lead(FirstName = 'Foo', LastName = 'Bar');
        List<String> fields = new List<String>{'FirstName', 'LastName'};
        Map<String, Object> result = new Map<String, Object>();
        Map<String, String> fieldMap = new Map<String, String>{
                'FirstName' => 'Names.FirstName',
                'LastName' => 'Names.LastName'
        };

        Test.startTest();
        new LazyIterator(fields)
                .mapValues(new ToTwoTuple(new IdentityFunction(), new GetFrom(testLead)))
                .mapValues(new TwoTupleMapValues(new GetFrom(fieldMap), new IdentityFunction()))
                .forEach(new PutTo(result));
        Test.stopTest();

        System.assertEquals(testLead.FirstName, ((Map<String, Object>)result.get('Names')).get('FirstName'));
        System.assertEquals(testLead.LastName, ((Map<String, Object>)result.get('Names')).get('LastName'));
    }
}