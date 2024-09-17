/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */
global interface BeforeUpdate {

    void handleBeforeUpdate(List<SObject> oldList, List<SObject> newList);
}