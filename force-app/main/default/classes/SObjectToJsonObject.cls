/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-06
 * @description Converts an SObject to a Map<String, Object>, as typically sent to JSON.serialize()
 */

global class SObjectToJsonObject {

    private Map<String, String> sObjectFieldToJsonObjectField;
    private Map<String, Function> fieldNameToFunction;
    private Boolean skipNulls;

    global SObjectToJsonObject(Map<String, String> sObjectFieldToJsonObjectField) {
        this.sObjectFieldToJsonObjectField = sObjectFieldToJsonObjectField;
        this.skipNulls = false;
    }

    global SObjectToJsonObject setFieldNameToFunction(Map<String, Function> fieldNameToFunction) {
        this.fieldNameToFunction = fieldNameToFunction;
        return this;
    }

    global SObjectToJsonObject setSkipNulls(Boolean skipNulls) {
        this.skipNulls = skipNulls;
        return this;
    }

    global Map<String, Object> toJsonObject(SObject sObjectToConvert) {
        Map<String, Object> returnVal = new Map<String, Object>();

        for(String sObjectField : sObjectFieldToJsonObjectField.keySet()) {
            Object value = SObjectGetter.get(sObjectToConvert, sObjectField);
            if(!(skipNulls && value == null)) {
                Function fieldFunction = fieldNameToFunction == null ? null : fieldNameToFunction.get(sObjectField);
                if(fieldFunction != null) {
                    value = fieldFunction.call(value);
                }

                List<String> jsonObjectFieldPath = sObjectFieldToJsonObjectField.get(sObjectField).split('\\.');

                Map<String, Object> boxingPosition = returnVal;
                for(Integer i=0; i < jsonObjectFieldPath.size(); i++) {
                    if(i == jsonObjectFieldPath.size() - 1) {
                        boxingPosition.put(jsonObjectFieldPath[i], value);
                    } else {
                        Map<String, Object> newBoxingPosition = (Map<String, Object>)boxingPosition.get(jsonObjectFieldPath[i]);

                        if(newBoxingPosition == null) {
                            newBoxingPosition = new Map<String, Object>();
                            boxingPosition.put(jsonObjectFieldPath[i], newBoxingPosition);
                        }
                        boxingPosition = newBoxingPosition;
                    }
                }
            }
        }
        return returnVal;
    }
}