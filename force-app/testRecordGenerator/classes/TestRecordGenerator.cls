/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 * @description Abstract base class for test record generators. Extend this class and implement
 * generateRecord() to create custom test data generators that can be configured via custom metadata.
 */
global inherited sharing abstract class TestRecordGenerator {

    global TestRecordSource parentRecordSource {get; private set;}
    global Test_Record_Generator__mdt metadata {get; private set;}
    global List<Test_Record_Generator_Field__mdt> metadataFields {get; private set;}
    private Map<SObjectField, Object> recordInstanceValues;

    protected Map<String, Object> parameters {
        get {
            if(parameters == null) {
                parameters = new Map<String, Object>();
            }
            return parameters;
        }
        set;
    }

    /**
     * @description Gets a parameter value by name
     * @param name The parameter name
     * @return The parameter value, or null if not found
     */
    global Object getParameter(String name) {
        return parameters == null ? null : parameters.get(name);
    }

    /**
     * @description Checks if a parameter exists
     * @param name The parameter name
     * @return True if the parameter exists
     */
    global Boolean hasParameter(String name) {
        return parameters.containsKey(name);
    }

    /**
     * @description Initializes the generator with its parent source and metadata configuration
     * @param parentRecordSource The parent TestRecordSource
     * @param metadata The generator's custom metadata configuration
     * @param metadataFields The field configurations from custom metadata
     */
    global void setup(TestRecordSource parentRecordSource, Test_Record_Generator__mdt metadata, List<Test_Record_Generator_Field__mdt> metadataFields) {
        this.parentRecordSource = parentRecordSource;
        this.metadata = metadata;
        this.metadataFields = metadataFields;
        this.recordInstanceValues = new Map<SObjectField, Object>();
    }

    /**
     * @description Sets a field value on the generated record
     * @param field The SObjectField to set
     * @param value The value to set
     * @return This TestRecordGenerator for method chaining
     */
    global TestRecordGenerator put(SObjectField field, Object value) {
        this.recordInstanceValues.put(field, value);
        return this;
    }

    /**
     * @description Sets multiple field values on the generated record
     * @param recordInstanceValues Map of fields to values
     * @return This TestRecordGenerator for method chaining
     */
    global TestRecordGenerator putAll(Map<SObjectField, Object> recordInstanceValues) {
        this.recordInstanceValues.putAll(recordInstanceValues);
        return this;
    }

    /**
     * @description Gets a record without inserting, using the provided parameters
     * @param parameters Parameters to pass to the generator
     * @return The generated SObject (not inserted)
     */
    global SObject getRecordWithoutInsert(Map<String, Object> parameters) {
        this.parameters = parameters;
        return getRecordWithoutInsert();
    }

    /**
     * @description Override this method to define how records are generated
     * @return A newly generated SObject
     */
    global abstract SObject generateRecord();

    /**
     * @description Gets a record without inserting, applying any put field values
     * @return The generated SObject (not inserted)
     */
    global SObject getRecordWithoutInsert() {
        SObject record = generateRecord();
        for(SObjectField f : recordInstanceValues.keySet()) {
            record.put(f, recordInstanceValues.get(f));
        }
        return record;
    }

    /**
     * @description Gets multiple records without inserting
     * @param numberOfRecords The number of records to generate
     * @param params Parameters to pass to the generator
     * @return List of generated SObjects (not inserted)
     */
    global virtual List<SObject> getRecordsWithoutInsert(Integer numberOfRecords, Map<String, Object> params) {
        List<SObject> returnVal = new List<SObject>();
        for(Integer i=0; i < numberOfRecords; i++) {
            returnVal.add(getRecordWithoutInsert(params));
        }
        return returnVal;
    }

    /**
     * @description Gets multiple records and inserts them
     * @param numberOfRecords The number of records to generate
     * @param params Parameters to pass to the generator
     * @return List of inserted SObjects
     */
    global List<SObject> getRecordsWithInsert(Integer numberOfRecords, Map<String, Object> params) {
        if(record == null) {
            record = getRecordsWithoutInsert(numberOfRecords, params);
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

    private List<SObject> record;

    /**
     * @description Gets a single record with insert, caching the result for future calls
     * @param params Parameters to pass to the generator
     * @return The inserted SObject
     */
    global virtual SObject getRecordWithInsert(Map<String, Object> params) {
        if(record == null) {
            record = new List<SObject> { getRecordWithoutInsert(params) };
            try {
                insert record;
            } catch (Exception e) {
                throw new TestRecordGeneratorException('Exception creating test record '
                        + metadata.DeveloperName
                        + '\n'
                        + e.getMessage());
            }

        }
        return record[0];
    }

    /**
     * @description Sets an already-created record as the cached record for this generator
     * @param record The record to cache
     */
    global virtual void setRecord(SObject record) {
        this.record = new List<SObject>{ record };
    }

    /**
     * @description Sets already-created records as the cached records for this generator
     * @param records The records to cache
     */
    global virtual void setRecords(List<SObject> records) {
        this.record = records;
    }
}