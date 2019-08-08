/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-06
 */

@IsTest
private class LazyIteratorExamples {

    static nebc.TestRecordSource testRecordSource = new nebc.TestRecordSource();
    static nebc.TestRecordSource testRecordSource2 = new nebc.TestRecordSource();
    static nebc.TestRecordSource testRecordSource3 = new nebc.TestRecordSource();

    @IsTest
    static void getFieldFromListOfSObjects() {
        List<Contact> allContacts = testRecordSource.getRecord(Contact.SObjectType).withInsert(2);
        allContacts.addAll((List<Contact>)testRecordSource2.getRecord(Contact.SObjectType).withInsert(2));
        List<Contact> contacts3 = testRecordSource3.getRecord(Contact.SObjectType).withoutInsert(2);
        for(Contact c : contacts3) {
            c.FirstName = 'Test First Name';
        }
        insert contacts3;

        allContacts.addAll(contacts3);

        Set<Id> accountIdsNoFirstName = new LazySObjectIterator(allContacts)
                .filter(new IsSObjectFieldEqual(Contact.FirstName, null))
                .mapValues(new FieldFromSObject(Contact.AccountId))
                .toSet(new Set<Id>());

        System.assertEquals(2, accountIdsNoFirstName.size());
        System.assert(accountIdsNoFirstName.contains(testRecordSource.getRecord(Account.SObjectType).withInsert().Id));
        System.assert(accountIdsNoFirstName.contains(testRecordSource2.getRecord(Account.SObjectType).withInsert().Id));
    }

    @IsTest
    static void changedObjectsFromTrigger() {
        List<Contact> newContacts = testRecordSource.getRecord(Contact.SObjectType).withInsert(2);
        List<Contact> oldContacts = newContacts.deepClone(true);
        newContacts[0].FirstName = 'Test First Name';

        List<Contact> contactsWithChangedFirstName = new LazyTriggerContextPairIterator(oldContacts, newContacts)
                .filter(new IsFieldChangedInTrigger(Contact.FirstName))
                .mapValues(new NewFromTriggerContextPair())
                .toList(new List<Contact>());

        System.assertEquals(1, contactsWithChangedFirstName.size());
        System.assertEquals(newContacts[0].Id, contactsWithChangedFirstName[0].Id);
    }

    @IsTest
    static void forkingGetFieldFromListOfSObjects() {
        List<Contact> allContacts = testRecordSource.getRecord(Contact.SObjectType).withInsert(2);
        allContacts.addAll((List<Contact>)testRecordSource2.getRecord(Contact.SObjectType).withInsert(2));
        List<Contact> contacts3 = testRecordSource3.getRecord(Contact.SObjectType).withoutInsert(2);
        for(Contact c : contacts3) {
            c.FirstName = 'Test First Name';
        }
        insert contacts3;

        allContacts.addAll(contacts3);

        Map<String, Object> accountIds = new LazySObjectIterator(allContacts)
                .fork()
                .addFork('noFirstName', new ForkIterator()
                        .filter(new IsSObjectFieldEqual(Contact.FirstName, null))
                        .mapValues(new FieldFromSObject(Contact.AccountId))
                        .postpone(new ToSet(new Set<Id>())))
                .addFork('withFirstName', new ForkIterator()
                        .filter(new IsNot(new IsSObjectFieldEqual(Contact.FirstName, null)))
                        .mapValues(new FieldFromSObject(Contact.AccountId))
                        .postpone(new ToSet(new Set<Id>())))
                .toMap();

        Set<Id> accountIdsNoFirstName = (Set<Id>)accountIds.get('noFirstName');
        Set<Id> accountIdsWithFirstName = (Set<Id>)accountIds.get('withFirstName');

        System.assertEquals(2, accountIdsNoFirstName.size());
        System.assert(accountIdsNoFirstName.contains(testRecordSource.getRecord(Account.SObjectType).withInsert().Id));
        System.assert(accountIdsNoFirstName.contains(testRecordSource2.getRecord(Account.SObjectType).withInsert().Id));
        System.assertEquals(1, accountIdsWithFirstName.size());
        System.assert(accountIdsWithFirstName.contains(testRecordSource3.getRecord(Account.SObjectType).withInsert().Id));
    }

    @IsTest
    static void primes() {
        System.assertEquals(5, new LazyIterator(new PositiveIntegers(4)).filter(new IsPrime()).firstOrDefault(null));
        System.assertEquals(7, new LazyIterator(new PositiveIntegers(6)).filter(new IsPrime()).firstOrDefault(null));
        System.assertEquals(11, new LazyIterator(new PositiveIntegers(8)).filter(new IsPrime()).firstOrDefault(null));
        System.assertEquals(13, new LazyIterator(new PositiveIntegers(12)).filter(new IsPrime()).firstOrDefault(null));
        System.assertEquals(17, new LazyIterator(new PositiveIntegers(14)).filter(new IsPrime()).firstOrDefault(null));
    }

    private class IsPrime implements BooleanFunction {
        public Boolean isTrueFor(Object o) {
            Integer n = (Integer)o;
            if(n <= 3) {
                return n > 1;
            }
            if (Math.mod(n, 2) == 0 || Math.mod(n, 3) == 0) {
                return false;
            }
            for(Integer i = 5; i * i <= n; i += 6) {
                if(Math.mod(n, i) == 0 || Math.mod(n, (i + 2)) == 0) {
                    return false;
                }
            }
            return true;
        }
    }
}