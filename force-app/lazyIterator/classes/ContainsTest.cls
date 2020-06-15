/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 07/05/2020
 */

@IsTest
private class ContainsTest {

    @IsTest
    static void sObjectIndex() {
        Account anAccount = new Account(Name = 'foo');
        SObjectIndex anIndex = new SObjectIndex(Account.Name).put(anAccount);
        Contains contains = new Contains(anIndex);
        
        Test.startTest();
        System.assert(contains.isTrueFor(anAccount));
        System.assert(contains.isTrueFor(anAccount.Name));
        System.assert(contains.isTrueFor(new Map<String, Object> { 'Name' => anAccount.Name}));
        System.assert(!contains.isTrueFor(new Account(Name = 'bar')));
        System.assert(!contains.isTrueFor('bar'));
        System.assert(contains.isTrueFor(new Map<String, Object> { 'Name' => anAccount.Name}));
        Test.stopTest();
    }

    @IsTest
    static void setObject() {
        Set<Object> strings = new Set<Object> {'a', 'b'};
        Contains contains = new Contains(strings);

        Test.startTest();
        System.assert(contains.isTrueFor('a'));
        System.assert(contains.isTrueFor('b'));
        System.assert(!contains.isTrueFor('c'));
        Test.stopTest();
    }

    @IsTest
    static void setString() {
        Set<String> strings = new Set<String> {'a', 'b'};
        Contains contains = new Contains(strings);

        Test.startTest();
        System.assert(contains.isTrueFor('a'));
        System.assert(contains.isTrueFor('b'));
        System.assert(!contains.isTrueFor('c'));
        Test.stopTest();
    }

    @IsTest
    static void setId() {
        TestIdGenerator idGenerator = new TestIdGenerator(Account.SObjectType);

        Id id1 = idGenerator.next(), id2 = idGenerator.next();
        Set<Id> strings = new Set<Id> {id1, id2};
        Contains contains = new Contains(strings);

        Test.startTest();
        System.assert(contains.isTrueFor(id1));
        System.assert(contains.isTrueFor(id2));
        System.assert(!contains.isTrueFor(idGenerator.next()));
        Test.stopTest();
    }

    @IsTest
    static void listString() {
        List<String> strings = new List<String> {'a', 'b'};
        Contains contains = new Contains(strings);

        Test.startTest();
        System.assert(contains.isTrueFor('a'));
        System.assert(contains.isTrueFor('b'));
        System.assert(!contains.isTrueFor('c'));
        Test.stopTest();
    }
}