/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 * @description For retrieving and caching objects by name. On the first request, your object will be
* queried. On subsequent requests, it will be returned from the cache. So, you can freely call getObject()
* inside a loop (as long as the parameters don't change each time). NamedSObjectCache is particularly useful for
* metadata objects e.g. Record Types, or Case Milestone Types, etc.
*/
global inherited sharing class NamedSObjectCache {

    private static Map<String, Map<String, SObject>> typeToNameToObject = new Map<String, Map<String, SObject>>();

    global static RecordType getRecordType(String sObjectType, String developerName) {
        return getRecordType(((SObject)Type.forName(sObjectType).newInstance()).getSObjectType(), developerName);
    }

    global static RecordType getRecordType(SObjectType sObjectType, String developerName) {
        String nameKey = getNameKey(developerName, 'sObjectType = \'' + sObjectType.getDescribe().getName() + '\'');
        Map<String, SObject> cachedRecordTypes = getNameToObject('RecordType');
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

    private static Map<String, SObject> getNameToObject(String type) {
        Map<String, SObject> nameToObject = typeToNameToObject.get(type);
        if(nameToObject == null) {
            nameToObject = new Map<String, SObject>();

            typeToNameToObject.put(type, nameToObject);
        }
        return nameToObject;
    }
}