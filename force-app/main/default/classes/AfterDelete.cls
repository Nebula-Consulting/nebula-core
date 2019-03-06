/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

global interface AfterDelete {

    void handleAfterDelete(List<SObject> oldList);
}