/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 06/11/2018
 * @description Container for SObjects, indexed by one or more of the SObject's fields. Fields can be references to
 * related objects, and a case-insensitive mode is available.
 */
global class SObjectIndex implements SObjectIndexI, Container {

    /**
     * @description Creates an index on a single field by field name
     * @param fieldName The field API name to index on
     */
    global SObjectIndex(String fieldName)  {
        this(new List<String>{fieldName}, 0);
    }

    /**
     * @description Creates an index on two fields by field names
     * @param fieldName1 The first field API name to index on
     * @param fieldName2 The second field API name to index on
     */
    global SObjectIndex(String fieldName1, String fieldName2)  {
        this(new List<String>{fieldName1, fieldName2}, 0);
    }

    /**
     * @description Creates an index on three fields by field names
     * @param fieldName1 The first field API name to index on
     * @param fieldName2 The second field API name to index on
     * @param fieldName3 The third field API name to index on
     */
    global SObjectIndex(String fieldName1, String fieldName2, String fieldName3)  {
        this(new List<String>{fieldName1, fieldName2, fieldName3}, 0);
    }

    /**
     * @description Creates an index on a single field by SObjectField token
     * @param field The SObjectField to index on
     */
    global SObjectIndex(SObjectField field)  {
        this(new List<String>{field.getDescribe().getName()}, 0);
    }

    /**
     * @description Creates an index on two fields by SObjectField tokens
     * @param field1 The first SObjectField to index on
     * @param field2 The second SObjectField to index on
     */
    global SObjectIndex(SObjectField field1, SObjectField field2)  {
        this(new List<String>{field1.getDescribe().getName(), field2.getDescribe().getName()}, 0);
    }

    /**
     * @description Creates an index on three fields by SObjectField tokens
     * @param field1 The first SObjectField to index on
     * @param field2 The second SObjectField to index on
     * @param field3 The third SObjectField to index on
     */
    global SObjectIndex(SObjectField field1, SObjectField field2, SObjectField field3)  {
        this(new List<String>{field1.getDescribe().getName(), field2.getDescribe().getName(), field3.getDescribe().getName()}, 0);
    }

    /**
     * @description Creates an index with the given list of field names
     * @param indexFields List of field API names to index on
     */
    global SObjectIndex(List<String> indexFields)  {
        this(indexFields, 0);
    }

    /**
     * @description Sets whether the index should be case-insensitive for string comparisons
     * @param isCaseInsensitive True for case-insensitive, false for case-sensitive
     * @return This SObjectIndex instance for method chaining
     */
    global SObjectIndex setIsCaseInsensitive(Boolean isCaseInsensitive)  {
        if(isCaseInsensitive) {
            return setKeyFunction(new StringLowerCaseFunction());
        } else {
            return setKeyFunction(new IdentityFunction());
        }
    }

    /**
     * @description Sets a custom key function for transforming index keys
     * @param keyFunction Function to apply to keys during indexing and lookup
     * @return This SObjectIndex instance for method chaining
     */
    global SObjectIndex setKeyFunction(Function keyFunction) {
        if(!isEmpty()) {
            throw new IllegalStateException(Label.SObjectIndex_Case_Insensitive_Error);
        } else {
            this.keyFunction = keyFunction;
        }
        return this;
    }

    private final List<String> allIndexFields;
    private final Integer thisIndexDepth;
    private final String thisIndexField;
    private final Boolean isLastIndexLayer;
    private Function keyFunction;

    private Map<Object, SObjectIndexI> children;

    private SObjectIndex(List<String> allIndexFields, Integer fieldDepth) {
        this.thisIndexDepth = fieldDepth;
        this.allIndexFields = allIndexFields;
        this.thisIndexField = allIndexFields[fieldDepth];
        this.isLastIndexLayer = fieldDepth == allIndexFields.size()-1;

        this.keyFunction = new IdentityFunction();
        this.children = new Map<Object, SObjectIndexI>();
    }

    /**
     * @description Adds a list of SObjects to the index
     * @param newObjects List of SObjects to add to the index
     * @return This SObjectIndex instance for method chaining
     */
    global SObjectIndex putAll(List<SObject> newObjects) {
        for(Integer i=0, size = newObjects.size(); i < size; i++) {
            put(newObjects[i]);
        }
        return this;
    }

    /**
     * @description Adds SObjects from an iterator to the index
     * @param iterator Iterator of SObjects to add to the index
     * @return This SObjectIndex instance for method chaining
     */
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

    /**
     * @description Adds a single SObject to the index
     * @param newObj The SObject to add to the index
     * @return This SObjectIndex instance for method chaining
     */
    global SObjectIndex put(SObject newObj) {
        getOrCreateIndexFor(getKeyFrom(newObj)).put(newObj);
        return this;
    }

    /**
     * @description Checks if the index contains a matching entry
     * @param o Either a Map of field names to values, an SObject, or a key value
     * @return True if a match is found, false otherwise
     */
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
        SObjectIndexI thisIndex = children.get(keyFunction.call(key));
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

    /**
     * @description Returns the set of keys at the current index level
     * @return Set of Object keys
     */
    global Set<Object> keySet() {
        return children.keySet();
    }

    /**
     * @description Fills a set with Id keys from the index
     * @param toFill Set to fill with Id keys
     * @return The filled set
     */
    global Set<Id> keySet(Set<Id> toFill) {
        for(Object key : children.keySet()) {
            toFill.add((Id)key);
        }
        return toFill;
    }

    /**
     * @description Returns an iterator over the keys at the current index level
     * @return Iterator of Object keys
     */
    global Iterator<Object> keyIterator() {
        return children.keySet().iterator();
    }

    /**
     * @description Fills a list with keys from the index
     * @param toFill List to fill with keys
     * @return The filled list
     */
    global List<Object> keyList(List<Object> toFill) {
        toFill.addAll(children.keySet());
        return toFill;
    }

    /**
     * @description Returns keys for a specific field in the index
     * @param field The field name to get keys for
     * @return Set of keys for the specified field
     */
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

    /**
     * @description Returns all SObjects in the index
     * @return List of all SObjects in the index
     */
    global List<SObject> values() {
        List<SObject> values = new List<SObject>();

        List<SObjectIndexI> subIndices = children.values();
        for(Integer i=0, size = subIndices.size(); i < size; i++) {
            values.addAll(subIndices[i].values());
        }

        return values;
    }

    /**
     * @description Returns an iterator over all SObjects in the index
     * @return Iterator of SObjects
     */
    global Iterator<Object> valueIterator() {
        Object iterator = values().iterator();
        return (Iterator<Object>)iterator;
    }

    /**
     * @description SObjectIndex is internally structured as a tree of indexes, with one level for
     * each field that you have indexed on. Given a value on the current top-level, this returns the
     * subtree matching that value
     * @param key A value on the first field indexed in the SObjectIndex
     * @return A SObjectIndex for entries matching key, and indexed on the remainder of the fields after
     * the current top-level. Null if there is no match
     */
    global SObjectIndex getSubIndex(Object key) {
        return (SObjectIndex)children.get(keyFunction.call(key));
    }

    /**
    * @description Removes some entries from the index, based on the same matching criteria as getAll(SObject spec)
    * @param spec An SObject which has all of the indexed fields (not necessarily the same object as stored in the index)
    * @return The list of objects removed, or an empty list if there were no matches
    */
    global List<SObject> remove(SObject spec) {
        SObjectIndexI thisIndex = children.get(getKeyFrom(spec));
        return thisIndex != null ? thisIndex.remove(spec) : new List<SObject>();
    }

    /**
    * @description Removes some entries from the index, based on the same matching criteria as getAll(Map<String, Object> spec)
    * @param spec A map of field names to values
    * @return The list of objects removed, or an empty list if there were no matches
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
        return keyFunction.call(SObjectGetter.get(obj, thisIndexField));
    }

    private Object getKeyFrom(Map<String, Object> aMap) {
        return keyFunction.call(aMap.get(thisIndexField));
    }
}