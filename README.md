# Nebula Core

 - [Install on Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0J0000002VTVQA2)
 - [Install on Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0J0000002VTVQA2)

The base set of classes used by Nebula Consulting. Topics covered:

  - Metadata-configured trigger handler framework
  - Metadata-configured logging framework
  - Conversions between SObjects and JSON structures
  - A dependency-injection framework for building test data
  - Support for declarative programming style
  - SObjectIndex for storing/retrieving lists of SObjects based on 1 or more criteria
  - Interfaces to help with common uses of the Strategy Pattern 
  - Caching class for retrieving objects by Name e.g. configuration data stored in SObjects
  - A callout-wrapper to make error-handling in callouts more consistent
  - A builder class for building dynamic SOQL queries
  - A class to dynamically get values in SObjects via lookup fields in a single call e.g. SObjectGetter.get(obj, 'Lookup__r.Field__c')
  - A default implementation of Metadata.DeployCallback which emails results
  - An HttpCalloutMock which just throws an exception
  - A class for pulling the details out of nested exceptions

## Trigger Handlers

A trigger handler requires three things:

 1. A trigger on the relevant object, invoking the framework's handler class [MetadataTriggerManager](force-app/main/default/classes/MetadataTriggerManager.cls) e.g.
    ```
    trigger Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        new MetadataTriggerManager(Contact.SObjectType).handle();
    }
    ```
    The trigger here should handle all events, and pass in the `SObjectType`
 1. A class implementing some of the trigger handler interfaces ([AfterInsert](force-app/main/default/classes/AfterInsert.cls), 
 [BeforeUpdate](force-app/main/default/classes/BeforeUpdate.cls), etc.). See [ContactNumberOfContactsRollUp](examples/main/default/classes/ContactNumberOfContactsRollUp.cls) for an example.
 1. A metadata record telling the framework about your class
 
### Notes

If you have multiple triggers on the same object, they should reside in separate classes to keep concerns separate.

Your trigger handler class should be `global`, or the framework won't be able to create an instance of it. It should 
probably also be `without sharing` so that it runs in system mode.

Your metadata record includes an Order field. Triggers are run in ascending order on that field. When you don't care 
about order, you can leave this as 0. Negative numbers are acceptable, so if you have some triggers at 0 and need to add
one which runs before them, you could make it -10.  
