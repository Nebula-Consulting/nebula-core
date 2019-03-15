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

    global JsonObjectToSObject(Schema.SObjectType objectType) {
        this.objectType = objectType;
        this.fieldMap = objectType.getDescribe().fields.getMap();
    }

    global JsonObjectToSObject setObjectFieldToSObjectField(Map<String, String> objectFieldToSObjectField) {
        this.objectFieldToSObjectField = new Map<String, String>();

        for(String key : objectFieldToSObjectField.keySet()) {
            this.objectFieldToSObjectField.put(key.toLowerCase(), objectFieldToSObjectField.get(key).toLowerCase());
        }
        return this;
    }

    global JsonObjectToSObject setFieldToFunction(Map<String, Function> fieldToFunction) {
        this.fieldToFunction = fieldToFunction;
        return this;
    }

    global JsonObjectToSObject setFieldsToIgnore(Set<String> fieldsToIgnore) {
        this.fieldsToIgnore = new Set<String>();
        for(String f : fieldsToIgnore) {
            this.fieldsToIgnore.add(f.toLowerCase());
        }
        return this;
    }

    global List<SObject> toSObjects(List<Object> jsonObjects) {
        List<SObject> returnVal = new List<SObject>();
        for(Object o : jsonObjects) {
            returnVal.add(toSObject((Map<String, Object>)o));
        }
        return returnVal;
    }

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

        if(objectFieldToSObjectField != null) {
            String fieldNameKey = objectFieldToSObjectField.get(fieldName);

            if(fieldMap.containsKey(fieldNameKey)) {
                returnVal.put(fieldNameKey, value);
            } else {
                fieldNameKey = objectFieldToSObjectField.get(fieldName);

                if(fieldMap.containsKey(fieldNameKey)) {
                    returnVal.put(fieldNameKey, value);
                }
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