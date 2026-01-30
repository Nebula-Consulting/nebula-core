## Building Dynamic SOQL Queries with QueryBuilder

[QueryBuilder](classes/QueryBuilder.cls) simplifies the creation of dynamic SOQL queries. It handles field deduplication, 
field sets, subqueries, and generates clean, readable SOQL strings.

### Basic Usage

```apex
// Create a query for Contacts
String query = new QueryBuilder(Contact.SObjectType)
    .addField(Contact.FirstName)
    .addField(Contact.LastName)
    .addField(Contact.Email)
    .setWhereClause('AccountId != null')
    .getQuery();

// Result: SELECT firstname, lastname, email FROM Contact WHERE AccountId != null

List<Contact> contacts = Database.query(query);
```

### Adding Fields

QueryBuilder provides multiple ways to add fields to your query:

```apex
// Using SObjectField tokens (recommended - compile-time checking)
new QueryBuilder(Account.SObjectType)
    .addField(Account.Name)
    .addField(Account.Industry);

// Using field name strings
new QueryBuilder(Account.SObjectType)
    .addField('Name')
    .addField('CreatedBy.Name'); // Supports relationship fields

// Adding multiple fields at once
new QueryBuilder(Account.SObjectType)
    .addFields(new List<SObjectField>{Account.Name, Account.Industry, Account.Website});

// Adding fields from a Field Set
new QueryBuilder(Account.SObjectType)
    .addFieldSet('My_Field_Set');

// Adding all fields on the object
new QueryBuilder(Account.SObjectType)
    .addAllFields();

// Adding fields matching a filter
new QueryBuilder(Account.SObjectType)
    .addAllFields(new IsAccessible()); // Only fields the user can access
```

### WHERE Clauses

```apex
// Simple WHERE clause
new QueryBuilder(Contact.SObjectType)
    .addField(Contact.Name)
    .setWhereClause('Email != null AND AccountId = :accountId')
    .getQuery();

// The WHERE keyword is added automatically
```

### ORDER BY and Pagination

```apex
String query = new QueryBuilder(Contact.SObjectType)
    .addField(Contact.Name)
    .addField(Contact.CreatedDate)
    .setOrderByClause('CreatedDate DESC, Name ASC')
    .setPaginationClause('LIMIT 100 OFFSET 50')
    .getQuery();

// Result: SELECT name, createddate FROM Contact ORDER BY CreatedDate DESC, Name ASC LIMIT 100 OFFSET 50
```

### GROUP BY

```apex
String query = new QueryBuilder(Contact.SObjectType)
    .addField('COUNT(Id)')
    .addField(Contact.AccountId)
    .groupBy(Contact.AccountId)
    .getQuery();

// Result: SELECT COUNT(Id), accountid FROM Contact GROUP BY AccountId
```

### Subqueries

QueryBuilder supports nested subqueries for querying child relationships:

```apex
QueryBuilder contactSubQuery = new QueryBuilder('Contacts')
    .addField('Name')
    .addField('Email');

String query = new QueryBuilder(Account.SObjectType)
    .addField(Account.Name)
    .addSubQuery(contactSubQuery)
    .getQuery();

// Result: SELECT name, (SELECT name, email FROM Contacts) FROM Account
```

### Security

Use `withSecurityEnforced()` to add `WITH SECURITY_ENFORCED` to your query, which enforces field-level security:

```apex
String query = new QueryBuilder(Account.SObjectType)
    .addField(Account.Name)
    .addField(Account.AnnualRevenue)
    .withSecurityEnforced()
    .getQuery();

// Result: SELECT name, annualrevenue FROM Account WITH SECURITY_ENFORCED
```

### Field Deduplication

QueryBuilder automatically handles duplicate fields:

```apex
String query = new QueryBuilder(Account.SObjectType)
    .addField(Account.Name)
    .addField('Name')           // Duplicate - ignored
    .addField(Account.Name)     // Duplicate - ignored
    .addFieldSet('My_Set')      // May contain Name - also deduplicated
    .getQuery();

// Name only appears once in the query
```

### Default Field

If no fields are specified, QueryBuilder automatically adds the `Id` field:

```apex
String query = new QueryBuilder(Account.SObjectType)
    .setWhereClause('Industry = \'Technology\'')
    .getQuery();

// Result: SELECT id FROM Account WHERE Industry = 'Technology'
```

### Complete Example

```apex
public List<Account> getActiveAccountsWithContacts(Set<Id> accountIds) {
    QueryBuilder contactsSubQuery = new QueryBuilder('Contacts')
        .addFields(new List<SObjectField>{
            Contact.FirstName, 
            Contact.LastName, 
            Contact.Email
        })
        .setWhereClause('IsActive__c = true');
    
    String query = new QueryBuilder(Account.SObjectType)
        .addFields(new List<SObjectField>{
            Account.Name,
            Account.Industry,
            Account.BillingCity
        })
        .addSubQuery(contactsSubQuery)
        .setWhereClause('Id IN :accountIds AND IsDeleted = false')
        .setOrderByClause('Name ASC')
        .setPaginationClause('LIMIT 200')
        .withSecurityEnforced()
        .getQuery();
    
    return Database.query(query);
}
```
