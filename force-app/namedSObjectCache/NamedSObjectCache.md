## Caching SObjects by Name with NamedSObjectCache

[NamedSObjectCache](classes/NamedSObjectCache.cls) provides a way to retrieve and cache SObjects by their name. On the 
first request, the object will be queried from the database. On subsequent requests, it will be returned from the 
cache. This is particularly useful for metadata objects like Record Types, or any configuration data stored in SObjects.

### Basic Usage

```apex
// Get an Account by Name
Account myAccount = (Account)new NamedSObjectCache(Account.SObjectType, 'Acme Corporation')
    .getObject();

// The second call returns from cache - no additional SOQL query
Account sameAccount = (Account)new NamedSObjectCache(Account.SObjectType, 'Acme Corporation')
    .getObject();
```

### Custom Name Fields

By default, `NamedSObjectCache` uses the `Name` field to find records. You can specify a different field:

```apex
// Find a Custom Setting by a custom field
My_Setting__c setting = (My_Setting__c)new NamedSObjectCache(My_Setting__c.SObjectType, 'ConfigA')
    .setNameField(My_Setting__c.Setting_Key__c)
    .getObject();
```

### Additional Query Filters

You can add additional WHERE clause conditions to filter results:

```apex
// Get an active Product by Name
Product2 product = (Product2)new NamedSObjectCache(Product2.SObjectType, 'Widget Pro')
    .setAndClause('IsActive = true')
    .getObject();
```

### Querying Additional Fields

By default, only the name field is queried. To include additional fields:

```apex
// Include additional fields in the query
Account account = (Account)new NamedSObjectCache(Account.SObjectType, 'Acme Corporation')
    .setExtraFields(new Set<String>{'Industry', 'AnnualRevenue', 'BillingCity'})
    .getObject();

// Now we can access all the queried fields
String industry = account.Industry;
```

### Record Types

A common use case is retrieving Record Types. There's a dedicated static method for this:

```apex
// Get a Record Type by SObject type and Developer Name
RecordType personAccountRT = NamedSObjectCache.getRecordType(Account.SObjectType, 'PersonAccount');

// Or using the SObject API name as a string
RecordType caseRT = NamedSObjectCache.getRecordType('Case', 'Support_Request');
```

### Multiple Records

You can retrieve multiple records at once using `getObjects()`:

```apex
// Note: Currently, the constructor takes a single name, but getObjects() 
// returns a Map that supports multiple cached results
Map<String, SObject> accountsByName = new NamedSObjectCache(Account.SObjectType, 'Acme Corporation')
    .getObjects();
```

### How Caching Works

- The cache is static, so it persists for the lifetime of the transaction
- Different SObject types maintain separate caches
- Cache keys are composed of the name value plus any `andClause` filter, ensuring that different query 
  conditions don't return incorrect cached results
- Once an object is cached (including null for not-found), subsequent requests return immediately without 
  a database query
- This makes it safe to call `getObject()` inside loops without worrying about SOQL limits
