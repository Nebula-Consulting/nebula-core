/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public class TestAccountGenerator extends TestRecordGenerator {

    public override SObject getObjectNoInsert(Map<String, Object> params) {
        return new Account(Name = 'Test AccountName');
    }
}