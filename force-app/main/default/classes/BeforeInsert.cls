/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

global interface BeforeInsert {

    void handleBeforeInsert(List<SObject> newList);
}