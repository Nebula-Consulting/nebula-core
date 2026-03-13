/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 06/11/2018
 * @description Container for SObjects, indexed by one or more of the SObject's fields. Fields can be references to
 * related objects, and a case-insensitive mode is available.
 */
global class SObjectIndex implements SObjectIndexI, Container {

    global SObjectIndex(String fieldName)  {
        this(new List<String>{fieldName}, 0);
    }

    global SObjectIndex(String fieldName1, String fieldName2)  {
        this(new List<String>{fieldName1, fieldName2}, 0);
    }

    global SObjectIndex(String fieldName1, String fieldName2, String fieldName3)  {
        this(new List<String>{fieldName1, fieldName2, fieldName3}, 0);
    }

    global SObjectIndex(SObjectField field)  {
        this(new List<String>{field.getDescribe().getName()}, 0);
    }

    global SObjectIndex(SObjectField field1, SObjectField field2)  {
        this(new List<String>{field1.getDescribe().getName(), field2.getDescribe().getName()}, 0);
    }

    global SObjectIndex(SObjectField field1, SObjectField field2, SObjectField field3)  {
        this(new List<String>{field1.getDescribe().getName(), field2.getDescribe().getName(), field3.getDescribe().getName()}, 0);
    }



    global SObjectIndex(List<String> indexFields)  {
        this(indexFields, 0);
    }

    global SObjectIndex setIsCaseInsensitive(Boolean isCaseInsensitive)  {
        if(isCaseInsensitive) {
            return setKeyFunction(new StringLowerCaseFunction());
        } else {
            return setKeyFunction(new IdentityFunction());
        }
    }

    global SObjectIndex setKeyFunction(Function keyFunction) {
        if(!isEmpty()) {
            throw new IllegalStateException(Label.SObjectIndex_Case_Insensitive_Error);
        } else {
            this.keyFunction = keyFunction;
        }
        return this;
    }

    /**
     * @param normalizeKeys If true, then when putting or getting objects in the index, any Date, Datetime, or Time values on indexed fields will be converted to Strings first. This is to work around the fact that Salesforce's Map implementation does not consider two Date, Datetime, or Time instances with the same value to be equal keys, which can lead to unintuitive behavior in the index. Enabling this option will mean that such values are treated as equal keys in the index. Note that this only affects the keys in the index - the actual SObjects stored in the index will still have their Date, Datetime, and Time fields stored as their original types.
     *
     * @return SObjectIndex class
     */
    global SObjectIndex setNormalizeKeys(Boolean normalizeKeys) {
        this.normalizeKeys = normalizeKeys;
        return this;
    }

    private final List<String> allIndexFields;
    private final Integer thisIndexDepth;
    private final String thisIndexField;
    private final Boolean isLastIndexLayer;
    private Function keyFunction;
    private Boolean normalizeKeys = false;
    private Map<Object, SObjectIndexI> children;

    private SObjectIndex(List<String> allIndexFields, Integer fieldDepth) {
        this.thisIndexDepth = fieldDepth;
        this.allIndexFields = allIndexFields;
        this.thisIndexField = allIndexFields[fieldDepth];
        this.isLastIndexLayer = fieldDepth == allIndexFields.size()-1;

        this.keyFunction = new IdentityFunction();
        this.children = new Map<Object, SObjectIndexI>();
    }

    global SObjectIndex putAll(List<SObject> newObjects) {
        for(Integer i=0, size = newObjects.size(); i < size; i++) {
            put(newObjects[i]);
        }
        return this;
    }

    global SObjectIndex putAll(Iterator<Object> iterator) {
        while(iterator.hasNext()) {
            put((SObject)iterator.next());
        }
        return this;
    }

    private SObjectIndexI getOrCreateIndexFor(Object key) {
        SObjectIndexI existingIndex = children.get(key);
        if(existingIndex != null) {
            return existingIndex;
        }

        SObjectIndexI newIndex;
        if(isLastIndexLayer) {
            newIndex = new SObjectIndexLeaf();
        } else {
            newIndex = new SObjectIndex(allIndexFields, thisIndexDepth + 1).setKeyFunction(keyFunction);
        }

        children.put(key, newIndex);
        return newIndex;
    }

    global SObjectIndex put(SObject newObj) {
        getOrCreateIndexFor(getKeyFrom(newObj)).put(newObj);
        return this;
    }

    global Boolean contains(Object o) {
        if(o instanceof Map<String, Object>) {
            return get((Map<String, Object>)o) != null;
        } else if(o instanceof SObject) {
            return get((SObject)o) != null;
        } else {
            return get(o) != null;
        }
    }

    /**
    * @description Get a single object in the index, according to getAll(Map<String, Object> spec)
    * @param spec a map of field names to values
    * @return a matching object (if more than one match, it picks the first one in the index,
    * in the same order that they were added). null, if there is no match
    */
    global SObject get(Map<String, Object> spec) {
        List<SObject> returnVal = getAll(spec);
        return returnVal.isEmpty() ? null : returnVal[0];
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
        SObjectIndexI thisIndex = children.get(keyFunction.call(normalizeValue(key)));
        return thisIndex == null ? new List<SObject>() : thisIndex.values();
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
        return thisIndex != null ? thisIndex.getAll(spec) : new List<SObject>();
    }

    /**
    * @description Get all objects in the index which match the spec map on all fields which are both indexed, and also
    * mentioned in the map. Note that the absence of an indexed field in the map means select all values on that field
    * @param spec a map of field names to values
    * @return a list of matching objects. If there is no match, an empty list is returned
    */
    global List<SObject> getAll(Map<String, Object> spec) {
        if(spec.containsKey(thisIndexField)) {
            SObjectIndexI thisIndex = children.get(getKeyFrom(spec));
            return thisIndex != null ? thisIndex.getAll(spec) : new List<SObject>();
        } else {
            List<SObjectIndexI> subIndices = children.values();
            List<SObject> returnVal = new List<SObject>();
            for(Integer i=0, size = subIndices.size(); i < size; i++) {
                returnVal.addAll(subIndices[i].getAll(spec));
            }
            return returnVal;
        }
    }

    global Boolean isEmpty() {
        return children.isEmpty();
    }

    global Set<Object> keySet() {
        return children.keySet();
    }

    global Set<Id> keySet(Set<Id> toFill) {
        for(Object key : children.keySet()) {
            toFill.add((Id)key);
        }
        return toFill;
    }

    global Iterator<Object> keyIterator() {
        return children.keySet().iterator();
    }

    global List<Object> keyList(List<Object> toFill) {
        toFill.addAll(children.keySet());
        return toFill;
    }

    global Set<Object> keySet(String field) {
        if(thisIndexField == field) {
            return children.keySet();
        } else {
            Set<Object> keySet = new Set<Object>();

            List<SObjectIndexI> subIndices = children.values();
            for(Integer i=0, size = subIndices.size(); i < size; i++) {
                keySet.addAll(subIndices[i].keySet(field));
            }

            return keySet;
        }
    }

    global List<SObject> values() {
        List<SObject> values = new List<SObject>();

        List<SObjectIndexI> subIndices = children.values();
        for(Integer i=0, size = subIndices.size(); i < size; i++) {
            values.addAll(subIndices[i].values());
        }

        return values;
    }

    global Iterator<Object> valueIterator() {
        Object iterator = values().iterator();
        return (Iterator<Object>)iterator;
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
        return (SObjectIndex)children.get(keyFunction.call(normalizeValue(key)));
    }

    /**
    * @description Removes some entries from the index, based on the same matching criteria as getAll(sObject spec)
    * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
    * @return the list of objects removed, or an empty list if there were no matches
    */
    global List<SObject> remove(SObject spec) {
        SObjectIndexI thisIndex = children.get(getKeyFrom(spec));
        return thisIndex != null ? thisIndex.remove(spec) : new List<SObject>();
    }

    /**
    * @description Removes some entries from the index, based on the same matching criteria as getAll(Map<String, Object> spec)
    * @param spec a map of field names to values
    * @return the list of objects removed, or an empty list if there were no matches
    */
    global List<SObject> remove(Map<String, Object> spec) {
        if(spec.containsKey(thisIndexField)) {
            SObjectIndexI thisIndex = children.get(getKeyFrom(spec));
            return thisIndex != null ? thisIndex.remove(spec) : new List<SObject>();
        } else {
            List<SObject> removedValues = new List<SObject>();
            List<SObjectIndexI> subIndices = children.values();
            for(Integer i=0, size = subIndices.size(); i < size; i++) {
                removedValues.addAll(subIndices[i].remove(spec));
            }
            return removedValues;
        }
    }

    private Object getKeyFrom(SObject obj) {
        return keyFunction.call(normalizeValue(SObjectGetter.get(obj, thisIndexField)));
    }

    private Object getKeyFrom(Map<String, Object> aMap) {
        return keyFunction.call(normalizeValue(aMap.get(thisIndexField)));
    }

    private Object normalizeValue(Object value) {
        if (normalizeKeys == false) {
            return value;
        }
        if (value instanceof Date) {
            return String.valueOf((Date)value);
        } else if (value instanceof Datetime) {
            return String.valueOf((Datetime)value);
        } else if (value instanceof Time) {
            return String.valueOf((Time)value);
        }
        return value;
    }
}