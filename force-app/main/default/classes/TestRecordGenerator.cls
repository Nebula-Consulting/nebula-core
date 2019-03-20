/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

global inherited sharing abstract class TestRecordGenerator {

    global TestRecordSource parentRecordSource {get; private set;}
    global Test_Record_Generator__mdt metadata {get; private set;}
    global List<Test_Record_Generator_Field__mdt> metadataFields {get; private set;}

    public void setup(TestRecordSource parentRecordSource, Test_Record_Generator__mdt metadata, List<Test_Record_Generator_Field__mdt> metadataFields) {
        this.parentRecordSource = parentRecordSource;
        this.metadata = metadata;
        this.metadataFields = metadataFields;
    }

    global abstract SObject getRecordNoInsert(Map<String, Object> params);

    private SObject record;

    global virtual SObject getRecordWithInsert(Map<String, Object> params) {
        if(record == null) {
            record = getRecordNoInsert(params);
            try {
                insert record;
            } catch (Exception e) {
                throw new TestRecordGeneratorException('Exception creating test record '
                                + metadata.DeveloperName
                                + '\n'
                                + e.getMessage());
            }

        }
        return record;
    }

    global virtual void setRecord(SObject record) {
        this.record = record;
    }
}