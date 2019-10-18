/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 18/10/2019
 * @description Get values from map-like objects e.g. Map, SObjectIndex, SObject
 */

global class Get implements Function {

    private Gettable theGettable;

    global Get(SObjectIndex theIndex) {
        theGettable = new SObjectIndexGet(theIndex);
    }

    global Get(Map<Id, SObject> sObjectMap) {
        theGettable = new SObjectMapGet(sObjectMap);
    }

    global Get(SObject anSObject) {
        this.theGettable = new SObjectGet(anSObject);
    }

    global Get(Gettable customGettable) {
        this.theGettable = customGettable;
    }

    global Object call(Object o) {
        return theGettable.get(o);
    }

    private class SObjectIndexGet implements Gettable {

        private SObjectIndex theIndex;

        public SObjectIndexGet(SObjectIndex theIndex) {
            this.theIndex = theIndex;
        }

        public Object get(Object key) {
            return theIndex.get(key);
        }
    }

    private class SObjectMapGet implements Gettable {

        private Map<Id, SObject> theMap;

        public SObjectMapGet(Map<Id, SObject> theMap) {
            this.theMap = theMap;
        }

        public Object get(Object key) {
            return theMap.get((Id)key);
        }
    }

    private class SObjectGet implements Gettable {

        private SObject theSObject;

        public SObjectGet(SObject theSObject) {
            this.theSObject = theSObject;
        }

        public Object get(Object key) {
            return SObjectGetter.get(theSObject, (String)key);
        }
    }
}