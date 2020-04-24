/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-14
 */

@IsTest
private class BooleanFunctionsTest {

    @IsTest
    static void isNull() {
        BooleanFunction isNull = new IsNull();

        System.assert(isNull.isTrueFor(null));
        System.assert(!isNull.isTrueFor(1));
    }

    @IsTest
    static void isNotNull() {
        BooleanFunction isNotNull = new IsNotNull();

        System.assert(isNotNull.isTrueFor(1));
        System.assert(!isNotNull.isTrueFor(null));
    }

    @IsTest
    static void isNotNotNull() {
        BooleanFunction isNotNotNull = new IsNot(new IsNotNull());

        System.assert(isNotNotNull.isTrueFor(null));
        System.assert(!isNotNotNull.isTrueFor(1));
    }

    @IsTest
    static void isAll() {
        BooleanFunction isAllAgree = new IsAll(new List<BooleanFunction>{
                new IsNotNull(),
                new IsNotNull()
        });

        System.assert(isAllAgree.isTrueFor(1));
        System.assert(!isAllAgree.isTrueFor(null));

        BooleanFunction isAllDisagree = new IsAll(new List<BooleanFunction>{
                new IsNotNull(),
                new IsNull()
        });

        System.assert(!isAllDisagree.isTrueFor(1));
    }

    @IsTest
    static void isAny() {
        BooleanFunction isAnyAgree = new IsAny(new List<BooleanFunction>{
                new IsNotNull(),
                new IsNotNull()
        });

        System.assert(isAnyAgree.isTrueFor(1));
        System.assert(!isAnyAgree.isTrueFor(null));

        BooleanFunction isAnyDisagree = new IsAny(new List<BooleanFunction>{
                new IsNotNull(),
                new IsNull()
        });

        System.assert(isAnyDisagree.isTrueFor(1));
        System.assert(isAnyDisagree.isTrueFor(null));
    }

    @IsTest
    static void isInSObjectIndex() {
        String accountName = 'foo';
        BooleanFunction isInIndex = new IsInSObjectIndex(
                new SObjectIndex('Name')
                        .putAll(new List<Account>{new Account(Name = accountName)})
        );

        System.assert(isInIndex.isTrueFor(new Account(Name = accountName)));
        System.assert(!isInIndex.isTrueFor(new Account(Name = accountName + '!')));
    }

    @IsTest
    static void isTriggerChanged() {
        TriggerContextBooleanFunction isTriggerChanged = new IsFieldChangedInTrigger(Account.Name);

        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        System.assert(isTriggerChanged.isTrueFor(null, new Account(Name = 'b')));
        System.assert(!isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'a')));
    }

    @IsTest
    static void isTriggerChanged2() {
        TriggerContextBooleanFunction isTriggerChanged = new IsFieldChangedInTrigger(Account.Name, Account.Description);

        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
    }

    @IsTest
    static void isTriggerChanged3() {
        TriggerContextBooleanFunction isTriggerChanged = new IsFieldChangedInTrigger(Account.Name, Account.Description, Account.Industry);

        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c', Industry = 'Tech'), new Account(Name = 'a', Description = 'c', Industry = 'Agriculture')));
    }

    @IsTest
    static void isTriggerChangedList() {
        TriggerContextBooleanFunction isTriggerChanged = new IsFieldChangedInTrigger(new List<SObjectField>{Account.Name, Account.Description, Account.Industry});

        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
        System.assert(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c', Industry = 'Tech'), new Account(Name = 'a', Description = 'c', Industry = 'Agriculture')));
    }

    @IsTest
    static void isSObjectFieldEqual() {
        BooleanFunction isSObjectFieldEqual = new IsSObjectFieldEqual(Account.Name, 'a');

        System.assert(isSObjectFieldEqual.isTrueFor(new Account(Name = 'a')));
        System.assert(!isSObjectFieldEqual.isTrueFor(new Account(Name = 'b')));
    }


    @IsTest
    static void isUniqueOnSObjectField() {
        BooleanFunction isUniqueOnSObjectField = new IsUniqueOn(new FieldFromSObject(Account.Name));

        System.assert(isUniqueOnSObjectField.isTrueFor(new Account(Name = 'a')));
        System.assert(!isUniqueOnSObjectField.isTrueFor(new Account(Name = 'a')));
        System.assert(isUniqueOnSObjectField.isTrueFor(new Account(Name = 'b')));
        System.assert(!isUniqueOnSObjectField.isTrueFor(new Account(Name = 'b')));
    }

}