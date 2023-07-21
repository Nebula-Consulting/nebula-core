/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-06
 */

@IsTest
private class LazyIteratorExamples {

    static nebc.TestIdGenerator accountIdGenerator = new nebc.TestIdGenerator(Account.SObjectType);
    static nebc.TestIdGenerator contactIdGenerator = new nebc.TestIdGenerator(Contact.SObjectType);

    static List<Account> accounts = new List<Account> {
            new Account(Id = accountIdGenerator.next(), Name = 'Account One', BillingStreet = 'Billing Street 1', BillingCity = 'Billing City 1'),
            new Account(Id = accountIdGenerator.next(), Name = 'Account Two', BillingStreet = 'Billing Street 2', BillingCity = 'Billing City 2')
    };

    static List<Contact> contacts = new List<Contact> {
            new Contact(Id = contactIdGenerator.next(), LastName = 'Test LastName One', AccountId = accounts[0].Id),
            new Contact(Id = contactIdGenerator.next(), LastName = 'Test LastName Two', AccountId = accounts[0].Id),
            new Contact(Id = contactIdGenerator.next(), FirstName = 'Test FirstName', LastName = 'Test LastName Three', AccountId = accounts[1].Id)
    };

    @IsTest
    static void getFieldFromListOfSObjects() {
        Set<Id> accountsIds = new nebc.LazySObjectIterator(contacts)
                .get(Contact.AccountId, new Set<Id>());

        System.assertEquals(2, accountsIds.size());
        System.assert(accountsIds.contains(accounts[0].Id));
        System.assert(accountsIds.contains(accounts[1].Id));
    }

    @IsTest
    static void copyFieldInListOfSObjects() {
        new nebc.LazySObjectIterator(contacts)
                .putField(Contact.FirstName, Contact.LastName)
                .forEach();

        for(Contact thisContact : contacts) {
            System.assertEquals(thisContact.LastName, thisContact.FirstName);
        }
    }

    @IsTest
    static void find() {
        Contact foundContact = (Contact)new nebc.LazySObjectIterator(contacts)
                .filterOnField(Contact.LastName, contacts[1].LastName)
                .firstOrDefault(nebc.NoResult.NO_RESULT);

        System.assertEquals(contacts[1].Id, foundContact.Id);
    }

    @IsTest
    static void getFieldFromListOfSObjectsFilter() {
        Set<Id> accountsIds = new nebc.LazySObjectIterator(contacts)
                .filterT(new nebc.IsNull(Contact.FirstName))
                .get(Contact.AccountId, new Set<Id>());

        System.assertEquals(1, accountsIds.size());
        System.assert(accountsIds.contains(accounts[0].Id));
    }

    @IsTest
    static void modifySObjects() {
        new nebc.LazySObjectIterator(contacts)
                .put(Contact.LeadSource, 'Web')
                .forEach();

        for(Contact thisContact : contacts) {
            System.assertEquals('Web', thisContact.LeadSource);
        }
    }

    @IsTest
    static void mapSObjectsToOtherSObjects() {
        List<Task> tasks = new nebc.LazySObjectIterator(contacts)
                .mapValues(new nebc.SObjectFromPrototype(new Task(ActivityDate = Date.today().addDays(7)))
                        .putField(Task.WhoId, Contact.Id)
                        .put(Task.Subject, new nebc.Add('Follow up with ', new nebc.FieldFromSObject(Contact.LastName)))
                )
                .toList(new List<Task>());

        System.assertEquals(contacts.size(), tasks.size());
        for(Integer i=0; i < contacts.size(); i++) {
            System.assertEquals(Date.today().addDays(7), tasks[i].ActivityDate);
            System.assertEquals(contacts[i].Id, tasks[i].WhoId);
            System.assertEquals('Follow up with ' + contacts[i].LastName, tasks[i].Subject);
        }
    }

    @IsTest
    static void modifySObjectsConditionally() {
        new nebc.LazySObjectIterator(contacts)
                .putIf(new nebc.IsSObjectFieldEqual(Contact.AccountId, accounts[0].Id), Contact.LeadSource, 'Web')
                .putIf(new nebc.IsSObjectFieldEqual(Contact.AccountId, accounts[1].Id), Contact.LeadSource, 'Other')
                .forEach();

        for(Contact thisContact : contacts) {
            if(thisContact.AccountId == accounts[0].Id) {
                System.assertEquals('Web', thisContact.LeadSource);
            } else {
                System.assertEquals('Other', thisContact.LeadSource);
            }
        }
    }

    @IsTest
    static void useMapValuesToWriteBack() {
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

        new nebc.LazySObjectIterator(contacts)
                .put(
                        Contact.MailingStreet,
                        new nebc.Composition(Contact.AccountId)
                                .compose(new nebc.GetFrom(accountMap))
                                .compose(new nebc.FieldFromSObject(Account.BillingStreet)))
                .forEach();

        for(Contact thisContact : contacts) {
            if(thisContact.AccountId == accounts[0].Id) {
                System.assertEquals(accounts[0].BillingStreet, thisContact.MailingStreet);
            } else {
                System.assertEquals(accounts[1].BillingStreet, thisContact.MailingStreet);
            }
        }
    }

    @IsTest
    static void useMapValuesToWriteBackMultipleValues() {
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

        new nebc.LazySObjectIterator(contacts)
                .mapValues(new nebc.ToPair(new nebc.Composition(new nebc.FieldFromSObject(Contact.AccountId), new nebc.GetFrom(accountMap))))
                .forEach(
                        new BinaryComposition(
                                new nebc.SObjectPutField(Contact.MailingStreet, new nebc.FieldFromSObject(Account.BillingStreet)),
                                new nebc.SObjectPutField(Contact.MailingCity, new nebc.FieldFromSObject(Account.BillingCity))
                        )
                );

        for(Contact thisContact : contacts) {
            if(thisContact.AccountId == accounts[0].Id) {
                System.assertEquals(accounts[0].BillingStreet, thisContact.MailingStreet);
                System.assertEquals(accounts[0].BillingCity, thisContact.MailingCity);
            } else {
                System.assertEquals(accounts[1].BillingStreet, thisContact.MailingStreet);
                System.assertEquals(accounts[1].BillingCity, thisContact.MailingCity);
            }
        }
    }

    @IsTest
    static void changedObjectsFromTrigger() {
        List<Contact> newContacts = contacts;
        List<Contact> oldContacts = contacts.deepClone(true);
        newContacts[0].FirstName = 'Test First Name';

        List<Contact> contactsWithChangedFirstName = new nebc.LazyTriggerContextPairIterator(oldContacts, newContacts)
                .filterT(new nebc.IsFieldChangedInTrigger(Contact.FirstName))
                .newRecords()
                .toList();

        System.assertEquals(1, contactsWithChangedFirstName.size());
        System.assertEquals(newContacts[0].Id, contactsWithChangedFirstName[0].Id);
    }
}