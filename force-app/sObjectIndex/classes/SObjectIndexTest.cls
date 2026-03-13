/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */
@IsTest
private class SObjectIndexTest {

    private final static String DOE = 'Doe';
    private final static String ACCOUNT_ID = Contact.AccountId.getDescribe().getName();
    private final static String LAST_NAME = Contact.LastName.getDescribe().getName();
    private final static String BIRTHDATE = Contact.Birthdate.getDescribe().getName();

    private static Account togAccount = new Account(Name = 'ACME', Id = new TestIdGenerator(Account.SObjectType).next());

    @IsTest
    static void emptyIndex() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ ACCOUNT_ID, LAST_NAME });

        Assert.isNull(theIndex.get(new Contact()));
        Assert.isTrue(theIndex.isEmpty());
    }

    @IsTest
    static void setCaseInsensitiveWithData() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ ACCOUNT_ID, LAST_NAME }).put(new Contact());

        try {
            theIndex.setIsCaseInsensitive(true);
        } catch (IllegalStateException e) {
            Assert.areEqual(Label.SObjectIndex_Case_Insensitive_Error, e.getMessage());
            return;
        }
        Assert.isTrue(false, 'Should have thrown IllegalStateException');
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

        Assert.areEqual(2, group1.size());
        Assert.areEqual('0', group1[0].Name);
        Assert.areEqual('1', group1[1].Name);
        Assert.areEqual(1, group2.size());
        Assert.areEqual('2', group2[0].Name);
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

        Assert.areEqual(2, group1.size());
        Assert.areEqual('0', group1[0].Name);
        Assert.areEqual('1', group1[1].Name);
        Assert.areEqual(1, group2.size());
        Assert.areEqual('2', group2[0].Name);
    }

    @IsTest
    static void nullValueOnIndexField() {
        SObjectIndex theIndex = new SObjectIndex(Account.ParentId.getDescribe().getName()).put(togAccount);
        Account indexAccount = (Account)theIndex.get((Id)null);

        Assert.areEqual(togAccount.Id, indexAccount.Id);
    }

    @IsTest
    static void singleHit() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ ACCOUNT_ID, LAST_NAME });

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        Assert.areEqual(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        Assert.isTrue(!theIndex.isEmpty());

        Set<Object> accountIdKeySet = theIndex.keySet(ACCOUNT_ID);
        Assert.areEqual(1, accountIdKeySet.size());
        Assert.isTrue(accountIdKeySet.contains(togAccount.Id));

        Set<Object> lastNameKeySet = theIndex.keySet(LAST_NAME);
        Assert.areEqual(1, lastNameKeySet.size());
        Assert.isTrue(lastNameKeySet.contains(DOE));

        List<Contact> values = (List<Contact>)theIndex.values();
        Assert.areEqual(1, values.size());
        Assert.areEqual(togContact, values[0]);

        Iterator<Object> valuesIterator = theIndex.valueIterator();
        Assert.isTrue(valuesIterator.hasNext());
        Assert.areEqual(togContact, valuesIterator.next());
    }

    @IsTest
    static void keyList() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{
                ACCOUNT_ID, LAST_NAME
        });

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        Assert.areEqual(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        Assert.isTrue(!theIndex.isEmpty());

        List<Id> accountIdKeyList = (List<Id>)theIndex.keyList(new List<Id>());
        Assert.areEqual(1, accountIdKeyList.size());
        Assert.isTrue(accountIdKeyList.contains(togAccount.Id));
    }

    @IsTest
    static void keyIterator() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{
                ACCOUNT_ID, LAST_NAME
        });

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        Assert.areEqual(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        Assert.isTrue(!theIndex.isEmpty());

        Iterator<Object> accountIds = theIndex.keyIterator();
        Assert.isTrue(accountIds.hasNext());
        Assert.areEqual(togAccount.Id, accountIds.next());
    }

    @IsTest
    static void keySetId() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{
                ACCOUNT_ID, LAST_NAME
        });

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        Assert.areEqual(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        Assert.isTrue(!theIndex.isEmpty());

        Set<Id> accountIds = theIndex.keySet(new Set<Id>());
        Assert.areEqual(1, accountIds.size());
        Assert.isTrue(accountIds.contains(togAccount.Id));
    }

    @IsTest
    static void caseInsensitive() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME})
                .setIsCaseInsensitive(true);

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        Assert.areEqual(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE.toLowerCase())).size());
        Assert.isTrue(!theIndex.isEmpty());
    }

    @IsTest
    static void caseInsensitiveMap() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME})
                .setIsCaseInsensitive(true);

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE);
        theIndex.put(togContact);

        Assert.areEqual(1, theIndex.getAll(new Map<String, String> {
                ACCOUNT_ID  => togAccount.Id,
                LAST_NAME => DOE.toLowerCase()}).size());
        Assert.isTrue(!theIndex.isEmpty());
    }

    @IsTest
    static void caseInsensitiveReverse() {
        SObjectIndex theIndex = new SObjectIndex(LAST_NAME)
                .setIsCaseInsensitive(true);

        Contact togContact = new Contact(AccountId = togAccount.Id, LastName = DOE.toLowerCase());
        theIndex.put(togContact);

        Assert.areEqual(1, theIndex.getAll(DOE).size());
        Assert.isTrue(!theIndex.isEmpty());
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

        Assert.areEqual(2, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        Assert.isTrue(!theIndex.isEmpty());
        Set<Object> accountKeySet = theIndex.keySet(ACCOUNT_ID);
        Assert.areEqual(1, accountKeySet.size());
        Assert.isTrue(accountKeySet.contains(togAccount.Id));
        Set<Object> nameKeySet = theIndex.keySet('LastName');
        Assert.areEqual(2, nameKeySet.size());
        Assert.isTrue(nameKeySet.contains(DOE));
        Assert.isTrue(nameKeySet.contains('Deer'));
    }

    @IsTest
    static void nearHit() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME});

        theIndex.put(new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE));
        theIndex.put(new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = DOE + 2));

        Assert.areEqual(1, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
    }

    @IsTest
    static void simpleIndex() {
        List<Contact> data = new List<Contact> {
                new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE),
                new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = DOE + 2)
        };

        SObjectIndex theIndex = new SObjectIndex(ACCOUNT_ID).putAll(data);

        Assert.areEqual(2, theIndex.getAll(togAccount.Id).size());

        Set<Object> ks2 = theIndex.keySet();
        Assert.areEqual(1, ks2.size());
        Assert.isTrue(ks2.contains(togAccount.Id));

        theIndex.get(togAccount.Id);
        Assert.isNull(theIndex.get('null'));
        Assert.isTrue(theIndex.getAll('null').isEmpty());
    }

    @IsTest
    static void crossObjectField() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{'Account.Name', LAST_NAME});

        Contact togContact = new Contact(Account = togAccount,  LastName = DOE);
        theIndex.put(togContact);

        Assert.areEqual(1, theIndex.getAll(new Contact(Account = new Account(Name = togAccount.Name), LastName = DOE)).size());
        Assert.isTrue(!theIndex.isEmpty());

        List<Contact> values = (List<Contact>)theIndex.values();
        Assert.areEqual(1, values.size());
        Assert.areEqual(togContact, values[0]);
    }

    @IsTest
    static void exactHitMap() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME});

        theIndex.put(new Contact(AccountId = togAccount.Id, LastName = DOE));

        Assert.areEqual(1, theIndex.getAll(new Map<String, Object>{ACCOUNT_ID => togAccount.Id, LAST_NAME => DOE}).size());
        Assert.isTrue(!theIndex.isEmpty());
    }

    @IsTest
    static void twoHitsMap() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME}).putAll(
                new List<Contact> { new Contact(AccountId = null, FirstName = 'John', LastName = 'Doe'),
                        new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = 'Doe'),
                        new Contact(AccountId = togAccount.Id, FirstName = 'Fred', LastName = 'Deer')
                });

        List<Contact> fetchedContacts = theIndex.getAll(new Map<String, Object>{LAST_NAME => DOE});
        Assert.areEqual(2, fetchedContacts.size());
        Assert.isTrue(fetchedContacts[0].AccountId == null);
        Assert.isTrue(fetchedContacts[1].AccountId == togAccount.Id);
        Assert.isTrue(fetchedContacts[0].FirstName == 'John');
        Assert.isTrue(fetchedContacts[1].FirstName == 'Jane');
        Assert.areEqual(DOE, fetchedContacts[0].LastName);
        Assert.areEqual(DOE, fetchedContacts[1].LastName);
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
        Assert.areEqual(1, fetchedContacts.size());
        Assert.isTrue(fetchedContacts[0].AccountId == togAccount.Id);
        Assert.isTrue(fetchedContacts[0].FirstName == 'Jane');
        Assert.areEqual(DOE, fetchedContacts[0].LastName);
    }

    @IsTest
    static void remove() {
        SObjectIndex theIndex = getTwoHitsIndex();

        theIndex.remove(new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE));
        Assert.areEqual(0, theIndex.getAll(new Contact(AccountId = togAccount.Id, LastName = DOE)).size());
        Set<Object> keySetName = theIndex.keySet(LAST_NAME);
        Assert.areEqual(2, keySetName.size());
        Assert.isTrue(keySetName.contains('Deer'));
        Assert.isTrue(keySetName.contains(DOE));

        Assert.isTrue(theIndex.remove(new Contact()).isEmpty());
    }

    @IsTest
    static void removeMap() {
        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, LAST_NAME, Contact.FirstName.getDescribe().getName()});

        theIndex.putAll(new List<Contact> { new Contact(AccountId = togAccount.Id, FirstName = 'John', LastName = DOE),
                new Contact(AccountId = togAccount.Id, FirstName = 'Jane', LastName = DOE),
                new Contact(AccountId = togAccount.Id, FirstName = 'Fred', LastName = 'Deer')
        });
        theIndex.remove(new Map<String, Object> { 'FirstName' => 'John'});
        Assert.areEqual(1, theIndex.getAll(new Map<String, Object>{ACCOUNT_ID => togAccount.Id, LAST_NAME => DOE}).size());
        Set<Object> keySetName = theIndex.keySet(LAST_NAME);
        Assert.areEqual(2, keySetName.size());
        Assert.isTrue(keySetName.contains(DOE));
        Assert.isTrue(keySetName.contains('Deer'));
    }

    @IsTest
    static void indexOnDate() {
        Date date1 = Date.newInstance(2023, 1, 1);
        Date date2 = Date.newInstance(2023, 1, 2);
        Date date3 = Date.newInstance(2023, 1, 3);

        List<Contact> contacts = new List<Contact> {
                new Contact(LastName = 'Contact1', Birthdate = date1),
                new Contact(LastName = 'Contact2', Birthdate = date2),
                new Contact(LastName = 'Contact3', Birthdate = date3)
        };

        SObjectIndex theIndex = new SObjectIndex(Contact.Birthdate).setNormalizeKeys(true).putAll(contacts);

        List<Contact> result1 = theIndex.getAll(date1);
        List<Contact> result2 = theIndex.getAll(date2);
        List<Contact> result3 = theIndex.getAll(date3);
        
        Assert.areEqual(1, result1.size());
        Assert.areEqual('Contact1', result1[0].LastName);
        Assert.areEqual(1, result2.size());
        Assert.areEqual('Contact2', result2[0].LastName);
        Assert.areEqual(1, result3.size());
        Assert.areEqual('Contact3', result3[0].LastName);



    }

    @IsTest
    static void indexOnDateWithGetSObject() {
        Date date1 = Date.newInstance(2023, 1, 1);
        Date date2 = Date.newInstance(2023, 1, 2);
        Date date3 = Date.newInstance(2023, 1, 3);

        List<Contact> contacts = new List<Contact> {
            new Contact(LastName = 'Contact1', Birthdate = date1),
            new Contact(LastName = 'Contact2', Birthdate = date2),
            new Contact(LastName = 'Contact3', Birthdate = date3)
        };

        SObjectIndex theIndex = new SObjectIndex(Contact.Birthdate).putAll(contacts);

        Contact result1 = (Contact) theIndex.get(new Contact(Birthdate = date1));
        Contact result2 = (Contact) theIndex.get(new Contact(Birthdate = date2));
        Contact result3 = (Contact) theIndex.get(new Contact(Birthdate = date3));

        Assert.areEqual('Contact1', result1?.LastName);
        Assert.areEqual('Contact2', result2?.LastName);
        Assert.areEqual('Contact3', result3?.LastName);

    }

    @IsTest
    static void indexOnDateMultiFieldMap() {
        Date date1 = Date.newInstance(2023, 1, 1);
        Date date2 = Date.newInstance(2023, 1, 2);

        SObjectIndex theIndex = new SObjectIndex(Contact.Birthdate, Contact.LastName)
                .putAll(new List<Contact>{
                    new Contact(LastName = 'Doe', Birthdate = date1),
                    new Contact(LastName = 'Doe', Birthdate = date2)
                });

        Contact result1 = (Contact)theIndex.get(new Map<String, Object>{BIRTHDATE => date1, LAST_NAME => 'Doe'});
        Contact result2 = (Contact)theIndex.get(new Map<String, Object>{BIRTHDATE => date2, LAST_NAME => 'Doe'});

        Assert.isNotNull(result1);
        Assert.areEqual(date1, result1.Birthdate);
        Assert.isNotNull(result2);
        Assert.areEqual(date2, result2.Birthdate);
        Assert.areNotEqual(result1.Birthdate, result2.Birthdate);
    }

    @IsTest
    static void indexOnDateSObjectSpec() {
        Date date1 = Date.newInstance(2023, 1, 1);
        Date date2 = Date.newInstance(2023, 1, 2);

        Contact contact1 = new Contact(AccountId = togAccount.Id, LastName = 'Contact1', Birthdate = date1);
        Contact contact2 = new Contact(AccountId = togAccount.Id, LastName = 'Contact2', Birthdate = date2);

        SObjectIndex theIndex = new SObjectIndex(new List<String>{ACCOUNT_ID, BIRTHDATE})
                .putAll(new List<Contact>{contact1, contact2});

        Contact result1 = (Contact)theIndex.get(new Contact(AccountId = togAccount.Id, Birthdate = date1));
        Contact result2 = (Contact)theIndex.get(new Contact(AccountId = togAccount.Id, Birthdate = date2));

        Assert.isNotNull(result1);
        Assert.areEqual('Contact1', result1.LastName);
        Assert.isNotNull(result2);
        Assert.areEqual('Contact2', result2.LastName);
    }
}