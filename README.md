# Nebula Core

 - [Install on Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0J0000006c4eQAA)
 - [Install on Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0J0000006c4eQAA)
 - Include in your SFDX project as `"Nebula Core": "04t0J0000006c4eQAA"`
 
The base set of classes used by Nebula Consulting. The licence for this code is MIT, see [LICENSE](LICENSE). 

Areas covered by the library:

  - [Metadata-configured trigger handler framework](MetadataTriggerManager.md)
  - [SObjectIndex for storing/retrieving lists of SObjects based on 1 or more criteria](SObjectIndex.md)
  - [Iterator-based operations like filter() and map()](LazyIterator.md)
  - Conversions between SObjects and JSON structures
  - [A dependency-injection framework for building test data](TestRecordGenerator.md)
  - [Metadata-configured logging framework](Logger.md)
  - Interfaces to help with common uses of the Strategy Pattern 
  - Caching class for retrieving objects by Name e.g. configuration data stored in SObjects
  - A callout-wrapper to make error-handling in callouts more consistent
  - A builder class for building dynamic SOQL queries
  - A class to dynamically get values in SObjects via lookup fields in a single call e.g. `SObjectGetter.get(obj, 'Lookup__r.Field__c')`
  - A default implementation of Metadata.DeployCallback which emails results
  - An HttpCalloutMock which just throws an exception
  - A class for pulling the details out of nested exceptions

