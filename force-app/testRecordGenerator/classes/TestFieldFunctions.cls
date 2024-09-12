/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 * @description Some standard implementations of TestFieldFunction
 */

global class TestFieldFunctions {

    global abstract class TestFieldFunctionWithParent implements TestFieldFunction {
        global TestRecordGenerator parentGenerator;

        global TestFieldFunction setParentGenerator(TestRecordGenerator parentGenerator) {
            this.parentGenerator = parentGenerator;
            return this;
        }
    }

    global class RandomLong extends TestFieldFunctionWithParent {

        global Integer maxLength {
            get {
                if(maxLength == null) {
                    maxLength = 10;
                }
                return maxLength;
            } set; }

        global Long maxValue {
            get {
                if(maxValue == null) {
                    // Note that Math.random() is strictly less than 1, so there's no chance the the result will ever
                    // be exactly 10^maxLength (which would be too long)
                    maxValue = (Long)Math.pow(10, maxLength);
                }
                return maxValue;
            } set; }

        global Long getValue(String fieldName, Object value) {
            return (Long)(Math.random() * maxValue);
        }
    }

    global class AppendRandomNumber extends TestFieldFunctionWithParent {

        private RandomLong randomNumber { get {
            if(randomNumber == null) {
                randomNumber = new RandomLong();
            }
            return randomNumber;
        } set; }

        global Object getValue(String fieldName, Object value) {
            return value == null ? value : (value + String.valueOf(randomNumber.getValue(fieldName, value)));
        }
    }

    global class InsertRandomNumber extends TestFieldFunctionWithParent {

        private RandomLong randomNumber { get {
            if(randomNumber == null) {
                randomNumber = new RandomLong();
            }
            return randomNumber;
        } set; }

        global Object getValue(String fieldName, Object value) {
            if(value == null) {
                return null;
            } else {
                return String.format((String)value, new List<Object>{randomNumber.getValue(fieldName, value)});
            }
        }
    }

    global class CurrentUserId extends nebc.TestFieldFunctions.TestFieldFunctionWithParent {
        global Object getValue(String fieldName, Object value) {
            return UserInfo.getUserId();
        }
    }

    global class NamedObjectId extends nebc.TestFieldFunctions.TestFieldFunctionWithParent {

        global String sObjectType;
        global String name;

        global Object getValue(String fieldName, Object value) {
            SObjectType sObjectType = ((SObject) TypeLoader.getType('Schema.'+ sObjectType).newInstance()).getSObjectType();
            return new NamedSObjectCache(sObjectType, name).getObject().Id;
        }
    }

    global class GetStandardPriceBookId extends TestFieldFunctionWithParent {
        global Object getValue(String fieldName, Object value) {
            return Test.getStandardPricebookId();
        }
    }

    global class CreateRecord extends TestFieldFunctionWithParent {

        global String sObjectType;
        global String variant;
        global String variantParameter;
        global Integer numberOfRecords;

        global Object getValue(String fieldName, Object value) {
            SObject targetInstance = (SObject) TypeLoader.getType('Schema.'+ sObjectType).newInstance();
            if(variantParameter != null) {
                variant = (String)parentGenerator.getParameter(variantParameter);
            }

            TestRecordSource.GetBuilder builder = parentGenerator.parentRecordSource
                    .getRecord(targetInstance.getSObjectType())
                    .asVariant(variant);
            if (numberOfRecords == null) {
                return builder.withInsert().Id;
            } else {
                return builder.withInsert(numberOfRecords);
            }
        }
    }

    global class GetRecordTypeId extends TestFieldFunctionWithParent {

        global String sObjectType;
        global String developerName;

        global Object getValue(String fieldName, Object value) {

            if (sObjectType == null) {
                sObjectType = parentGenerator.metadata.SObject__c;
            }
            if (developerName == null) {
                developerName = (String) value;
            }

            return NamedSObjectCache.getRecordType(
                    sObjectType,
                    developerName
            ).Id;
        }
    }

    global class Now extends TestFieldFunctionWithParent {

        global Integer addDays;
        global Integer addMonths;
        global Integer addYears;
        global Integer addMinutes;

        global Object getValue(String fieldName, Object value) {
            Datetime returnValue = Datetime.now();
            if(addDays != null) {
                returnValue = returnValue.addDays(addDays);
            }
            if(addMonths != null) {
                returnValue = returnValue.addMonths(addMonths);
            }
            if(addYears != null) {
                returnValue = returnValue.addYears(addYears);
            }
            if(addMinutes != null) {
                returnValue = returnValue.addMinutes(addMinutes);
            }
            return returnValue;
        }
    }

    global class Today extends TestFieldFunctionWithParent {

        global Integer addDays;
        global Integer addMonths;
        global Integer addYears;
        global Boolean toStartOfWeek;
        global Boolean toStartOfMonth;

        global Object getValue(String fieldName, Object value) {
            Date returnValue = Date.today();
            if(toStartOfWeek == true) {
                returnValue = returnValue.toStartOfWeek();
            }
            if(toStartOfMonth == true) {
                returnValue = returnValue.toStartOfMonth();
            }
            if(addDays != null) {
                returnValue = returnValue.addDays(addDays);
            }
            if(addMonths != null) {
                returnValue = returnValue.addMonths(addMonths);
            }
            if(addYears != null) {
                returnValue = returnValue.addYears(addYears);
            }
            return returnValue;
        }
    }

    global class Increment extends TestFieldFunctionWithParent {

        global Decimal accumulator;
        global Decimal increment;

        global Object getValue(String fieldName, Object value) {
            Decimal result =  (Decimal)value + accumulator;
            accumulator += increment;
            return result;
        }
    }

    global class ReadParameter extends TestFieldFunctionWithParent {

        global String parameterName;

        global Object getValue(String fieldName, Object value) {
            parameterName = parameterName == null ? fieldName : parameterName;
            if(parentGenerator.hasParameter(parameterName)) {
                return parentGenerator.getParameter(parameterName);
            } else {
                return value;
            }
        }
    }
}