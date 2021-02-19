/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */

@IsTest
private class SObjectIndexTest {

    private final static String DOE = 'Doe';
    private final static String ACCOUNT_ID = Contact.AccountId.getDescribe().getName();
    private final static String LAST_NAME = Contact.LastName.getDescribe().getName();

    private static Account togAccount = new Account(Name = 'ACME', Id = new TestIdGenerator(Account.SObjectType).next());

    @IsTest
    static void emptyIndex() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ ACCOUNT_ID, LAST_NAME });

        System.assertEquals(null, theIndex.get(new Contact()));
        System.assert(theIndex.isEmpty());
    }

    @IsTest
    static void setCaseInsensitiveWithData() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ ACCOUNT_ID, LAST_NAME }).put(new Contact());

        try {
            theIndex.setIsCaseInsensitive(true);
        } catch (IllegalStateException e) {
            System.assertEquals(Label.SObjectIndex_Case_Insensitive_Error, e.getMessage());
            return;
        }
        System.assert(false, 'Should have thrown IllegalStateException');
    }

    @IsTest
    static void indexOnDecimal() {
        List<Account> accounts = new List<Account> {togAccount, togAccount.clone(), togAccount.clone()};
        accounts[0].NumberOfEmployees = 1;
        accounts[0].Name = '0';
        accounts[1].NumberOfEmployees = 1;
        accounts[1].Name = '1';
        accounts[2].NumberOfEmployees = 3;
        accounts[2].Name = '2';

        SObjectIndex theIndex = new SObjectIndex(new List<String>{ Account.NumberOfEmployees.getDescribe().getName()})
                .putAll(accounts);

        List<Account> group1 = theIndex.getAll(1);
        List<Account> group2 = theIndex.getAll(3);

        System.assertEquals(2, group1.size());
        System.assertEquals('0', group1[0].Name);
        System.assertEquals('1', group1[1].Name);
        System.assertEquals(1, group2.size());
        System.assertEquals('2', group2[0].Name);
    }

    @IsTest
    static void putAllIterator() {
        List<Account> accounts = new List<Account> {togAccount, togAccount.clone(), togAccount.clone()};
        accounts[0].NumberOfEmployees = 1;
        accounts[0].Name = '0';
        accounts[1].NumberOfEmployees = 1;
        accounts[1].Name = '1';
        accounts[2].NumberOfEmployees = 3;
        accounts[2].Name = '2';
        Iterator<Account> accountIterator = accounts.iterator();
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ Account.NumberOfEmployees.getDescribe().getName()})
                .putAll(accountIterator);

        List<Account> group1 = theIndex.getAll(1);
        List<Account> group2 = theIndex.getAll(3);

        System.assertEquals(2, group1.size());
        System.assertEquals('0', group1[0].Name);
        System.assertEquals('1', group1[1].Name);
        System.assertEquals(1, group2.size());
        System.assertEquals('2', group2[0].Name);
    }

    @IsTest
    static void nullValueOnIndexField() {
        SObjectIndex theIndex = new SObjectIndex(Account.ParentId.getDescribe().getName()).put(togAccount);
        Account indexAccount = (Account)theIndex.get((Id)null);

        System.assertEquals(togAccount.Id, indexAccount.Id);
    }

    @IsTest
    static void singleHit() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ ACCOUNT_ID, LAST_NAME });

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        System.assertEquals(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        System.assert(!theIndex.isEmpty());

        Set<Object> accountIdKeySet = theIndex.keySet(ACCOUNT_ID);
        System.assertEquals(1, accountIdKeySet.size());
        System.assert(accountIdKeySet.contains(togAccount.Id));

        Set<Object> lastNameKeySet = theIndex.keySet(LAST_NAME);
        System.assertEquals(1, lastNameKeySet.size());
        System.assert(lastNameKeySet.contains(DOE));

        List<Contact> values = (List<Contact>)theIndex.values();
        System.assertEquals(1, values.size());
        System.assertEquals(togContact, values[0]);

        Iterator<Object> valuesIterator = theIndex.valueIterator();
        System.assert(valuesIterator.hasNext());
        System.assertEquals(togContact, valuesIterator.next());
    }

    @IsTest
    static void keyList() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{
                ACCOUNT_ID, LAST_NAME
        });

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        System.assertEquals(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        System.assert(!theIndex.isEmpty());

        List<Id> accountIdKeyList = (List<Id>)theIndex.keyList(new List<Id>());
        System.assertEquals(1, accountIdKeyList.size());
        System.assert(accountIdKeyList.contains(togAccount.Id));
    }

    @IsTest
    static void keyIterator() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{
                ACCOUNT_ID, LAST_NAME
        });

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        System.assertEquals(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        System.assert(!theIndex.isEmpty());

        Iterator<Object> accountIds = theIndex.keyIterator();
        System.assert(accountIds.hasNext());
        System.assertEquals(togAccount.Id, accountIds.next());
    }

    @IsTest
    static void keySetId() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{
                ACCOUNT_ID, LAST_NAME
        });

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        System.assertEquals(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        System.assert(!theIndex.isEmpty());

        Set<Id> accountIds = theIndex.keySet(new Set<Id>());
        System.assertEquals(1, accountIds.size());
        System.assert(accountIds.contains(togAccount.Id));
    }

    @IsTest
    static void caseInsensitive() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME})
                .setIsCaseInsensitive(true);

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        System.assertEquals(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE.toLowerCase())).size());
        System.assert(!theIndex.isEmpty());
    }

    @IsTest
    static void caseInsensitiveMap() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME})
                .setIsCaseInsensitive(true);

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        System.assertEquals(1, theIndex.getAll(new Map<String, String> {
                ACCOUNT_ID  => togAccount.Id,
                LAST_NAME => DOE.toLowerCase()}).size());
        System.assert(!theIndex.isEmpty());
    }

    @IsTest
    static void caseInsensitiveReverse() {
        SObjectIndex theIndex = new SObjectIndex(LAST_NAME)
                .setIsCaseInsensitive(true);

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE.toLowerCase());
        theIndex.put(togContact);

        System.assertEquals(1, theIndex.getAll(DOE).size());
        System.assert(!theIndex.isEmpty());
    }

    private static SObjectIndex getTwoHitsIndex() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME});

        theIndex.putAll(new List<Contact> { new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE),
                new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = DOE),
                new Contact(AccountId = togAccount.Id, FirstName = 'Fred', LastName = 'Deer')
        });
        return theIndex;
    }

    @IsTest
    static void twoHits() {
        SObjectIndex theIndex = getTwoHitsIndex();

        System.assertEquals(2, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        System.assert(!theIndex.isEmpty());
        Set<Object> accountKeySet = theIndex.keySet(ACCOUNT_ID);
        System.assertEquals(1, accountKeySet.size());
        System.assert(accountKeySet.contains(togAccount.Id));
        Set<Object> nameKeySet = theIndex.keySet('LastName');
        System.assertEquals(2, nameKeySet.size());
        System.assert(nameKeySet.contains(DOE));
        System.assert(nameKeySet.contains('Deer'));
    }

    @IsTest
    static void nearHit() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME});

        theIndex.put(new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE));
        theIndex.put(new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = DOE + 2));

        System.assertEquals(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
    }

    @IsTest
    static void simpleIndex() {
        List<Contact> data = new List<Contact> {
                new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE),
                new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = DOE + 2)
        };

        SObjectIndex theIndex = new SObjectIndex(ACCOUNT_ID).putAll(data);

        System.assertEquals(2, theIndex.getAll(togAccount.Id).size());

        Set<Object> ks2 = theIndex.keySet();
        System.assertEquals(1, ks2.size());
        System.assert(ks2.contains(togAccount.Id));

        theIndex.get(togAccount.Id);
        System.assertEquals(null, theIndex.get('null'));
        System.assert(theIndex.getAll('null').isEmpty());
    }

    @IsTest
    static void crossObjectField() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{'Account.Name', LAST_NAME});

        Contact togContact = new Contact(Account = togAccount,  LastName = DOE);
        theIndex.put(togContact);

        System.assertEquals(1, theIndex.getAll(new Contact(Account = new Account(Name = togAccount.Name), LastName = DOE)).size());
        System.assert(!theIndex.isEmpty());

        List<Contact> values = (List<Contact>)theIndex.values();
        System.assertEquals(1, values.size());
        System.assertEquals(togContact, values[0]);
    }

    @IsTest
    static void exactHitMap() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME});

        theIndex.put(new Contact(AccountId = togAccount.Id, LastName = DOE));

        System.assertEquals(1, theIndex.getAll(new Map<String, Object>{ACCOUNT_ID => togAccount.Id, LAST_NAME => DOE}).size());
        System.assert(!theIndex.isEmpty());
    }

    @IsTest
    static void twoHitsMap() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME}).putAll(
                new List<Contact> { new Contact(AccountId = null, FirstName = 'John', LastName = 'Doe'),
                        new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = 'Doe'),
                        new Contact(AccountId = togAccount.Id, FirstName = 'Fred', LastName = 'Deer')
                });

        List<Contact> fetchedContacts = theIndex.getAll(new Map<String, Object>{LAST_NAME => DOE});
        System.assertEquals(2, fetchedContacts.size());
        System.assert(fetchedContacts[0].AccountId == null);
        System.assert(fetchedContacts[1].AccountId == togAccount.Id);
        System.assert(fetchedContacts[0].FirstName == 'John');
        System.assert(fetchedContacts[1].FirstName == 'Jane');
        System.assertEquals(DOE, fetchedContacts[0].LastName);
        System.assertEquals(DOE, fetchedContacts[1].LastName);
    }

    @IsTest
    static void twoHitsSubIndex() {
        SObjectIndex theIndex =  new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME}).putAll(
                new List<Contact> { new Contact(AccountId = null, FirstName = 'John', LastName = 'Doe'),
                        new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = 'Doe'),
                        new Contact(AccountId = togAccount.Id, FirstName = 'Fred', LastName = 'Deer')
                });

        SObjectIndex subIndex = theIndex.getSubIndex(togAccount.Id);
        List<Contact> fetchedContacts = subIndex.getAll(new Map<String, Object>{LAST_NAME => DOE});
        System.assertEquals(1, fetchedContacts.size());
        System.assert(fetchedContacts[0].AccountId == togAccount.Id);
        System.assert(fetchedContacts[0].FirstName == 'Jane');
        System.assertEquals(DOE, fetchedContacts[0].LastName);
    }

    @IsTest
    static void remove() {
        SObjectIndex theIndex = getTwoHitsIndex();

        theIndex.remove(new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE));
        System.assertEquals(0, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        Set<Object> keySetName = theIndex.keySet(LAST_NAME);
        System.assertEquals(2, keySetName.size());
        System.assert(keySetName.contains('Deer'));
        System.assert(keySetName.contains(DOE));

        System.assert(theIndex.remove(new Contact()).isEmpty());
    }

    @IsTest
    static void removeMap() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME, Contact.FirstName.getDescribe().getName()});

        theIndex.putAll(new List<Contact> { new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE),
                new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = DOE),
                new Contact(AccountId = togAccount.Id, FirstName = 'Fred', LastName = 'Deer')
        });
        theIndex.remove(new Map<String, Object> { 'FirstName' => 'John'});
        System.assertEquals(1, theIndex.getAll(new Map<String, Object>{ACCOUNT_ID => togAccount.Id, LAST_NAME => DOE}).size());
        Set<Object> keySetName = theIndex.keySet(LAST_NAME);
        System.assertEquals(2, keySetName.size());
        System.assert(keySetName.contains(DOE));
        System.assert(keySetName.contains('Deer'));
    }
}