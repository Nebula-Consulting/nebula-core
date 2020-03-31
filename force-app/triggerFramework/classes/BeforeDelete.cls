/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

global interface BeforeDelete {

    void handleBeforeDelete(List<SObject> oldList);
}