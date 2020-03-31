/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/02/2020
 */

@IsTest
private class IsInSObjectIndexTest {

    static String accountName = 'ACME';
    static Account testAccount = new Account(Name = accountName);
    static SObjectIndex testIndex = new SObjectIndex(Account.Name).put(testAccount);

    @IsTest
    static void presentSObject() {
        System.assert(new IsInSObjectIndex(testIndex).isTrueFor(new Account(Name = accountName)));
    }

    @IsTest
    static void presentObject() {
        System.assert(new IsInSObjectIndex(testIndex).isTrueFor(accountName));
    }

    @IsTest
    static void notPresentSObject() {
        System.assert(!new IsInSObjectIndex(testIndex).isTrueFor(new Account(Name = 'not ' + accountName)));
    }

    @IsTest
    static void notPresentObject() {
        System.assert(!new IsInSObjectIndex(testIndex).isTrueFor('not ' + accountName));
    }

}