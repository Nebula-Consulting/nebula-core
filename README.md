# Nebula Core

 - Paste this onto the end of your My Domain URL: /packaging/installPackage.apexp?p0=04t6M000000gaxSQAQ
 - Include in your SFDX project as `"Nebula Core": "04t6M000000gaxSQAQ"`
 
The base set of classes used by Nebula Consulting. The licence for this code is MIT, see [LICENSE](LICENSE). 

Areas covered by the library:

  - [Metadata-configured trigger handler framework](force-app/triggerFramework/MetadataTriggerManager.md)
  - [SObjectIndex for storing/retrieving lists of SObjects based on 1 or more criteria](force-app/sObjectIndex/SObjectIndex.md)
  - [Iterator-based operations like filter() and map()](force-app/lazyIterator/LazyIterator.md)
  - Conversions between SObjects and JSON structures
  - [A dependency-injection framework for building test data](force-app/testRecordGenerator/TestRecordGenerator.md)
  - [Metadata-configured logging framework](force-app/logger/Logger.md)
  - Interfaces to help with common uses of the Strategy Pattern 
  - Caching class for retrieving objects by Name e.g. configuration data stored in SObjects
  - A callout-wrapper to make error-handling in callouts more consistent
  - A builder class for building dynamic SOQL queries
  - A class to dynamically get values in SObjects via lookup fields in a single call e.g. `SObjectGetter.get(obj, 'Lookup__r.Field__c')`
  - A default implementation of Metadata.DeployCallback which emails results
  - An HttpCalloutMock which just throws an exception
  - A class for pulling the details out of nested exceptions

## Just Triggers?

There is a lot of functionality in Nebula Core, but that also implies a footprint that might not work for you. So, you 
can install 'Nebula Triggers' instead. This contains just the trigger handlers and a few parts of Nebula Core that were 
used to write it. 

- [Install Nebula Triggers on Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t6M000000km7LQAQ,)
- [Install Nebula Triggers on Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t6M000000km7LQAQ,)
- Paste this onto the end of your My Domain URL: /packaging/installPackage.apexp?p0=04t6M000000km7LQAQ,
- Include in your SFDX project as `"Nebula Triggers": "04t6M000000km7LQAQ,"`

Or you just might want to build from the source with no namespace. 

In that case, use the [nebula-triggers/](nebula-triggers) directory. This 
is a symbolic link, that pulls in just what you need to run the trigger framework. Note that if you're on Windows, you 
need to tick a checkbox when you install Git to make this work (see https://github.community/t/git-bash-symbolic-links-on-windows/522/4).

So, for example, if you have checked out the entire repository, you should be able to run the following commands 
successfully to put just the triggers in a scratch org, as source:

    sfdx force:org:create edition=Developer --setalias 'Trigger Framework' --nonamespace
    sfdx force:source:deploy --sourcepath nebula-triggers -u 'Trigger Framework'
    sfdx force:apex:test:run --wait 60 -u 'Trigger Framework'

So, you could use `force:source:deploy` to deploy the code to your sandbox org for source-only usage.