/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-13
 * @description Generates fake Ids that look like real ids for records that never get inserted
 */
global class TestIdGenerator implements Iterator<Id> {

    private String keyPrefix;
    private Integer count;

    /**
     * @description Creates a test ID generator for the specified SObjectType
     * @param sObjectType The SObjectType to generate IDs for
     */
    global TestIdGenerator(SObjectType sObjectType) {
        this.keyPrefix = sObjectType.getDescribe().getKeyPrefix();
        this.count = 0;
    }

    /**
     * @description Always returns true as this generator has no limit
     * @return True
     */
    global Boolean hasNext() {
        return true;
    }

    /**
     * @description Generates the next fake ID
     * @return A fake but valid-looking Salesforce ID
     */
    global Id next() {
        return keyPrefix + '00'
                + String.valueOf(count++).leftPad(10, '0');
    }
}