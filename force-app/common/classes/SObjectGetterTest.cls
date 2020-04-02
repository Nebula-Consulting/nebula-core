/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */

@IsTest
private class SObjectGetterTest {

    static Account parentAccount = new Account(Name = 'Parent');
    static Account childAccount = new Account(Name = 'Child', Parent = parentAccount);

    @IsTest
    public static void basic() {
        System.assertEquals(childAccount.Parent.Name, String.valueOf(SObjectGetter.get(childAccount, 'Parent.Name')));
        System.assertEquals(childAccount.Name, SObjectGetter.get(childAccount, 'Name'));
        System.assertEquals(null, SObjectGetter.get(childAccount, 'Industry'));
    }

    @IsTest
    public static void relationIsNullPartWay() {
        System.assertEquals(null, String.valueOf(SObjectGetter.get(parentAccount, 'Parent.Name')));
    }
}