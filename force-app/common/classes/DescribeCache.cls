/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 * @description Describe calls are expensive - stores the results in a cache for fast access,
 * and access by name/token
 */
global class DescribeCache {

    global static Map<String, Schema.SObjectType> globalDescribe {
        get {
            if(globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        private set;
    }

    global static FieldSet getFieldSet(String sObjectType, String fieldSetName) {
        return globalDescribe.get(sObjectType).getDescribe().fieldSets.getMap().get(fieldSetName);
    }

    global static DescribeSObjectResult describeSObject(String typeName) {
        return Schema.describeSObjects(new List<String>{typeName})[0];
    }
}