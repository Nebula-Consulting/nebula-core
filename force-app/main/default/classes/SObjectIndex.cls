/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 06/11/2018
 * @description (if required)
 */

global class SObjectIndex implements SObjectIndexI {

    global SObjectIndex(String fieldName)  {
        this(new List<String>{fieldName});
    }
    global SObjectIndex(List<String> indexFields)  {
        this(indexFields, 0);
    }
    global SObjectIndex setData(List<SObject> data)  {
        putAll(data);
        return this;
    }
    global SObjectIndex setIsCaseInsensitive(Boolean isCaseInsensitive)  {
        this.isCaseInsensitive = isCaseInsensitive;
        return this;
    }

    global class SObjectIndexException extends Exception {

    }

    private List<String> fieldOrder {get; set{
        fieldOrder = value;
        fieldOrderSize = fieldOrder.size();
        isLeaf = fieldDepth >= fieldOrderSize;
    }}

    private Integer fieldOrderSize;
    private Integer fieldDepth;

    private Map<String, SObjectIndexI> index;
    private List<SObject> objects;
    private Set<Id> ids;
    private Boolean isLeaf {get; set {
        isLeaf = value;
        if(isLeaf) {
            objects = new List<SObject>();
        }
    }}
    
    private Boolean isCaseInsensitive;
    
    private SObjectIndex(List<String> indexFields, Integer fieldDepth) {
        this.fieldDepth = fieldDepth;
        this.fieldOrder = indexFields;
        this.index = new Map<String, SObjectIndex>();
        this.ids = new Set<Id>();
        this.isCaseInsensitive = false;
    }

    private void doPut(SObject newObj, String val) {
        SObjectIndex thisIndex = index.get(val);

        if(thisIndex == null) {
            thisIndex = new SObjectIndex(fieldOrder, fieldDepth + 1).setIsCaseInsensitive(isCaseInsensitive);

            index.put(val, thisIndex);
        }

        thisIndex.put(newObj);
    }

    /**
    * @description put a list of objects into the index, all at once
    * @param newObjects some objects which have the fields you are indexing on
    * @example
    * contactsByAccountAndCountry.putAll([SELECT Id, AccountId, MailingCountry, Name FROM Contact]);
    */
    global SObjectIndex putAll(List<SObject> newObjects) {
        for(Integer i=0, size = newObjects.size(); i < size; i++) {
            put(newObjects[i]);
        }
        return this;
    }

    /**
    * @description get the Ids of every object in the index
    * @example
    * Nebula_Tools.SObjectIndex accountsByCountry = new Nebula_Tools.SObjectIndex('BillingCountry');
    * // Populate the accountsByCountry somehow
    * List<Contact> relatedContacts = [SELECT Id, Name FROM Contact WHERE AccountId IN :accountsByCountry.getIds()];
    */
    global Set<Id> getIds() {
        return ids;
    }

    /**
    * @description put an object into the index
    * @param newObj an object which has the fields you are indexing on
    * @example
    * contactsByAccountAndCountry.put(myContact);
    */
    global void put(SObject newObj) {
        if(newObj.Id != null) {
            ids.add(newObj.Id);
        }
        if(isLeaf) {
            objects.add(newObj);
        } else {
            String val = getValue(newObj);

            doPut(newObj, val);
        }
    }

    private String getValue(SObject obj) {
        String returnVal = SObjectGetter.getString(obj, fieldOrder[fieldDepth]);
        if(isCaseInsensitive && returnVal != null) {
            return returnVal.toLowerCase();
        } else {
            return returnVal;
        }
    }

    /**
    * @description Get a single object in the index where the indexed field is equal to objVal.
    * Only applicable to indexes on a single field (throws SObjectIndexException if called on index with more fields)
    * @param objVal a value for the indexed field
    * @return a matching object (if more than one match, it picks the first one in the index,
    * in the same order that they were added). null, if there is no match
    * @example
    * Contact ukContact = (Contact)contactsByCountry.get('United Kingdom');
    */
    global SObject get(Object objVal) {
        List<SObject> returnVal = getAll(objVal);
        return returnVal.isEmpty() ? null : returnVal[0];
    }

    /**
    * @description Get all objects in the index where the indexed field is equal to objVal
    * Only applicable to indexes on a single field (throws SObjectIndexException if called on index with more fields)
    * @param objVal a value for the indexed field
    * @return a list of matching objects. If there is no match, an empty list is returned
    * @example
    * List<Contact> ukContacts = contactsByCountry.getAll('United Kingdom');
    */
    global List<SObject> getAll(Object objVal) {
        if(isLeaf) {
            return objects;
        } else {
            String val;
            if(objVal != null) {
                val = '' + objVal;
                if(isCaseInsensitive) {
                    val = val.toLowerCase();
                }
            }

            SObjectIndex thisIndex = index.get(val);
            if(thisIndex == null) {
                return new List<SObject>();
            } else if(thisIndex.fieldDepth < thisIndex.fieldOrderSize) {
                throw new SObjectIndexException('SObjectIndex: must call getAll(objVal) on an index with depth 0 or 1');
            } else {
                return thisIndex.objects;
            }
        }
    }


    /**
    * @description Get an object in the index which matches the spec object on all indexed fields. Note that a
    * null value for an indexed field in the spec object will only match against null in the index
    * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
    * @return a matching object (if more than one match, it picks the first one in the index,
    * in the same order that they were added). null, if there is no match
    * @example
    *
    * Contact aContact = [SELECT Id FROM Contact WHERE some_condition];
    * Nebula_Tools.SObjectIndex existingCases =
    *     new Nebula_Tools.SObjectIndex(new List<String> {'Subject', 'ContactId'},
    *                                   [select relevant existing Cases somehow]);
    * Case newCase = new Case(Subject = 'Bug in SObjectIndex', ContactId = aContact.Id);
    *
    * if(existingCases.get(newCase) == null) {
    *     insert newCase;
    * }
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
    * @example
    *
    * Contact aContact = [SELECT Id, AccountId FROM Contact WHERE some_condition];
    * Nebula_Tools.SObjectIndex existingCases =
    *     new Nebula_Tools.SObjectIndex('AccountId',
    *                                   [select relevant existing Cases somehow]);
    * List<Case> casesFromSameAccount = existingCases.getAll(aContact);
    */
    global List<SObject> getAll(SObject spec) {
        if(isLeaf) {
            return objects;
        } else {
            String val = getValue(spec);
            SObjectIndex thisIndex = index.get(val);
            List<SObject> returnVal = new List<SObject>();

            if(thisIndex != null) {
                returnVal.addAll(thisIndex.getAll(spec));
            }

            return returnVal;
        }

    }

    /**
    * @description Get all objects in the index which match the spec map on all fields which are both indexed, and also
    * mentioned in the map. Note that the absence of an indexed field in the map means select all values on that field
    * @param spec a map of field names to values
    * @return a list of matching objects. If there is no match, an empty list is returned
    * @example
    *
    * Account acc = [SELECT Id FROM Account LIMIT 1];
    *
    * SObjectIndex theIndex = new SObjectIndex(new List<String>{'AccountId', 'LastName'},
    *                                          new List<Contact> { new Contact(AccountId = null, FirstName = 'John', LastName = 'Doe'),
    *                                              new Contact(AccountId = acc.id, FirstName = 'Jane', LastName = 'Doe'),
    *                                              new Contact(AccountId = acc.id, FirstName = 'Fred', LastName = 'Deer')
    *                                              });
    *
    * List<Contact> fetchedContacts = theIndex.getAll(new Map<String, Object>{'LastName' => 'Doe'});
    * System.assertEquals(2, fetchedContacts.size());
    * System.assert(fetchedContacts[0].AccountId == null);
    * System.assert(fetchedContacts[1].AccountId == acc.id);
    * System.assert(fetchedContacts[0].FirstName == 'John');
    * System.assert(fetchedContacts[1].FirstName == 'Jane');
    * System.assertEquals('Doe', fetchedContacts[0].LastName);
    * System.assertEquals('Doe', fetchedContacts[1].LastName);
    */
    global List<SObject> getAll(Map<String, Object> spec) {
        if(isLeaf) {
            return objects;
        } else {
            List<SObject> returnVal = new List<SObject>();

            if(spec.containsKey(fieldOrder[fieldDepth])) {
                Object objVal = spec.get(fieldOrder[fieldDepth]);
                String val = objVal == null ? null : '' + objVal;
                if(val != null && isCaseInsensitive) {
                    val = val.toLowerCase();
                }

                SObjectIndex thisIndex = index.get(val);

                if(thisIndex != null) {
                    returnVal.addAll(thisIndex.getAll(spec));
                }
            } else {
                List<SObjectIndex> subIndices = index.values();
                for(Integer i=0, size = subIndices.size(); i < size; i++) {
                    returnVal.addAll(subIndices[i].getAll(spec));
                }
            }
            return returnVal;
        }

    }

    /**
    * @description Is the index empty
    * @return true if the index is empty
    */
    global Boolean isEmpty() {
        return index.isEmpty();
    }

    /**
    * @description Get the all of the values for indexed objects on the indexed field
    * Only applicable to indexes on a single field (throws SObjectIndexException if called on index with more fields)
    * @return a set of String representations of the values
    * @example
    * Nebula_Tools.SObjectIndex theIndex = new Nebula_Tools.SObjectIndex('AccountId');
    *
    * Account acc = [SELECT Id FROM Account LIMIT 1];
    *
    * theIndex.put(new Contact(AccountId = acc.id, FirstName = 'John', LastName = 'Doe'));
    * theIndex.put(new Contact(AccountId = acc.id, FirstName = 'Jane', LastName = 'Doe2'));
    *
    * Set<String> ks = theIndex.keySet();
    * System.assertEquals(1, ks.size());
    * System.assert(ks.contains(acc.id));
    */
    global Set<String> keySet() {
        if(fieldDepth != fieldOrderSize - 1) {
            throw new SObjectIndexException('SObjectIndex: must call keySet() on an index with depth 1');
        } else {
            return index.keySet();
        }
    }

    /**
    * @description Get the all of the values for indexed objects on the indexed field, convert them to Ids
    * Only applicable to indexes on a single field (throws SObjectIndexException if called on index with more fields)
    * @return a set of Ids which are the values
    */
    global Set<Id> keySetId() {
        if(fieldDepth != fieldOrderSize - 1) {
            throw new SObjectIndexException('SObjectIndex: must call keySet() on an index with depth 1');
        } else {
            Set<Id> returnVal = new Set<Id>();
            for(String key : index.keySet()) {
                returnVal.add((Id)key);
            }
            return returnVal;
        }
    }

    /**
    * @description Get the all of the values for indexed objects on the specified indexed field
    * @return a set of String representations of the values
    * @example
    * Nebula_Tools.SObjectIndex theIndex = new Nebula_Tools.SObjectIndex('AccountId');
    *
    * Account acc = [SELECT Id FROM Account LIMIT 1];
    *
    * theIndex.put(new Contact(AccountId = acc.id, FirstName = 'John', LastName = 'Doe'));
    * theIndex.put(new Contact(AccountId = acc.id, FirstName = 'Jane', LastName = 'Doe2'));
    *
    * Set<String> ks = theIndex.keySet('AccountId');
    * System.assertEquals(1, ks.size());
    * System.assert(ks.contains(acc.id));
    */
    global Set<String> keySet(String field) {
        if(isLeaf) {
            return new Set<String>();
        } else if(fieldOrder[fieldDepth] == field) {
            return index.keySet();
        } else {
            Set<String> returnVal = new Set<String>();

            List<SObjectIndex> subIndices = index.values();
            for(Integer i=0, size = subIndices.size(); i < size; i++) {
                returnVal.addAll(subIndices[i].keySet(field));
            }

            return returnVal;
        }
    }

    /**
    * @description Get all of the values in the index
    * @return all values in the index
    */
    global List<SObject> values() {
        if(isLeaf) {
            return objects;
        } else {
            List<SObject> returnVal = new List<SObject>();

            List<SObjectIndex> subIndices = index.values();
            for(Integer i=0, size = subIndices.size(); i < size; i++) {
                returnVal.addAll(subIndices[i].values());
            }

            return returnVal;
        }

    }

    /**
    * @description SObjectIndex is internally structured as a tree of indexes, with one level for
    * each field that you have indexed on. Given a value on the current top-level, this returns the
    * subtree matching that value
    * @param val a value on the first field indexed in the SObjectIndex
    * @return a SObjectIndex for entries matching val, and indexed on the remainder of the fields after
    * the current top-level
    */
    global SObjectIndex getSubIndex(Object val) {
        SObjectIndex returnVal;

        if(!isLeaf) {
            String key = val == null ? null : '' + val;
            returnVal = index.get(key);
        }

        return returnVal;
    }

    /**
    * @description Removes some entries from the index, based on the same matching criteria as getAll(sObject spec)
    * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
    * @return a set of Ids of the objects removed, or an empty set if there were no matches
    */
    global Set<Id> remove(SObject spec) {
        if(isLeaf) {
            Set<Id> returnVal = new Set<Id>();
            for(Integer i=objects.size()-1; i >= 0; i--) {
                if(objects[i] == spec) {
                    if(objects[i].Id != null) {
                        returnVal.add(objects[i].Id);
                        ids.remove(objects[i].Id);
                    }
                    objects.remove(i);
                }
            }
            return returnVal;
        } else {
            String val = getValue(spec);

            SObjectIndex thisIndex = index.get(val);
            Set<Id> returnVal;

            if(thisIndex != null) {
                returnVal = thisIndex.remove(spec);
                ids.removeAll(returnVal);
            } else {
                returnVal = new Set<Id>();
            }

            return returnVal;
        }
    }

    /**
    * @description Removes some entries from the index, based on the same matching criteria as getAll(Map<String, Object> spec)
    * @param spec a map of field names to values
    * @return a set of Ids of the objects removed, or an empty set if there were no matches
    */
    global Set<Id> remove(Map<String, Object> spec) {
        if(isLeaf) {
            Set<Id> returnVal = ids;
            ids = new Set<Id>();
            objects = new List<SObject>();
            return returnVal;
        } else {
            Set<Id> returnVal = new Set<Id>();

            if(spec.containsKey(fieldOrder[fieldDepth])) {
                Object objVal = spec.get(fieldOrder[fieldDepth]);
                String val = objVal == null ? null : '' + objVal;
                if(val != null && isCaseInsensitive) {
                    val = val.toLowerCase();
                }

                SObjectIndex thisIndex = index.get(val);

                if(thisIndex != null) {
                    returnVal.addAll(thisIndex.remove(spec));
                }
            } else {
                List<SObjectIndex> subIndices = index.values();
                for(Integer i=0, size = subIndices.size(); i < size; i++) {
                    returnVal.addAll(subIndices[i].remove(spec));
                }
            }
            ids.removeAll(returnVal);
            return returnVal;
        }

    }

    /**
    * @description Deep clone the index, and the objects inside it. The result is a completely separate
    * SObjectIndex where the entries have had List<sObject>.deepClone(true, true, true) called on them
    * @return a deep clone of the SObjectIndex
    */
    global SObjectIndex deepClone() {
        SObjectIndex returnVal;
        if(isLeaf) {
            returnVal = new SObjectIndex(new List<String>());

            returnVal.objects = objects.deepClone(true, true, true);
        } else {
            returnVal = new SObjectIndex(fieldOrder[fieldDepth]);

            for(String key : index.keySet()) {
                returnVal.index.put(key, index.get(key).deepClone());
            }
        }

        returnVal.ids = ids.clone();

        return returnVal;
    }
}