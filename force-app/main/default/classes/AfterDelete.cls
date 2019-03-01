/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public interface AfterDelete {

    void handleAfterDelete(List<SObject> oldList);
}