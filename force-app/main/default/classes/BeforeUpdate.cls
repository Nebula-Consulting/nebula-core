/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public interface BeforeUpdate {

    void handleBeforeUpdate(List<SObject> oldList, List<SObject> newList);
}