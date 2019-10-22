/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 18/10/2019
 * @description Get values from map-like objects e.g. Map, SObjectIndex, SObject
 */

global class GetFrom implements Function {

    private Gettable theGettable;

    global GetFrom(SObjectIndex theIndex) {
        theGettable = new GetFromSObjectIndex(theIndex);
    }

    global GetFrom(Map<Id, SObject> sObjectMap) {
        theGettable = new GetFromSObjectMap(sObjectMap);
    }

    global GetFrom(SObject anSObject) {
        this.theGettable = new GetFromSObject(anSObject);
    }

    global GetFrom(Gettable customGettable) {
        this.theGettable = customGettable;
    }

    global Object call(Object o) {
        return theGettable.get(o);
    }

    private class GetFromSObjectIndex implements Gettable {

        private SObjectIndex theIndex;

        public GetFromSObjectIndex(SObjectIndex theIndex) {
            this.theIndex = theIndex;
        }

        public Object get(Object key) {
            return theIndex.get(key);
        }
    }

    private class GetFromSObjectMap implements Gettable {

        private Map<Id, SObject> theMap;

        public GetFromSObjectMap(Map<Id, SObject> theMap) {
            this.theMap = theMap;
        }

        public Object get(Object key) {
            return theMap.get((Id)key);
        }
    }

    private class GetFromSObject implements Gettable {

        private SObject theSObject;

        public GetFromSObject(SObject theSObject) {
            this.theSObject = theSObject;
        }

        public Object get(Object key) {
            return SObjectGetter.get(theSObject, (String)key);
        }
    }
}