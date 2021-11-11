/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/11/2021
 * @description Puts values into map-like objects e.g. Map, SObjectIndex, SObject. Call with a 2-tuple of <key, value>
 */

public class PutTo implements nebc.Function {

    private Puttable target;

    public PutTo(SObject target) {
        this.target = new SObjectPuttable(target);
    }

    public PutTo(Map<String, Object> target) {
        this.target = new JsonObjectPuttable(target);
    }

    public Object call(Object o) {
        Tuple keyValue = (Tuple) o;
        target.put((String)keyValue.get(0), keyValue.get(1));
        return keyValue;
    }

    private class SObjectPuttable implements Puttable {

        private SObject target;

        public SObjectPuttable(SObject target) {
            this.target = target;
        }

        public void put(Object key, Object value) {
            target.put((String)key, value);
        }
    }

    private class JsonObjectPuttable implements Puttable {

        private Map<String, Object> target;

        public JsonObjectPuttable(Map<String, Object> target) {
            this.target = target;
        }

        public void put(Object key, Object value) {
            List<String> jsonObjectFieldPath = ((String)key).split('\\.');

            Map<String, Object> boxingPosition = target;
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
}