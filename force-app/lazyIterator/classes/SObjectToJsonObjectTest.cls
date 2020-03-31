/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-06
 */

@IsTest
private class SObjectToJsonObjectTest {

    private static String firstName = 'Peter';
    private static String lastName = 'Griffin';
    private static String accountName = 'Family Guy';

    @IsTest public static void noDepth() {
        SObjectToJsonObject js = new SObjectToJsonObject(new Map<String, String> {'FirstName' => 'first_name', 'LastName' => 'last_name'});

        Map<String, Object> result = js.toJsonObject(new Contact(FirstName = firstName, LastName = lastName));

        System.assertEquals(firstName, result.get('first_name'));
        System.assertEquals(lastName, result.get('last_name'));
    }

    @IsTest public static void noSkipNulls() {
        SObjectToJsonObject js = new SObjectToJsonObject(new Map<String, String> {'FirstName' => 'first_name', 'LastName' => 'last_name'});

        Map<String, Object> result = js.toJsonObject(new Contact(FirstName = firstName));

        System.assertEquals(firstName, result.get('first_name'));
        System.assert(result.containsKey('last_name'));
        System.assertEquals(null, result.get('last_name'));
    }

    @IsTest public static void skipNulls() {
        SObjectToJsonObject js = new SObjectToJsonObject(new Map<String, String> {'FirstName' => 'first_name', 'LastName' => 'last_name'})
                .setSkipNulls(true);

        Map<String, Object> result = js.toJsonObject(new Contact(FirstName = firstName));

        System.assertEquals(firstName, result.get('first_name'));
        System.assert(!result.containsKey('last_name'));
    }

    @IsTest public static void boxed() {
        SObjectToJsonObject js = new SObjectToJsonObject(new Map<String, String> {'FirstName' => 'names.first', 'LastName' => 'names.last'});

        Map<String, Object> result = js.toJsonObject(new Contact(FirstName = firstName, LastName = lastName));

        System.assertEquals(firstName, ((Map<String, Object>)result.get('names')).get('first'));
        System.assertEquals(lastName, ((Map<String, Object>)result.get('names')).get('last'));

        System.debug(JSON.serialize(result));
    }

    @IsTest public static void deeplyBoxed() {
        SObjectToJsonObject js = new SObjectToJsonObject(new Map<String, String> {'FirstName' => 'meta.names.first', 'LastName' => 'meta.names.last'});

        Map<String, Object> result = js.toJsonObject(new Contact(FirstName = firstName, LastName = lastName));

        Map<String, Object> meta = (Map<String, Object>)result.get('meta');
        System.assertEquals(firstName, ((Map<String, Object>)meta.get('names')).get('first'));
        System.assertEquals(lastName, ((Map<String, Object>)meta.get('names')).get('last'));

        System.debug(JSON.serialize(result));
    }

    @IsTest public static void mixedBoxed() {
        SObjectToJsonObject js = new SObjectToJsonObject(new Map<String, String> {'FirstName' => 'meta.names.first', 'LastName' => 'meta.last'});

        Map<String, Object> result = js.toJsonObject(new Contact(FirstName = firstName, LastName = lastName));

        Map<String, Object> meta = (Map<String, Object>)result.get('meta');
        System.assertEquals(firstName, ((Map<String, Object>)meta.get('names')).get('first'));
        System.assertEquals(lastName, meta.get('last'));

        System.debug(JSON.serialize(result));
    }

    @IsTest public static void customFieldFunction() {
        SObjectToJsonObject js = new SObjectToJsonObject(new Map<String, String> {'FirstName' => 'first_name', 'LastName' => 'last_name'})
                .setFieldNameToFunction(new Map<String, Function> {'FirstName' => new AtSerializer()});

        Map<String, Object> result = js.toJsonObject(new Contact(FirstName = firstName, LastName = lastName));

        System.assertEquals('@Peter', result.get('first_name'));
        System.assertEquals(lastName, result.get('last_name'));
    }

    public class AtSerializer implements Function {
        public Object call(Object o) {
            return '@' + o;
        }
    }
}