/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public interface AfterUndelete {

    void handleAfterUndelete(List<SObject> newList);
}