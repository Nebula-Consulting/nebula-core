/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 06/11/2018
 * @description Container for SObject, indexed by one or more of the SObject's fields. Fields can be references to
 * related objects, and a case-insensitive mode is available.
 */

global class SObjectIndex implements SObjectIndexI {

    global SObjectIndex(String fieldName)  {
        this(new List<String>{fieldName}, 0);
    }
    global SObjectIndex(List<String> indexFields)  {
        this(indexFields, 0);
    }
    global SObjectIndex setIsCaseInsensitive(Boolean isCaseInsensitive)  {
        if(!isEmpty()) {
            throw new IllegalStateException(Label.SObjectIndex_Case_Insensitive_Error);
        }
        this.isCaseInsensitive = isCaseInsensitive;
        return this;
    }

    private List<String> allIndexFields;
    private Integer thisIndexDepth;
    private String thisIndexField;
    private Boolean isLastIndexLayer;

    private Map<String, SObjectIndexI> children;
    private Boolean isCaseInsensitive;

    private SObjectIndex(List<String> allIndexFields, Integer fieldDepth) {
        this.thisIndexDepth = fieldDepth;
        this.allIndexFields = allIndexFields;
        this.thisIndexField = allIndexFields[fieldDepth];
        this.isLastIndexLayer = fieldDepth == allIndexFields.size()-1;

        this.children = new Map<String, SObjectIndexI>();
        this.isCaseInsensitive = false;
    }

    global SObjectIndex putAll(List<SObject> newObjects) {
        for(Integer i=0, size = newObjects.size(); i < size; i++) {
            put(newObjects[i]);
        }
        return this;
    }

    global SObjectIndex put(SObject newObj) {
        String key = getKeyFrom(newObj);
        SObjectIndexI thisIndex = children.get(key);

        if(thisIndex == null) {
            if(isLastIndexLayer) {
                thisIndex = new SObjectIndexLeaf();
            } else {
                thisIndex = new SObjectIndex(allIndexFields, thisIndexDepth + 1).setIsCaseInsensitive(isCaseInsensitive);
            }

            children.put(key, thisIndex);
        }

        thisIndex.put(newObj);
        return this;
    }

    /**
    * @description Get a single object in the index where the indexed field is equal to key.
    * @param key a value for the indexed field
    * @return a matching object (if more than one match, it picks the first one in the index,
    * in the same order that they were added). null, if there is no match
    */
    global SObject get(Object key) {
        List<SObject> returnVal = getAll(key);
        return returnVal.isEmpty() ? null : returnVal[0];
    }

    /**
    * @description Get all objects in the index where the indexed field is equal to objVal
    * @param key a value for the indexed field
    * @return a list of matching objects. If there is no match, an empty list is returned
    */
    global List<SObject> getAll(Object key) {
        String keyString = getKeyStringFrom(key);

        SObjectIndexI thisIndex = children.get(keyString);
        if(thisIndex == null) {
            return new List<SObject>();
        } else {
            return thisIndex.values();
        }
    }


    /**
    * @description Get an object in the index which matches the spec object on all indexed fields. Note that a
    * null value for an indexed field in the spec object will only match against null in the index
    * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
    * @return a matching object (if more than one match, it picks the first one in the index,
    * in the same order that they were added). null, if there is no match
    */
    global SObject get(SObject spec) {
        List<SObject> returnVal = getAll(spec);
        return returnVal.isEmpty() ? null : returnVal[0];
    }

    /**
    * @description Get all objects in the index which match the spec object on all indexed fields. Note that a
    * null value for an indexed field in the spec object will only match against null in the index
    * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
    * @return a list of matching objects. If there is no match, an empty list is returned
    */
    global List<SObject> getAll(SObject spec) {
        SObjectIndexI thisIndex = children.get(getKeyFrom(spec));

        if(thisIndex != null) {
            return thisIndex.getAll(spec);
        } else {
            return new List<SObject>();
        }
    }

    /**
    * @description Get all objects in the index which match the spec map on all fields which are both indexed, and also
    * mentioned in the map. Note that the absence of an indexed field in the map means select all values on that field
    * @param spec a map of field names to values
    * @return a list of matching objects. If there is no match, an empty list is returned
    */
    global List<SObject> getAll(Map<String, Object> spec) {
        List<SObject> returnVal = new List<SObject>();

        if(spec.containsKey(thisIndexField)) {
            SObjectIndexI thisIndex = children.get(getKeyStringFrom(spec.get(thisIndexField)));

            if(thisIndex != null) {
                returnVal.addAll(thisIndex.getAll(spec));
            }
        } else {
            List<SObjectIndexI> subIndices = children.values();
            for(Integer i=0, size = subIndices.size(); i < size; i++) {
                returnVal.addAll(subIndices[i].getAll(spec));
            }
        }
        return returnVal;
    }

    global Boolean isEmpty() {
        return children.isEmpty();
    }

    global Set<String> keySet() {
        return children.keySet();
    }

    global Set<String> keySet(String field) {
        if(thisIndexField == field) {
            return children.keySet();
        } else {
            Set<String> returnVal = new Set<String>();

            List<SObjectIndexI> subIndices = children.values();
            for(Integer i=0, size = subIndices.size(); i < size; i++) {
                returnVal.addAll(subIndices[i].keySet(field));
            }

            return returnVal;
        }
    }

    global List<SObject> values() {
        List<SObject> returnVal = new List<SObject>();

        List<SObjectIndexI> subIndices = children.values();
        for(Integer i=0, size = subIndices.size(); i < size; i++) {
            returnVal.addAll(subIndices[i].values());
        }

        return returnVal;
    }

    /**
    * @description SObjectIndex is internally structured as a tree of indexes, with one level for
    * each field that you have indexed on. Given a value on the current top-level, this returns the
    * subtree matching that value
    * @param key a value on the first field indexed in the SObjectIndex
    * @return a SObjectIndex for entries matching val, and indexed on the remainder of the fields after
    * the current top-level. null if there is no match
    */
    global SObjectIndex getSubIndex(Object key) {
        return (SObjectIndex) children.get(getKeyStringFrom(key));
    }

    /**
    * @description Removes some entries from the index, based on the same matching criteria as getAll(sObject spec)
    * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
    * @return a set of Ids of the objects removed, or an empty set if there were no matches
    */
    global Set<Id> remove(SObject spec) {
        SObjectIndexI thisIndex = children.get(getKeyFrom(spec));

        if(thisIndex != null) {
            return thisIndex.remove(spec);
        } else {
            return new Set<Id>();
        }
    }

    /**
    * @description Removes some entries from the index, based on the same matching criteria as getAll(Map<String, Object> spec)
    * @param spec a map of field names to values
    * @return a set of Ids of the objects removed, or an empty set if there were no matches
    */
    global Set<Id> remove(Map<String, Object> spec) {
        Set<Id> returnVal = new Set<Id>();

        if(spec.containsKey(thisIndexField)) {
            SObjectIndexI thisIndex = children.get(getKeyStringFrom(spec.get(thisIndexField)));

            if(thisIndex != null) {
                returnVal.addAll(thisIndex.remove(spec));
            }
        } else {
            List<SObjectIndexI> subIndices = children.values();
            for(Integer i=0, size = subIndices.size(); i < size; i++) {
                returnVal.addAll(subIndices[i].remove(spec));
            }
        }
        return returnVal;
    }

    /**
    * @description Deep clone the index, and the objects inside it. The result is a completely separate
    * SObjectIndex where the entries have had List<sObject>.deepClone(true, true, true) called on them
    * @return a deep clone of the SObjectIndex
    */
    global SObjectIndex deepClone() {
        SObjectIndex returnVal;
        returnVal = new SObjectIndex(thisIndexField);

        for(String key : children.keySet()) {
            returnVal.children.put(key, children.get(key).deepClone());
        }

        return returnVal;
    }

    private String getKeyFrom(SObject obj) {
        String returnVal = String.valueOf(SObjectGetter.get(obj, thisIndexField));
        if(isCaseInsensitive && returnVal != null) {
            return returnVal.toLowerCase();
        } else {
            return returnVal;
        }
    }

    private String getKeyStringFrom(Object key) {
        if(key == null) {
            return null;
        } else {
            String returnVal = key.toString();
            if(isCaseInsensitive) {
                return returnVal.toLowerCase();
            } else {
                return returnVal;
            }
        }
    }
}