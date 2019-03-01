/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public interface BeforeDelete {

    void handleBeforeDelete(List<SObject> oldList);
}