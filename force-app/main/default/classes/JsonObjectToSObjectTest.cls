/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-06
 */

@IsTest
private class JsonObjectToSObjectTest {

    @IsTest
    public static void basic() {
        JsonObjectToSObject parser = new JsonObjectToSObject(Account.SObjectType);

        String accountName = 'ACME';
        Account acc = (Account)parser.toSObject(new Map<String, Object> {'Name' => accountName});

        System.assertEquals(accountName, acc.Name);
    }

    @IsTest
    public static void ignoreId() {
        JsonObjectToSObject parser = new JsonObjectToSObject(Account.SObjectType).setFieldsToIgnore(new Set<String>{'id'});

        String accountName = 'ACME';
        Account acc = (Account)parser.toSObject(new Map<String, Object> {'Name' => accountName, 'Id' => 'abc'});

        System.assertEquals(accountName, acc.Name);
        System.assertEquals(null, acc.Id);
    }

    @IsTest
    public static void mapIdElsewhere() {
        JsonObjectToSObject parser = new JsonObjectToSObject(Account.SObjectType)
                .setObjectFieldToSObjectField(new Map<String, String>{
                        'Id' => Account.Description.getDescribe().getName()
                });

        String accountName = 'ACME';
        String accountDescription = 'abc';
        Account acc = (Account)parser.toSObject(new Map<String, Object> {'Name' => accountName, 'Id' => accountDescription});

        System.assertEquals(accountName, acc.Name);
        System.assertEquals(accountDescription, acc.Description);
        System.assertEquals(null, acc.Id);
    }

    private class StringToDateConverter implements Function {
        public Object call(Object o) {
            return Datetime.valueOf('' + o);
        }
    }

    @IsTest
    public static void dateConversion() {
        JsonObjectToSObject parser = new JsonObjectToSObject(Account.SObjectType)
                .setFieldToFunction(new Map<String, Function>{'dateField' => new StringToDateConverter()});

        String accountName = 'ACME';
        Account acc = (Account)parser.toSObject(new Map<String, Object> {'Name' => accountName, 'dateField' => '2015-01-01 15:12:02'});

        System.assertEquals(accountName, acc.Name);
    }

    @IsTest
    public static void listVersion() {
        JsonObjectToSObject parser = new JsonObjectToSObject(Account.SObjectType);

        String accountName = 'ACME';
        List<Account> acc = (List<Account>)parser.toSObjects(new List<Object> {
                new Map<String, Object> {'Name' => accountName},
                new Map<String, Object> {'Name' => accountName + '2'}
        });

        System.assertEquals(accountName, acc[0].Name);
        System.assertEquals(accountName + '2', acc[1].Name);
    }

    @IsTest
    public static void mapped() {
        JsonObjectToSObject parser = new JsonObjectToSObject(Account.SObjectType)
                .setObjectFieldToSObjectField(new Map<String, String> {'AccountName' => 'Name'});

        String accountName = 'ACME';
        Account acc = (Account)parser.toSObject(new Map<String, Object> {'AccountName' => accountName});

        System.assertEquals(accountName, acc.Name);
    }

    @IsTest
    public static void unBoxed() {
        JsonObjectToSObject parser = new JsonObjectToSObject(Account.SObjectType)
                .setObjectFieldToSObjectField(new Map<String, String> {'Account.Name' => 'Name'});

        String accountName = 'ACME';
        Account acc = (Account)parser.toSObject(new Map<String, Object> {'Account' => new Map<String, Object> {'Name' => accountName}});

        System.assertEquals(accountName, acc.Name);
    }

    @IsTest
    public static void deeplyUnBoxed() {
        JsonObjectToSObject parser = new JsonObjectToSObject(Account.SObjectType)
                .setObjectFieldToSObjectField(new Map<String, String> {'meta.Account.Name' => 'Name'});

        String accountName = 'ACME';
        Account acc = (Account)parser.toSObject(
                new Map<String, Object> {'meta'=> new Map<String, Object> {'Account' => new Map<String, Object> {'Name' => accountName}}});

        System.assertEquals(accountName, acc.Name);
    }
}