## Conversions between SObjects and JSON structures

Nebula Core provides classes for converting between SObjects and JSON representations. This is useful for 
integrations, API responses, and dynamic data manipulation.

### JsonReader

[JsonReader](classes/JsonReader.cls) allows you to read values from a JSON structure using path expressions. It's 
particularly useful when you only need a few values from a large JSON response.

```apex
String jsonString = '{"data": {"items": [{"name": "First"}, {"name": "Second"}]}}';
JsonReader reader = new JsonReader(jsonString);

// Read nested values using path expressions
String firstName = (String)reader.read('data.items[0].name'); // Returns 'First'
String secondName = (String)reader.read('data.items[1].name'); // Returns 'Second'

// Handle missing keys gracefully
reader.setMissingKeyResult('N/A');
String missing = (String)reader.read('data.nonexistent'); // Returns 'N/A'
```

Path expressions support:
- Dot notation for object keys: `data.items`
- Bracket notation for array indices: `items[0]`
- Combined paths: `data.items[0].name`

### JsonObjectToSObject

[JsonObjectToSObject](classes/JsonObjectToSObject.cls) maps JSON data to SObject fields. This is useful when 
receiving data from external APIs and needing to create or update Salesforce records.

```apex
// Define field mappings from JSON keys to SObject field names
Map<String, String> jsonToField = new Map<String, String>{
    'firstName' => 'FirstName',
    'lastName' => 'LastName',
    'emailAddress' => 'Email'
};

JsonObjectToSObject mapper = new JsonObjectToSObject(Contact.SObjectType);
mapper.setObjectFieldToSObjectField(jsonToField);
// Convert JSON to SObject
Map<String, Object> jsonData = new Map<String, Object>{
    'firstName' => 'John',
    'lastName' => 'Smith',
    'emailAddress' => 'john.smith@example.com'
};

Contact newContact = (Contact)mapper.toSObject(jsonData);
// newContact.FirstName = 'John'
// newContact.LastName = 'Smith'  
// newContact.Email = 'john.smith@example.com'
```

The mapper can also work with JSON strings by first deserializing them into a `Map<String, Object>`:

```apex
String jsonString = '{"firstName": "John", "lastName": "Smith"}';
Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
Contact newContact = (Contact)mapper.toSObject(jsonData);
```

### SObjectToJsonObject

[SObjectToJsonObject](classes/SObjectToJsonObject.cls) performs the reverse operation, converting SObjects to 
JSON-compatible Map structures. This is useful for API responses and external integrations.

```apex
// Define field mappings from SObject fields to JSON keys
Map<SObjectField, String> fieldToJson = new Map<SObjectField, String>{
    Contact.FirstName => 'firstName',
    Contact.LastName => 'lastName',
    Contact.Email => 'emailAddress'
};

SObjectToJsonObject mapper = new SObjectToJsonObject(fieldToJson);

Contact existingContact = [SELECT FirstName, LastName, Email FROM Contact LIMIT 1];
Map<String, Object> jsonObject = mapper.toJsonObject(existingContact);

// Convert to JSON string
String jsonString = JSON.serialize(jsonObject);
// {"firstName": "John", "lastName": "Smith", "emailAddress": "john@example.com"}
```

### Related Classes

- [RegexFindIterator](classes/RegexFindIterator.cls) - Used internally by JsonReader to parse path expressions
