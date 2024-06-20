/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 * @description Allows the retrieval of fields on related objects using calls such as get('Related__r.Field__c') which 
 * are not directly possible on SObject
 */
global class SObjectGetter {
    
    global static Object get(SObject obj, String field) {
        if(field.indexOf('.') > 0) {
            List<String> objectFields = field.split('\\.');

            SObject currentObject = obj;
            Integer currentFieldPosition = 0;

            while(currentFieldPosition < objectFields.size() - 1) {
                currentObject = (SObject)currentObject.getSObject(objectFields[currentFieldPosition++]);
                if(currentObject == null) {
                    return null;
                }
            }
            return currentObject.get(objectFields[currentFieldPosition]);
        } else {
            return obj.get(field);
        }
    }
}