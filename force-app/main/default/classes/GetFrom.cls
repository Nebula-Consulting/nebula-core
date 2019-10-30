/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 18/10/2019
 * @description Get values from map-like objects e.g. Map, SObjectIndex, SObject
 */

global class GetFrom implements Function {

    private Gettable theGettable;

    global GetFrom(SObjectIndex theIndex) {
        this(theIndex, NoResult.NO_RESULT);
    }

    global GetFrom(SObjectIndex theIndex, Object defaultIfMissing) {
        theGettable = new GetFromSObjectIndex(theIndex, defaultIfMissing);
    }

    global GetFrom(Map<Id, SObject> sObjectMap) {
        this(sObjectMap, NoResult.NO_RESULT);
    }

    global GetFrom(Map<Id, SObject> sObjectMap, Object defaultIfMissing) {
        theGettable = new GetFromSObjectMap(sObjectMap, defaultIfMissing);
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
        private Object defaultIfMissing;

        public GetFromSObjectIndex(SObjectIndex theIndex, Object defaultIfMissing) {
            this.theIndex = theIndex;
            this.defaultIfMissing = defaultIfMissing;
        }

        public Object get(Object key) {
            List<SObject> results = theIndex.getAll(key);
            if(results.isEmpty()) {
                return defaultIfMissing;
            } else {
                return results[0];
            }
        }
    }

    private class GetFromSObjectMap implements Gettable {

        private Map<Id, SObject> theMap;
        private Object defaultIfMissing;

        public GetFromSObjectMap(Map<Id, SObject> theMap, Object defaultIfMissing) {
            this.theMap = theMap;
            this.defaultIfMissing = defaultIfMissing;
        }

        public Object get(Object key) {
            return theMap.containsKey((Id)key) ? theMap.get((Id)key) : defaultIfMissing;
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