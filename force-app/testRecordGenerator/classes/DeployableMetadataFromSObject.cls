/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 22/11/2019
 * @description Converts a custom metadata SObject record into a Metadata.CustomMetadata representation so that it can
 * be deployed
 */

public class DeployableMetadataFromSObject implements Function {

    private SObject metadataRecord;
    private DescribeSObjectResult metadataRecordDescribe;

    public Metadata.CustomMetadata call(Object o) {
        metadataRecord = (SObject)o;
        metadataRecordDescribe = metadataRecord.getSObjectType().getDescribe();

        Map<String, Object> populatedFields = metadataRecord.getPopulatedFieldsAsMap();

        return (Metadata.CustomMetadata)new LazyStringIterator(populatedFields.keySet().iterator())
                .filter(new IsNot(new IsAny(new IsEqual('MasterLabel'), new IsEqual('DeveloperName'))))
                .filter(new IsWriteableType(metadataRecordDescribe))
                .mapValues(new CustomMetadataValueFromField(populatedFields))
                .reduce(new AddValueToCustomMetadata(), getCustomMetadataWithNames());
    }

    private Metadata.CustomMetadata getCustomMetadataWithNames() {
        Metadata.CustomMetadata metadataResult = new Metadata.CustomMetadata();

        metadataResult.fullName = metadataRecordDescribe.getName().removeEnd('__mdt')
                + '.' + metadataRecord.get('DeveloperName');
        metadataResult.label = (String)metadataRecord.get('MasterLabel');

        return metadataResult;
    }

    private class IsWriteableType implements BooleanFunction {

        Map<String, SObjectField> fieldMap;
        Set<DisplayType> acceptableTypes = new Set<DisplayType>{
                DisplayType.STRING,
                DisplayType.TEXTAREA,
                DisplayType.DOUBLE,
                DisplayType.BOOLEAN,
                DisplayType.PICKLIST
        };

        public IsWriteableType(DescribeSObjectResult metadataRecordDescribe) {
            fieldMap = metadataRecordDescribe.fields.getMap();
        }

        public Boolean isTrueFor(Object thisField) {
            DisplayType thisDisplayType = fieldMap.get((String)thisField).getDescribe().getType();

            return acceptableTypes.contains(thisDisplayType);
        }
    }

    private class CustomMetadataValueFromField implements Function {

        Map<String, Object> populatedFields;

        public CustomMetadataValueFromField(Map<String, Object> populatedFields) {
            this.populatedFields = populatedFields;
        }

        public Object call(Object o) {
            String thisField = (String)o;
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = thisField;
            customField.value = populatedFields.get(thisField);
            return customField;
        }
    }

    private class AddValueToCustomMetadata implements AccumulatorFunction {
        public Object nextValue(Object valueSoFar, Object thisValue) {
            ((Metadata.CustomMetadata)valueSoFar).values.add((Metadata.CustomMetadataValue)thisValue);
            return valueSoFar;
        }
    }
}