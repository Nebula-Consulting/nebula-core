/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-14
 */

@IsTest
private class BooleanFunctionsTest {

    @IsTest
    static void isNull() {
        BooleanFunction isNull = new BooleanFunctions.IsNull();

        System.assert(isNull.isTrueFor(null));
        System.assert(!isNull.isTrueFor(1));
    }

    @IsTest
    static void isNotNull() {
        BooleanFunction isNotNull = new BooleanFunctions.IsNotNull();

        System.assert(isNotNull.isTrueFor(1));
        System.assert(!isNotNull.isTrueFor(null));
    }

    @IsTest
    static void isNotNotNull() {
        BooleanFunction isNotNotNull = new BooleanFunctions.IsNot(new BooleanFunctions.IsNotNull());

        System.assert(isNotNotNull.isTrueFor(null));
        System.assert(!isNotNotNull.isTrueFor(1));
    }

    @IsTest
    static void isAll() {
        BooleanFunction isAllAgree = new BooleanFunctions.IsAll(new List<BooleanFunction>{
                new BooleanFunctions.IsNotNull(),
                new BooleanFunctions.IsNotNull()
        });

        System.assert(isAllAgree.isTrueFor(1));
        System.assert(!isAllAgree.isTrueFor(null));

        BooleanFunction isAllDisagree = new BooleanFunctions.IsAll(new List<BooleanFunction>{
                new BooleanFunctions.IsNotNull(),
                new BooleanFunctions.IsNull()
        });

        System.assert(!isAllDisagree.isTrueFor(1));
    }

    @IsTest
    static void isAny() {
        BooleanFunction isAnyAgree = new BooleanFunctions.IsAny(new List<BooleanFunction>{
                new BooleanFunctions.IsNotNull(),
                new BooleanFunctions.IsNotNull()
        });

        System.assert(isAnyAgree.isTrueFor(1));
        System.assert(!isAnyAgree.isTrueFor(null));

        BooleanFunction isAnyDisagree = new BooleanFunctions.IsAny(new List<BooleanFunction>{
                new BooleanFunctions.IsNotNull(),
                new BooleanFunctions.IsNull()
        });

        System.assert(isAnyDisagree.isTrueFor(1));
        System.assert(isAnyDisagree.isTrueFor(null));
    }

    @IsTest
    static void isInSObjectIndex() {
        String accountName = 'foo';
        BooleanFunction isInIndex = new BooleanFunctions.IsInSObjectIndex(
                new SObjectIndex('Name')
                        .putAll(new List<Account>{new Account(Name = accountName)})
        );

        System.assert(isInIndex.isTrueFor(new Account(Name = accountName)));
        System.assert(!isInIndex.isTrueFor(new Account(Name = accountName + '!')));
    }

}