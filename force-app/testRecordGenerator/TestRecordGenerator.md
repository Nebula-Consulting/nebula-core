# TestRecordSource

We are all familiar with the idea of a Test Utility class used for creating unit test data and can only be accessed only from a running test. 

Test utility classes contain methods that can be called by test methods to perform useful tasks, such as setting up test data.

One issue with creating test data this way is that it requires alterations to code when org validation rules change.

Another is how do we handle the move to unmanaged packages to build a shared test utility class?

TestRecordSource resolves these issues by moving the test data to custom metadata types, this means changes can be made without the need of a developer and packages can deploy and depend on their own or existing test metadata.

## Importing Test Data for Standard Objects

To speed up creation of test data for standard objects the Nebula Core package contains a [JSON static resource](https://bitbucket.org/nebulaconsulting/nebula-core/src/051855f904e8/force-app/testRecordGenerator/staticresources/?at=master) of frequently used objects.

Supported standard objects:

- Account
- Asset
- Case
- Contact
- ContentVersion
- Event
- Lead
- Opportunity
- OpportunityLineItem
- Order
- OrderItem
- Product2
- PricebookEntry
- Task

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
        Contact testContact = (Contact) testRecordSource.getRecord(Contact.SObjectType)
            .withInsert();
    }



The above example would insert one contact ready to be used for testing.

### Simple Create With Putting field

A test may require that a field to be set in a particular way, but it is only relevant for this one test. 

In this instance it doesn't make sense to adjust the record to include this data, instead you can put one or more field values as part of the chained get record in the test itself:

     @IsTest
     static void getContactAndSetField() {
         Contact testContact = (Contact) testRecordSource.getRecord(Contact.SObjectType)
             .put(Contact.Department, 'Development')
             .withInsert();
             
         System.assertEquals('Development', testContact.Department);
     } 


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
        List<Contact> contacts = (List<Contact>) testRecordSource.getRecord(Contact.SObjectType)
            .withInsert(2);

        System.assertNotEquals(contacts[0].Id, contacts[1].Id);
    }

This allows standard test fields functions to apply different logic to fields on each different Contact if set.

### Mixing With and Without Insert

Another way to create multiple records would be to use WithoutInsert, in the example below the first Contact will be created outside of the TestRecordSource framework.

Therefor the second Contact when retrieved will be a fresh version and not cached. Note: if a third Contact was created using withInsert after the second then it will return the cached version.
  

    @IsTest
     static void getContact() {
     
         Contact testContact = (Contact) testRecordSource.getRecord(Contact.SObjectType)
             .withoutInsert();
         insert testContact;
 
         Contact testContact2 = (Contact) testRecordSource.getRecord(Contact.SObjectType)
             .withInsert();
         
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
* ReadParameter - TODO

### Example of Test Field Functions

When specifying the Test Record Generator Field you can optionally set an Apex Class as follows:

`nebc.TestFieldFunctions.Today`

This will set the field to Today's date, optionally you can specify days to add in the Apex Class Parameters as JSON:

`{
 "addDays": 1
 }`

### Creating Custom Test Field Functions

It is possible to write custom test field functions by extending the _nebc.TestFieldFunctions.TestFieldFunctionWithParent class_.

Here is an example that was created to get the current user ID:

    global class GetCurrentUserId extends nebc.TestFieldFunctions.TestFieldFunctionWithParent {
         global Object getValue(String fieldName, Object value) {
             return UserInfo.getUserId();
         }
    }

This is now part of the standard library of functions, if you spot a useful function that is not already part of the standard library raise an issue [here](https://bitbucket.org/nebulaconsulting/nebula-core/jira?statuses=new&statuses=indeterminate&sort=-updated&page=1) to get it added.

## Set Record

Using the TestFieldFunctions it is possible to create a relationship record when creating the test record with 'CreateRecord'.

So for example creating a Contact can create the associate Account.

This may not always be the desired behaviour, so using 'setRecord' it is possible to override this and specify the related record.

     @IsTest
     static void setRecord() {
 
         Account testAccount = (Account) testRecordSource.getRecord(Account.SObjectType).withoutInsert();
         testAccount.Name = 'My New Account';
         insert testAccount;
 
         testRecordSource.setRecord(testAccount);
 
         Contact testContact = (Contact) testRecordSource.getRecord(Contact.SObjectType).withInsert();
 
         System.assertEquals(testAccount.Id, testContact.AccountId);
 
     }

## Variants

Variant allow different 'shapes' of the record to be stored. This may be useful for creating records with different record types and fields to be set. 

Another useful scenario is to allow records at different stages to be stored, consider an org when moving an opportunity to closed won requires many fields to be set. 

This could simply be defined as a 'Closed Won' variant of the opportunity: 

      @IsTest
      static void opportunityVariant() {             
          Opportunity openOpportunity = (Opportunity) testRecordSource.getRecord(Opportunity.SObjectType).withoutInsert();
          Opportunity closedWonOpportunity = (Opportunity) testRecordSource.getRecord(Opportunity.SObjectType).asVariant('Closed Won').withoutInsert();
      }

Note: It is also possible to set a record with a variant as follows:

    testRecordSource.setRecordAsVariant(testAccount, 'My Variant Name');

## Variant Inheritance

Defining different variants of a record is a good way to structure your test data allowing clear and concise way of defining the type of record being created.

One downside of this is that defining each record in its fullest can be timing consuming both initially and when inevitable org changes occur.

To alleviate this issue the idea of inheritance can be used so that only the differences need to be stored. 

Here is an example of a contact test record:

**Base Contact (no variant):**

    - FirstName: Foo
    - LastName: Bar
    - Email: foo@bar.com
    - Account: FooBar Inc.

If we wanted to create a variant of this that is attached to a different account we could do this by simply defining the variant and just the account.

By default, variants will inherit from the base contact (no variant) unless specified.

**Nebula Contact (Variant 'Nebula')**

    - Account: Nebula

So above we'd still have a first name of 'Foo' and a last name of 'Bar' etc... but the account would be Nebula not FooBar Inc.

If we wanted to create another variant from the 'Nebula' variant we simply make sure the 'Inherits From Variant' option is 'Nebula'. 

**Nebula Contact With DOB (Variant 'Nebula DOB')**

    - BirthDate: 30/07/1966

This would then create the contact with first name, last name, email, account and birth date all set.

Finally, here is an example of the variant examples:

         Contact baseContact = (Contact) testRecordSource.getRecord(Contact.SObjectType).withInsert();
         Contact nebulaContact = (Contact) testRecordSource.getRecord(Contact.SObjectType).asVariant('Nebula').withInsert();
         Contact nebulaDOBContact = (Contact) testRecordSource.getRecord(Contact.SObjectType).asVariant('Nebula DOB').withInsert();
 
         ....
 
         System.assertEquals('Bar', baseContact.LastName);
         System.assertEquals('Nebula', nebulaContact.Account.Name);
         System.assertEquals(Date.newInstance(1966, 7, 30), nebulaDOBContact.Birthdate);

# Priority

When specify a test record it is possible to assign a priority, so that if more than one test record exists for the same SObject and variant the highest priority record is used.

This is useful to override behaviour that is deployed as part of a package in a customer org.


