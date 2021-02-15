/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 15/02/2021
 */

@IsTest
private class SObjectFieldComparatorTest {

    @IsTest
    static void decimalSort() {
        List<Account> accounts = new List<Account> {
                new Account(NumberOfEmployees = 3),
                new Account(NumberOfEmployees = 1),
                new Account(NumberOfEmployees = 2),
                new Account(NumberOfEmployees = 0)
        };

        Lists.sort(accounts, new SObjectFieldComparator(Account.NumberOfEmployees));

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(i, accounts[i].NumberOfEmployees);
        }
    }

    @IsTest
    static void decimalDirect() {
        SObjectFieldComparator comparator = new SObjectFieldComparator(Account.NumberOfEmployees);

        System.assert(comparator.compare(new Account(NumberOfEmployees = 0), new Account(NumberOfEmployees = 1)) < 0);
        System.assert(comparator.compare(new Account(NumberOfEmployees = 1), new Account(NumberOfEmployees = 0)) > 0);
        System.assert(comparator.compare(new Account(NumberOfEmployees = 0), new Account(NumberOfEmployees = 0)) == 0);
    }

    @IsTest
    static void stringSort() {
        List<Account> accounts = new List<Account> {
                new Account(ShippingStreet = '3'),
                new Account(ShippingStreet = '1'),
                new Account(ShippingStreet = '2'),
                new Account(ShippingStreet = '0')
        };

        Lists.sort(accounts, new SObjectFieldComparator(Account.ShippingStreet));

        for(Integer i=0; i < accounts.size(); i++) {
            System.assertEquals(String.valueOf(i), accounts[i].ShippingStreet);
        }
    }

    @IsTest
    static void stringDirect() {
        SObjectFieldComparator comparator = new SObjectFieldComparator(Account.ShippingStreet);

        System.assert(comparator.compare(new Account(ShippingStreet = '0'), new Account(ShippingStreet = '1')) < 0);
        System.assert(comparator.compare(new Account(ShippingStreet = '1'), new Account(ShippingStreet = '0')) > 0);
        System.assert(comparator.compare(new Account(ShippingStreet = '0'), new Account(ShippingStreet = '0')) == 0);
    }
}