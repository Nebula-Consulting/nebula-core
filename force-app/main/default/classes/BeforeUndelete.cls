/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public interface BeforeUndelete {

    void handleBeforeUndelete(List<SObject> newList);
}