/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-14
 */

@IsTest
private class BooleanFunctionsTest {

    @IsTest
    static void isNull() {
        BooleanFunction isNull = new IsNull();

        Assert.isTrue(isNull.isTrueFor(null));
        Assert.isTrue(!isNull.isTrueFor(1));
    }

    @IsTest
    static void isNullField() {
        BooleanFunction isNull = new IsNull(Account.Name);

        Assert.isTrue(isNull.isTrueFor(new Account()));
        Assert.isTrue(!isNull.isTrueFor(new Account(Name = 'ACME')));
    }

    @IsTest
    static void isNotNull() {
        BooleanFunction isNotNull = new IsNotNull();

        Assert.isTrue(isNotNull.isTrueFor(1));
        Assert.isTrue(!isNotNull.isTrueFor(null));
    }

    @IsTest
    static void isNotNullField() {
        BooleanFunction isNotNull = new IsNotNull(Account.Name);

        Assert.isTrue(!isNotNull.isTrueFor(new Account()));
        Assert.isTrue(isNotNull.isTrueFor(new Account(Name = 'ACME')));
    }

    @IsTest
    static void isNotNotNull() {
        BooleanFunction isNotNotNull = new IsNot(new IsNotNull());

        Assert.isTrue(isNotNotNull.isTrueFor(null));
        Assert.isTrue(!isNotNotNull.isTrueFor(1));
    }

    @IsTest
    static void isAll() {
        BooleanFunction isAllAgree = new IsAll(new List<BooleanFunction>{
                new IsNotNull(),
                new IsNotNull()
        });

        Assert.isTrue(isAllAgree.isTrueFor(1));
        Assert.isTrue(!isAllAgree.isTrueFor(null));

        BooleanFunction isAllDisagree = new IsAll(new List<BooleanFunction>{
                new IsNotNull(),
                new IsNull()
        });

        Assert.isTrue(!isAllDisagree.isTrueFor(1));
    }

    @IsTest
    static void isAny() {
        BooleanFunction isAnyAgree = new IsAny(new List<BooleanFunction>{
                new IsNotNull(),
                new IsNotNull()
        });

        Assert.isTrue(isAnyAgree.isTrueFor(1));
        Assert.isTrue(!isAnyAgree.isTrueFor(null));

        BooleanFunction isAnyDisagree = new IsAny(new List<BooleanFunction>{
                new IsNotNull(),
                new IsNull()
        });

        Assert.isTrue(isAnyDisagree.isTrueFor(1));
        Assert.isTrue(isAnyDisagree.isTrueFor(null));
    }

    @IsTest
    static void isInSObjectIndex() {
        String accountName = 'foo';
        BooleanFunction isInIndex = new IsInSObjectIndex(
                new SObjectIndex('Name')
                        .putAll(new List<Account>{new Account(Name = accountName)})
        );

        Assert.isTrue(isInIndex.isTrueFor(new Account(Name = accountName)));
        Assert.isTrue(!isInIndex.isTrueFor(new Account(Name = accountName + '!')));
    }

    @IsTest
    static void isTriggerChanged() {
        TriggerContextBooleanFunction isTriggerChanged = new IsFieldChangedInTrigger(Account.Name);

        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        Assert.isTrue(isTriggerChanged.isTrueFor(null, new Account(Name = 'b')));
        Assert.isTrue(!isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'a')));
    }

    @IsTest
    static void isTriggerChangedString() {
        TriggerContextBooleanFunction isTriggerChanged = new IsFieldChangedInTrigger('Name');

        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        Assert.isTrue(isTriggerChanged.isTrueFor(null, new Account(Name = 'b')));
        Assert.isTrue(!isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'a')));
    }

    @IsTest
    static void isTriggerChanged2() {
        TriggerContextBooleanFunction isTriggerChanged = new IsAnyFieldChangedInTrigger(Account.Name, Account.Description);

        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
    }

    @IsTest
    static void isTriggerChanged3() {
        TriggerContextBooleanFunction isTriggerChanged = new IsAnyFieldChangedInTrigger(Account.Name, Account.Description, Account.Industry);

        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c', Industry = 'Tech'), new Account(Name = 'a', Description = 'c', Industry = 'Agriculture')));
    }

    @IsTest
    static void isTriggerChangedList() {
        TriggerContextBooleanFunction isTriggerChanged = new IsAnyFieldChangedInTrigger(new List<SObjectField>{Account.Name, Account.Description, Account.Industry});

        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c', Industry = 'Tech'), new Account(Name = 'a', Description = 'c', Industry = 'Agriculture')));
    }

    @IsTest
    static void isTriggerChanged2String() {
        TriggerContextBooleanFunction isTriggerChanged = new IsAnyFieldChangedInTrigger('Name', 'Description');

        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
    }

    @IsTest
    static void isTriggerChanged3String() {
        TriggerContextBooleanFunction isTriggerChanged = new IsAnyFieldChangedInTrigger('Name', 'Description', 'Industry');

        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c', Industry = 'Tech'), new Account(Name = 'a', Description = 'c', Industry = 'Agriculture')));
    }

    @IsTest
    static void isTriggerChangedListString() {
        TriggerContextBooleanFunction isTriggerChanged = new IsAnyFieldChangedInTrigger(new List<String>{'Name', 'Description', 'Industry'});

        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a'), new Account(Name = 'b')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c'), new Account(Name = 'a', Description = 'd')));
        Assert.isTrue(isTriggerChanged.isTrueFor(new Account(Name = 'a', Description = 'c', Industry = 'Tech'), new Account(Name = 'a', Description = 'c', Industry = 'Agriculture')));
    }

    @IsTest
    static void isSObjectFieldEqual() {
        BooleanFunction isSObjectFieldEqual = new IsSObjectFieldEqual(Account.Name, 'a');

        Assert.isTrue(isSObjectFieldEqual.isTrueFor(new Account(Name = 'a')));
        Assert.isTrue(!isSObjectFieldEqual.isTrueFor(new Account(Name = 'b')));
    }


    @IsTest
    static void isUniqueOnSObjectField() {
        BooleanFunction isUniqueOnSObjectField = new IsUniqueOn(Account.Name);

        Assert.isTrue(isUniqueOnSObjectField.isTrueFor(new Account(Name = 'a')));
        Assert.isTrue(!isUniqueOnSObjectField.isTrueFor(new Account(Name = 'a')));
        Assert.isTrue(isUniqueOnSObjectField.isTrueFor(new Account(Name = 'b')));
        Assert.isTrue(!isUniqueOnSObjectField.isTrueFor(new Account(Name = 'b')));
    }

    @IsTest
    static void isSuccess() {
        BooleanFunction isSuccess = new IsSuccess();

        Database.SaveResult successfulSave = (Database.SaveResult)JSON.deserialize('{"success" : true}', Database.SaveResult.class);
        Database.SaveResult unsuccessfulSave = (Database.SaveResult)JSON.deserialize('{"success" : false}', Database.SaveResult.class);
        Assert.isTrue(isSuccess.isTrueFor(new SaveResult(successfulSave, null)));
        Assert.isTrue(!isSuccess.isTrueFor(new SaveResult(unsuccessfulSave, null)));
    }

    @IsTest
    static void isNotSuccess() {
        BooleanFunction isNotSuccess = new IsNotSuccess();

        Database.SaveResult successfulSave = (Database.SaveResult)JSON.deserialize('{"success" : true}', Database.SaveResult.class);
        Database.SaveResult unsuccessfulSave = (Database.SaveResult)JSON.deserialize('{"success" : false}', Database.SaveResult.class);
        Assert.isTrue(!isNotSuccess.isTrueFor(new SaveResult(successfulSave, null)));
        Assert.isTrue(isNotSuccess.isTrueFor(new SaveResult(unsuccessfulSave, null)));
    }

}