/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 * @description For retrieving and caching objects by name. On the first request, your object will be
* queried. On subsequent requests, it will be returned from the cache. So, you can freely call getObject()
* inside a loop (as long as the parameters don't change each time). NamedSObjectCache is particularly useful for
* metadata objects e.g. Record Types, or Case Milestone Types, etc.
*/
global inherited sharing class NamedSObjectCache {

    private static Map<SObjectType, Map<String, SObject>> typeToNameToObject = new Map<SObjectType, Map<String, SObject>>();

    private SObjectType typeName;
    private Map<String, SObject> nameToObject;
    private Set<String> names;
    private String nameFieldName;
    private String andClause;
    private Set<String> extraFields;

    global NamedSObjectCache(SObjectType typeName, String name) {
        this.typeName = typeName;
        this.nameToObject = getNameToObject(typeName);
        this.nameFieldName = 'Name';
        this.names = new Set<String>{name};
        this.extraFields = new Set<String>();
    }

    global NamedSObjectCache setNameField(SObjectField nameField) {
        return setNameField(nameField.getDescribe().getName());
    }

    global NamedSObjectCache setNameField(String nameField) {
        this.nameFieldName = nameField;
        return this;
    }

    global NamedSObjectCache setAndClause(String andClause) {
        this.andClause = andClause;
        return this;
    }

    global NamedSObjectCache setExtraFields(Set<String> extraFields) {
        this.extraFields = extraFields;
        return this;
    }

    global SObject getObject() {
        return getObjects().get(names.iterator().next());
    }

    global Map<String, SObject> getObjects() {
        Map<String, SObject> returnValue = new Map<String, SObject>();
        Set<String> toQuery = populateCachedResultsAndReturnMisses(returnValue);

        if(!toQuery.isEmpty()) {
            extraFields.add(nameFieldName);
            String query = new QueryBuilder(typeName)
                    .addFields(extraFields)
                    .setWhereClause(nameFieldName + ' IN :toQuery' + (andClause != null && andClause != '' ? ' AND (' + andClause  + ')' : ''))
                    .getQuery();

            toQuery.removeAll(writeToCacheAndResultsAndReturnHits(Database.query(query), returnValue));

            for(String name : toQuery) {
                returnValue.put(name, null);
                nameToObject.put(getNameKey(name, andClause), null);
            }
        }

        return returnValue;
    }

    global static RecordType getRecordType(String sObjectType, String developerName) {
        return getRecordType(((SObject)Type.forName(sObjectType).newInstance()).getSObjectType(), developerName);
    }

    global static RecordType getRecordType(SObjectType sObjectType, String developerName) {
        String nameKey = getNameKey(developerName, 'sObjectType = \'' + sObjectType.getDescribe().getName() + '\'');
        Map<String, SObject> cachedRecordTypes = getNameToObject(RecordType.getSObjectType());
        RecordType returnVal = (RecordType)cachedRecordTypes.get(nameKey);
        if(!cachedRecordTypes.containsKey(nameKey)) {
            RecordTypeInfo recordTypeInfo = sObjectType
                    .getDescribe()
                    .getRecordTypeInfosByDeveloperName()
                    .get(developerName);
            if(recordTypeInfo != null) {
                returnVal = new RecordType(
                        Name = recordTypeInfo.getName(),
                        DeveloperName = developerName,
                        Id = recordTypeInfo.getRecordTypeId());
                cachedRecordTypes.put(nameKey, returnVal);
            }
        }
        return returnVal;
    }

    private Set<String> populateCachedResultsAndReturnMisses(Map<String, SObject> returnValue) {
        Set<String> misses = new Set<String>();

        for(String name : names) {
            String nameKey = getNameKey(name, andClause);
            if(!nameToObject.containsKey(nameKey)) {
                misses.add(name);
            } else {
                returnValue.put(name, nameToObject.get(nameKey));
            }
        }
        return misses;
    }

    private Set<String> writeToCacheAndResultsAndReturnHits(List<SObject> objects, Map<String, SObject> returnValue) {
        Set<String> hits = new Set<String>();

        for(SObject obj : objects) {
            String name = (String)obj.get(nameFieldName);
            returnValue.put(name, obj);
            nameToObject.put(getNameKey(name, andClause), obj);
            hits.add(name);
        }

        return hits;
    }

    private static Map<String, SObject> getNameToObject(SObjectType type) {
        Map<String, SObject> nameToObject = typeToNameToObject.get(type);
        if(nameToObject == null) {
            nameToObject = new Map<String, SObject>();

            typeToNameToObject.put(type, nameToObject);
        }
        return nameToObject;
    }

    /**
    * @description Queries using the andClause store values in the cache under a key composed of the name, along with
    * the andClause. This function takes a name and an andClause and returns the key.
    * @param typeName object type
    * @param name name of the instance of an object
    * @param ancClause a string to be included in the query
    *
    * @return the key that would be used in the cache. Being a static method, this just forms the key in a consistent way. It does not say that they key is used
    */
    private static String getNameKey(String name, String andClause) {
        return name + (andClause != null ? andClause : '');
    }
}