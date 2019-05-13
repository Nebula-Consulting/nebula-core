/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-13
 * @description Generates fake Ids that look like real ids for records that never get inserted
 */

global class TestIdGenerator implements Iterator<Id> {

    private String keyPrefix;
    private Integer count;

    global TestIdGenerator(SObjectType sObjectType) {
        this.keyPrefix = sObjectType.getDescribe().getKeyPrefix();
        this.count = 0;
    }

    global Boolean hasNext() {
        return true;
    }

    global Id next() {
        return keyPrefix
                + String.valueOf(count++).leftPad(4, '0')
                + '0'.repeat(8);
    }
}