/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

global interface AfterInsert {

    void handleAfterInsert(List<SObject> newList);
}