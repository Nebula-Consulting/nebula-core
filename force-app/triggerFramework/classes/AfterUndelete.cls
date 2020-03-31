/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

global interface AfterUndelete {

    void handleAfterUndelete(List<SObject> newList);
}