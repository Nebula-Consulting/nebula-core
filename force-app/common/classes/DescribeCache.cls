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

    /**
     * @description Retrieves a field set for a given SObject type
     * @param sObjectType The SObject type API name
     * @param fieldSetName The field set API name
     * @return The FieldSet metadata
     */
    global static FieldSet getFieldSet(String sObjectType, String fieldSetName) {
        return globalDescribe.get(sObjectType).getDescribe().fieldSets.getMap().get(fieldSetName);
    }

    /**
     * @description Gets the describe result for an SObject type by name
     * @param typeName The SObject type API name
     * @return The DescribeSObjectResult for the type
     */
    global static DescribeSObjectResult describeSObject(String typeName) {
        return Schema.describeSObjects(new List<String>{typeName})[0];
    }
}