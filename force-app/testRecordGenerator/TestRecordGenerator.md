# TestRecordSource

TODO - _Insert lovely intro from Aidan._

## Importing Test Data for Standard Objects

To speed up creation of test data for standard objects the Nebula Core package contains a [JSON static resource](https://bitbucket.org/nebulaconsulting/nebula-core/src/051855f904e8/force-app/testRecordGenerator/staticresources/?at=master) of frequently used objects.

Supported standard objects:

- Account
- Contact
- Opportunity
- Product2
- PricebookEntry
- OpportunityLineItem

To create a standard test data record for Account for example the following can be used:

`new nebc.StandardTestRecordGenerators().deploy('Account');`

Beware, this will overwrite existing definitions if they have the same name.

**NOTE: You cannot pull down these metadata records to your local project as sfdx change tracking ignores changes made by the metadata deployment. A work around is to go in and edit each record.**

## Using Within Tests

### Simple Example

A simple example of this would be to define the TestRecordSource and get the record using the SObjectType and insert it manually:
    
    private static nebc.TestRecordSource testRecordSource = new nebc.TestRecordSource();

    @IsTest
    static void getContact() {
        Contact testContact = (Contact) testRecordSource.getRecord(Contact.SObjectType).withoutInsert();
        insert testContact;
    }



### Simple Create Example

A simple example of this would be to define the TestRecordSource and get the record using the SObjectType:
    
    private static nebc.TestRecordSource testRecordSource = new nebc.TestRecordSource();

    @IsTest
    static void createContact() {
        Contact testContact = (Contact) testRecordSource.getRecord(Contact.SObjectType).withInsert();
    }



The above example would insert one contact ready to be used for testing.

### Creating Multiple Records 

Creating multiple records using the same static TestRecordSource might not give you the results you expect. In the below example both contacts are in fact the same contact: 

    
    private static nebc.TestRecordSource testRecordSource = new nebc.TestRecordSource();

    @IsTest
    static void creatingMultipleContacts() {
        Contact testContact1 = (Contact) testRecordSource.getRecord(Contact.SObjectType).withInsert();
        Contact testContact2 = (Contact) testRecordSource.getRecord(Contact.SObjectType).withInsert();
        
        System.assertEquals(contact1.Id, contact2.Id);
        
    }


Why? TestRecordSource will simply return the cached result of the first Contact on the second request.

One work-around would be to simply clone the first Contact record and insert it again.
 
A better way to create multiple different records you could specify a number of records as a parameter to the withInsert method:

    @IsTest
    static void multipleContacts() {
        List<Contact> contacts = (List<Contact>) testRecordSource.getRecord(Contact.SObjectType).withInsert(2);

        System.assertNotEquals(contacts[0].Id, contacts[1].Id);
    }

This allows standard test fields functions to apply different logic to fields on each different Contact if set.

### Mixing With and Without Insert

Another way to create multiple records would be to use WithoutInsert, in the example below the first Contact will be created outside of the TestRecordSource framework.

Therefor the second Contact when retrieved will be a fresh version and not cached. Note: if a third Contact was created using withInsert after the second then it will return the cached version.
  

    @IsTest
     static void getContact() {
     
         Contact testContact = (Contact) testRecordSource.getRecord(Contact.SObjectType).withoutInsert();
         insert testContact;
 
         Contact testContact2 = (Contact) testRecordSource.getRecord(Contact.SObjectType).withInsert();
         
         System.assertNotEquals(testContact.Id, testContact2.Id);
 
     }


## Standard Test Field Functions

Not all fields cannot be set with static values, it may be fine to assign a contact the email address of 'foo@bar.com' but what if you want to create multiple contacts? 

To allow dynamic setting of fields there is the ability to use pre-defined standard [Test Field Functions](https://bitbucket.org/nebulaconsulting/nebula-core/src/051855f904e8/force-app/testRecordGenerator/classes/TestFieldFunctions.cls?at=master).

These include:

* AppendRandomNumber - append a random number to the end of a string
* InsertRandomNumber - insert random number at a given point in the string, for example using the String.format method and the placement parameter {0}.
* CurrentUserId - get the current user ID.
* NamedObjectId - get the record ID of a record using the Object API name and the record name.
* GetStandardPriceBookId - get the standard pricebook ID (Test.getStandardPricebookId()).
* CreateRecord - create the associated record, for example account when creating a contact.
* GetRecordTypeId - get the record type ID for given Object API name and record type developer name.
* Now - get the current date and time with the option to addDays and/or addMinutes.
* Today - get the current date with the option to addDays.
* Increment - increment the current value with the accumulator and increment.
* ReadParameter - ?

### Example of Test Field Functions

When specifying the Test Record Generator Field you can optionally set an Apex Class as follows:

`nebc.TestFieldFunctions.Today`

This will set the field to Today's date, optionally you can specify days to add in the Apex Class Parameters as JSON:

`{
 "addDays": 1
 }`

### Creating Custom Test Field Functions

TODO

## Set Record

TODO

## Variants

TODO

# Priority

TODO


