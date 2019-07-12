# Nebula Core

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

