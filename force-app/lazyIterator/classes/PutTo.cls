/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/11/2021
 * @description Puts values into map-like objects e.g. Map, SObjectIndex, SObject. Call with a 2-tuple of <key, value>
 */
global class PutTo implements nebc.Function {

    private Puttable target;

    global PutTo(SObject target) {
        this.target = new SObjectPuttable(target);
    }

    global PutTo(Map<String, Object> target) {
        this.target = new JsonObjectPuttable(target);
    }

    global PutTo(Object target) {
        if(target instanceof SObject) {
            this.target = new SObjectPuttable((SObject)target);
        } else if (target instanceof Map<String, Object>) {
            this.target = new JsonObjectPuttable((Map<String, Object>)target);
        } else {
            throw new IllegalArgumentException(String.format(
                    'PutTo constructed with invalid type {0}. Must be SObject, or Map<String, Object>',
                    new List<String>{
                            String.valueOf(target)
                    })
            );
        }
    }

    global Object call(Object o) {
        Tuple keyValue = (Tuple) o;
        target.put((String)keyValue.get(0), keyValue.get(1));
        return keyValue;
    }

    private class SObjectPuttable implements Puttable {

        private SObject target;

        public SObjectPuttable(SObject target) {
            this.target = target;
        }

        @SuppressWarnings('PMD.OneDeclarationPerLine') // OK for optimised loops
        public void put(Object key, Object value) {
            List<String> sObjectFieldPath = ((String)key).split('\\.');

            SObject boxingPosition = target;
            for(Integer i = 0, size = sObjectFieldPath.size() - 1; i < size; i++) {
                SObject newBoxingPosition = boxingPosition.getSObject(sObjectFieldPath[i]);

                if(newBoxingPosition == null) {
                    newBoxingPosition = fieldToNewInstance(boxingPosition, relationToField(sObjectFieldPath[i]));
                    boxingPosition.putSObject(sObjectFieldPath[i], newBoxingPosition);
                }

                boxingPosition = newBoxingPosition;
            }
            boxingPosition.put(sObjectFieldPath[sObjectFieldPath.size() - 1], value);
        }

        private String relationToField(String relation) {
            return relation.contains('__r') ? relation.replace('__r', '__c') : relation + 'Id';
        }

        private SObject fieldToNewInstance(SObject sourceSObject, String field) {
            return sourceSObject.getSObjectType().getDescribe().fields.getMap().get(field).getDescribe().referenceTo[0].newSObject();
        }
    }

    private class JsonObjectPuttable implements Puttable {

        private Map<String, Object> target;

        public JsonObjectPuttable(Map<String, Object> target) {
            this.target = target;
        }

        @SuppressWarnings('PMD.OneDeclarationPerLine') // OK for optimised loops
        public void put(Object key, Object value) {
            List<String> jsonObjectFieldPath = ((String)key).split('\\.');

            Map<String, Object> boxingPosition = target;
            for(Integer i = 0, size = jsonObjectFieldPath.size() - 1; i < size; i++) {
                Map<String, Object> newBoxingPosition = (Map<String, Object>)boxingPosition.get(jsonObjectFieldPath[i]);

                if(newBoxingPosition == null) {
                    newBoxingPosition = new Map<String, Object>();
                    boxingPosition.put(jsonObjectFieldPath[i], newBoxingPosition);
                }
                boxingPosition = newBoxingPosition;
            }
            boxingPosition.put(jsonObjectFieldPath[jsonObjectFieldPath.size() - 1], value);
        }
    }
}