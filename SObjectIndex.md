##Storing/retrieving SObjects with SObjectIndex

[SObjectIndex](force-app/main/default/classes/SObjectIndex.cls) is a generalisation of something that will be familiar to most Apex programmers: a Map of  Ids to SObjects.

It brings great benefits over a standard `Map<Id, SObject>`, though:

 - You can choose which field to use as the index: It doesn't just have to be Id
 - If there are multiple records with the same value in the SObjectIndex, it handles the Lists so you don’t have to directly create and manage something like Map<String, List<Contact>>
 - You can use fields on related objects as the index e.g. for a list of Contacts, we can index on Account.Industry
 - You can set the index to be case-insensitive
 - You can index on multiple fields

And more, read on…

Here’s the plain Apex version:

    Set<Id> contactIds = getContactIdsFrom(objectsWithContactField); // Just assume such a method exists
    Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT FirstName, LastName FROM Contact WHERE Id IN :contactIds]);
    for (SObject objectWithContactField : objectsWithContactField) {
        Contact thisContact = contactsById.get((Id) objectWithContactField.get('Contact__c'));
        // Do something with objectWithContactField and thisContact 
    }

The `Map<Id, Contact>`  makes use of a neat Apex trick: it can take a list of SObjects and initialise them directly into a map in one line. This allows you to query all the Contacts that you need you need in one SOQL query, and efficiently retrieve them later. It is a very useful thing to have in the language.

But, what if you need to find your Contacts by some other criteria? Say, LastName? That’s where SObjectIndex comes in:

    Set<String> lastNames = new SObjectIndex('Last_Name__c').putAll(objectsWithLastName).keySet();
    SObjectIndex contactsByLastName = new SObjectIndex('LastName').putAll([SELECT FirstName, LastName FROM Contact WHERE LastName IN :lastNames]);
    for (SObject objectWithLastName : objectsWithLastName) {
        List<Contact> theseContacts = contactsByLastName.getAll(objectWithLastName.get('Last_Name__c'));
        // Do something with objectWithLastName and theseContacts 
    }

SObjectIndex takes the idea of easily building a map out of SObjects, and generalises it to be able to index on any field. You construct an SObjectIndex by passing in the field you want to index on, then adding a list of SObjects as data. It supports the same sorts of operations as a map: put(), get(), remove(), keySet(), values(); along with some extensions due to its generic nature: putAll(), getAll(), keySet(field).
As you can see in the first line of the listing above, it gives us a neat way to get the set of values for any field on a list of objects by using keySet().

### Field Relationships

You need to index on a field from a related object? No problem:

    SObjectIndex contactsByIndustry = new SObjectIndex('Account.Industry').putAll([SELECT FirstName, LastName, Account.Industry FROM Contact]);
    List<Contact> agricultureContacts = contactsByIndustry.getAll('Agriculture');

Any field you’ve queried (custom fields, or standard; on the object or following a relationship) is available to use as the index.

### Case Sensitivity

The default is for the index to be case-sensitive, but it doesn't have to be. The following will retrieve the same agriculture contacts as above:

    SObjectIndex contactsByIndustry = new SObjectIndex('Account.Industry').setIsCaseInsensitive(true).putAll([SELECT FirstName, LastName, Account.Industry FROM Contact]);
    List<Contact> agricultureContacts = contactsByIndustry.getAll('aGrIcUlTuRe');

### Multiple Fields

One field is pretty useful. Multiple fields opens up a whole new world of possibilities. We can use SObjectIndex for jobs like checking for duplicates. Suppose, for example, we want to insert some new contacts, but only if there are no existing contacts which match on all of: Email, FirstName, LastName.

    public void insertUniqueContacts(List<Contact> newContactsToMaybeInsert) {
        List<String> fieldsToIndexOn = new List<String>{'Email', 'FirstName', 'LastName'};
    
        SObjectIndex newContactsIndex = new SObjectIndex(fieldsToIndexOn).putAll(newContactsToMaybeInsert);
        Set<String> emails = newContactsIndex.keySet('Email');
        Set<String> firstNames = newContactsIndex.keySet('FirstName');
        Set<String> lastNames = newContactsIndex.keySet('LastName');
    
        SObjectIndex existingContacts = new SObjectIndex(fieldsToIndexOn).putAll(
        [
                SELECT Email, FirstName, LastName 
                FROM Contact 
                WHERE Email IN :emails 
                AND FirstName IN :firstNames 
                AND LastName IN :lastNames
        ]);
    
        List<Contact> toInsert = new List<Contact>();
        for(Contact newContact : newContactsToMaybeInsert) {
            if(existingContacts.get(newContact) == null) {
                toInsert.add(newContact);
            }
        }
        insert toInsert;
    }

We start by using the keySet() function to get all of the key values from newContactsToMaybeInsert. Then, we can query all existing Contacts where Email, FirstName, and LastName are mentioned in newContactsToMaybeInsert. But this doesn't guarantee that all three fields match any particular record in newContactsToMaybeInsert, but it gives us a superset of the records that we are looking for.
SObjectIndex is going to take care of finding the records where all three match. When we do a get() on the SObjectIndex, it checks all of the fields from the object you pass in and returns the first object it has which matches on all three fields (or null, if nothing entirely matches).

### Polymorphism

If two SObject definitions have a common set of fields, you can populate an SObjectIndex with one type, and then use the other to query common records. For example, suppose we are implementing a custom Lead conversion process where we need to find existing Contacts that match each Lead before converting it. We can find existing Contacts via an SObjectIndex where we just use a Lead as the criteria for retrieval:

    public void convertLeads(List<Lead> toConvert) {
        List<String> fieldsToIndexOn = new List<String>{'Email', 'FirstName', 'LastName'};
    
        SObjectIndex newContactsIndex = new SObjectIndex(fieldsToIndexOn).putAll(toConvert);
        Set<String> emails = newContactsIndex.keySet('Email');
        Set<String> firstNames = newContactsIndex.keySet('FirstName');
        Set<String> lastNames = newContactsIndex.keySet('LastName');
    
        SObjectIndex existingContacts = new SObjectIndex(fieldsToIndexOn).putAll(
        [
                SELECT Email, FirstName, LastName
                FROM Contact
                WHERE Email IN :emails
                AND FirstName IN :firstNames
                AND LastName IN :lastNames
        ]);
    
        List<Database.LeadConvert> convertOperations = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        for(Lead thisToConvert : toConvert) {
            Database.LeadConvert thisLeadConvert = new Database.LeadConvert();
            thisLeadConvert.setLeadId(thisToConvert.Id);
            thisLeadConvert.setConvertedStatus(convertStatus.MasterLabel);
    
            Contact existingContact = (Contact)existingContacts.get(thisToConvert);
            if(existingContact != null) {
                thisLeadConvert.setContactId(existingContact.Id);
            }
            convertOperations.add(thisLeadConvert);
        }
        Database.convertLead(convertOperations);
    }

### Read-Only Fields

Using an SObject itself as the criteria for retrieval from the SObjectIndex is handy, but it’s not always appropriate. Suppose you need to retrieve SObjects from the SObjectIndex based on a formula field… Apex will not let you write to that object in your code, even if you don’t intent to commit it to the database. In this case you can use a map as your criterion:

    SObjectIndex anIndex = new SObjectIndex(new List<String>{'My_Field__c', 'My_Formula__c'}).putAll(data);
    
    SObject value = anIndex.get(new Map<String, Object>{
            'My_Field__c' => 'foo',
            'My_Formula__c' => 'bar'
    });

### Don't Care

Suppose you have an existing SObjectIndex built against two fields: FirstName, and LastName. What happens if we do a get() with the criteria set to have a LastName, but no FirstName? i.e.

    SObjectIndex firstAndLastNameToContact = new SObjectIndex(new List<String>{'FirstName', 'LastName'}).putAll(data);
    
    List<Contact> results = firstAndLastNameToContact.getAll(new Contact(LastName = 'Simpson'));

This is interpreted as:
Get all the Contacts where LastName is ‘Simpson’ and FirstName is null.
If we do the similar thing with the map form, the interpretation is different:

    SObjectIndex firstAndLastNameToContact = new SObjectIndex(new List<String>{'FirstName', 'LastName'}).putAll(data);
    
    List<Contact> results = firstAndLastNameToContact.getAll(new Map<String, Object>{'LastName' => 'Simpson'});

This is interpreted as:
Get all the Contacts where LastName is ‘Simpson’ and FirstName can be anything.
So, you can use whichever suits your needs.