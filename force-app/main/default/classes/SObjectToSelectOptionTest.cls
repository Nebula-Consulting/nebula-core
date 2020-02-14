/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/02/2020
 */

@IsTest
private class SObjectToSelectOptionTest {

    static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);
    static Account testAccount = new Account(Id = accountIdGenerator.next(), Name = 'Foo', Description = 'Bar');

    @IsTest
    static void defaultConstructor() {
        Test.startTest();
        SelectOption testSelectOption = (SelectOption)new SObjectToSelectOption().call(testAccount);
        Test.stopTest();

        System.assertEquals(testAccount.Id, testSelectOption.getValue());
        System.assertEquals(testAccount.Name, testSelectOption.getLabel());
    }

    @IsTest
    static void fieldConstructor() {
        Test.startTest();
        SelectOption testSelectOption = (SelectOption)new SObjectToSelectOption(Account.Name, Account.Description).call(testAccount);
        Test.stopTest();

        System.assertEquals(testAccount.Name, testSelectOption.getValue());
        System.assertEquals(testAccount.Description, testSelectOption.getLabel());
    }

    @IsTest
    static void functionConstructor() {
        Test.startTest();
        SelectOption testSelectOption = (SelectOption)new SObjectToSelectOption(
                new Composition(new FieldFromSObject(Account.Name), new StringLowerCaseFunction()),
                new FieldFromSObject(Account.Id))
                        .call(testAccount);
        Test.stopTest();

        System.assertEquals(testAccount.Name.toLowerCase(), testSelectOption.getValue());
        System.assertEquals(testAccount.Id, testSelectOption.getLabel());
    }
}