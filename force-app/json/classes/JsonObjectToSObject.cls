/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-06
 * @description Converts a typical JSON.deserialize() result into an SObject or SObjects in a configurable way
 */
global class JsonObjectToSObject {

    private Schema.SObjectType objectType;
    private Map<String, Schema.SObjectField> fieldMap;
    private Map<String, String> objectFieldToSObjectField;
    private Map<String, Function> fieldToFunction;
    private Set<String> fieldsToIgnore;

    /**
     * @description Creates a converter for the specified SObjectType
     * @param objectType The SObjectType to convert JSON into
     */
    global JsonObjectToSObject(Schema.SObjectType objectType) {
        this.objectType = objectType;
        this.fieldMap = objectType.getDescribe().fields.getMap();
    }

    /**
     * @description Maps JSON field names to SObject field names
     * @param objectFieldToSObjectField Map of JSON field names to SObject field API names
     * @return This JsonObjectToSObject instance for method chaining
     */
    global JsonObjectToSObject setObjectFieldToSObjectField(Map<String, String> objectFieldToSObjectField) {
        this.objectFieldToSObjectField = new Map<String, String>();

        for(String key : objectFieldToSObjectField.keySet()) {
            this.objectFieldToSObjectField.put(key.toLowerCase(), objectFieldToSObjectField.get(key).toLowerCase());
        }
        return this;
    }

    /**
     * @description Sets custom functions to transform field values during conversion
     * @param fieldToFunction Map of field names to transformation functions
     * @return This JsonObjectToSObject instance for method chaining
     */
    global JsonObjectToSObject setFieldToFunction(Map<String, Function> fieldToFunction) {
        this.fieldToFunction = fieldToFunction;
        return this;
    }

    /**
     * @description Sets fields to ignore during conversion
     * @param fieldsToIgnore Set of field names to skip
     * @return This JsonObjectToSObject instance for method chaining
     */
    global JsonObjectToSObject setFieldsToIgnore(Set<String> fieldsToIgnore) {
        this.fieldsToIgnore = new Set<String>();
        for(String f : fieldsToIgnore) {
            this.fieldsToIgnore.add(f.toLowerCase());
        }
        return this;
    }

    /**
     * @description Converts a list of JSON objects to SObjects
     * @param jsonObjects List of deserialized JSON objects (Maps)
     * @return List of SObjects populated from the JSON
     */
    global List<SObject> toSObjects(List<Object> jsonObjects) {
        List<SObject> returnVal = new List<SObject>();
        for(Object o : jsonObjects) {
            returnVal.add(toSObject((Map<String, Object>)o));
        }
        return returnVal;
    }

    /**
     * @description Converts a single JSON object to an SObject
     * @param jsonObject The deserialized JSON object as a Map
     * @return An SObject populated from the JSON
     */
    global SObject toSObject(Map<String, Object> jsonObject) {
        SObject returnVal = objectType.newSObject();
        return jsonToSobject(jsonObject, returnVal, null);
    }

    private Object applyFieldFunction(String fieldName, Object value) {
        if(fieldToFunction != null) {
            Function thisFunction = fieldToFunction.get(fieldName);
            if(thisFunction != null) {
                return thisFunction.call(value);
            }
        }
        return value;
    }

    // If we are to set Master-Detail fields that cannot be re-parented, we must
    // set the id field last or we will get a runtime exception
    private String idValue = null;
    
    private void handleField(Object value, SObject returnVal, String fieldName) {

        if(fieldsToIgnore != null && fieldsToIgnore.contains(fieldName)) {
            return;
        }

        value = applyFieldFunction(fieldName, value);

        if(value instanceof Map<String, Object>) {
            jsonToSobject((Map<String, Object>) value, returnVal, fieldName);
        } else if(objectFieldToSObjectField != null && objectFieldToSObjectField.containsKey(fieldName)) {
            String fieldNameKey = objectFieldToSObjectField.get(fieldName);

            if(fieldMap.containsKey(fieldNameKey)) {
                returnVal.put(fieldNameKey, value);
            } else {
                fieldNameKey = objectFieldToSObjectField.get(fieldName);

                if(fieldMap.containsKey(fieldNameKey)) {
                    returnVal.put(fieldNameKey, value);
                }
            }
        } else if(fieldName == 'id') {
            idValue = (String) value;
        } else if(fieldMap.containsKey(fieldName)) {
            returnVal.put(fieldName, value);
        } else {
            String fieldNameC = fieldName + '__c';

            if(fieldMap.containsKey(fieldNameC)) {
                returnVal.put(fieldNameC, value);
            }
        }
    }
    
    private SObject jsonToSobject(Map<String, Object> jsonObject, SObject returnVal, String fieldPrefix) {
        idValue = null;
        
        for(String fieldName : jsonObject.keySet()) {
            String normalisedFieldName = ((fieldPrefix != null ? fieldPrefix + '.' : '') + fieldName.replaceAll('-', '_')).toLowerCase();
            handleField(jsonObject.get(fieldName), returnVal, normalisedFieldName);
        }

        if(idValue != null) {
            returnVal.put('Id', idValue);
        }

        return returnVal;
    }
}