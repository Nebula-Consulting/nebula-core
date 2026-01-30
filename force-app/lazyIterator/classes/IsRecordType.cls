/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 03/09/2020
 * @description For testing SObjects against record types. If constructed with just the developer name, each object to
 * test can be a different SObjectType. However, this is less efficient.
 */
global class IsRecordType implements BooleanFunction {

    private String developerName;
    private Id recordTypeId;

    global IsRecordType(String developerName) {
        this.developerName = developerName;
    }

    global IsRecordType(SObjectType sObjectType, String developerName) {
        recordTypeId = NamedSObjectCache.getRecordType(sObjectType, developerName).Id;
    }

    global Boolean isTrueFor(Object o) {
        SObject thisSObject = (SObject)o;
        if(recordTypeId != null) {
            return thisSObject.get('RecordTypeId') == recordTypeId;
        } else {
            return thisSObject.get('RecordTypeId') == NamedSObjectCache.getRecordType(thisSObject.getSObjectType(), developerName).Id;
        }
    }
}