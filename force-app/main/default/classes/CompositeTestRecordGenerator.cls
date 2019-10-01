/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 30/09/2019
 * @description A TestRecordGenerator made up of a series of generators. Applies them in order to create the final
 * object
 */

public class CompositeTestRecordGenerator extends TestRecordGenerator {

    private List<TestRecordGenerator> generators;

    public CompositeTestRecordGenerator(TestRecordGenerator lastGenerator) {
        generators = new List<TestRecordGenerator>{lastGenerator};
        setup(lastGenerator.parentRecordSource, lastGenerator.metadata, lastGenerator.metadataFields);
    }

    public void pushFront(TestRecordGenerator nextGenerator) {
        generators.add(0, nextGenerator);
    }

    public override SObject getRecordWithoutInsert() {
        SObject result = generators[0].getRecordWithoutInsert(parameters);

        for(Integer i=1; i < generators.size(); i++) {
            Map<String, Object> newValues = generators[i].getRecordWithoutInsert(parameters).getPopulatedFieldsAsMap();
            for(String f : newValues.keySet()) {
                result.put(f, newValues.get(f));
            }
        }

        return result;
    }

}