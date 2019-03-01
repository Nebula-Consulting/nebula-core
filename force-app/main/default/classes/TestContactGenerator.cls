/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public class TestContactGenerator extends TestRecordGenerator {

    private Boolean linkToAccount = true;

    public override SObject getObjectNoInsert(Map<String, Object> params) {
        return new Contact(
                LastName = 'Test LastName',
                AccountId = (linkToAccount ? parentTestRecords.getObjectWithInsert(Account.SObjectType).Id : null)
        );
    }

}