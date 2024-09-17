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

    global GetFrom(Map<String, String> mapStringString) {
        theGettable = new GetFromMapStringString(mapStringString);
    }

    global GetFrom(SObject anSObject) {
        this.theGettable = new GetFromSObject(anSObject);
    }

    global GetFrom(Map<String, Object> aJsonObject) {
        this.theGettable = new GetFromJsonObject(aJsonObject);
    }

    global GetFrom(Object anObject) {
        if(anObject instanceof SObjectIndex) {
            this.theGettable = new GetFromSObjectIndex((SObjectIndex) anObject);
        } else if(anObject instanceof SObject) {
            this.theGettable = new GetFromSObject((SObject)anObject);
        } else if (anObject instanceof Map<String, Object>) {
            this.theGettable = new GetFromJsonObject(anObject);
        } else {
            throw new IllegalArgumentException(String.format(
                    'GetFrom constructed with invalid type {0}. Must be SObjectIndex, SObject, or Map<String, Object>',
                    new List<String>{
                            String.valueOf(anObject)
                    })
            );
        }
    }

    global GetFrom(Gettable customGettable) {
        this.theGettable = customGettable;
    }

    global Object call(Object o) {
        return theGettable.get(o);
    }

    global GetFrom setDefaultIfMissing(Object defaultIfMissing) {
        theGettable.setDefaultIfMissing(defaultIfMissing);
        return this;
    }

    private class GetFromSObjectIndex implements Gettable {

        private SObjectIndex theIndex;
        private Object defaultIfMissing = NoResult.NO_RESULT;

        public GetFromSObjectIndex(SObjectIndex theIndex) {
            this.theIndex = theIndex;
        }

        public Gettable setDefaultIfMissing(Object defaultIfMissing) {
            this.defaultIfMissing = defaultIfMissing;
            return this;
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
        private Object defaultIfMissing = NoResult.NO_RESULT;

        public GetFromSObjectMap(Map<Id, SObject> theMap) {
            this.theMap = theMap;
        }

        public Gettable setDefaultIfMissing(Object defaultIfMissing) {
            this.defaultIfMissing = defaultIfMissing;
            return this;
        }

        public Object get(Object key) {
            return theMap.containsKey((Id)key) ? theMap.get((Id)key) : defaultIfMissing;
        }
    }

    private class GetFromMapStringString implements Gettable {

        private Map<String, String> theMap;
        private Object defaultIfMissing = NoResult.NO_RESULT;

        public GetFromMapStringString(Map<String, String> theMap) {
            this.theMap = theMap;
        }

        public Gettable setDefaultIfMissing(Object defaultIfMissing) {
            this.defaultIfMissing = defaultIfMissing;
            return this;
        }

        public Object get(Object key) {
            return theMap.containsKey((String)key) ? theMap.get((String)key) : defaultIfMissing;
        }
    }

    private class GetFromJsonObject implements Gettable {

        private JsonReader jsonReader;

        public GetFromJsonObject(Object jsonObject) {
            this.jsonReader = new JsonReader(jsonObject);
        }

        public Object get(Object key) {
            return jsonReader.read((String)key);
        }

        public Gettable setDefaultIfMissing(Object defaultIfMissing) {
            jsonReader.setMissingKeyResult(defaultIfMissing);
            return this;
        }
    }

    private class GetFromSObject implements Gettable {

        private SObject theSObject;

        public GetFromSObject(SObject theSObject) {
            this.theSObject = theSObject;
        }

        public Gettable setDefaultIfMissing(Object defaultIfMissing) {
            return this;
        }

        public Object get(Object key) {
            return SObjectGetter.get(theSObject, (String)key);
        }
    }
}