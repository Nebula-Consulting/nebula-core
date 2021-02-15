/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 15/02/2021
 * @description Comparator for SObjects, comparing on a single field. Currently only support Decimal types, and then
 * sorts by string representation
 */

public class SObjectFieldComparator implements Comparator {

    private SObjectField fieldToCompare;
    private Comparator valueComparator;

    public SObjectFieldComparator(SObjectField fieldToCompare) {
        this.fieldToCompare = fieldToCompare;
        DisplayType displayType = fieldToCompare.getDescribe().getType();

        switch on displayType {
            when  DOUBLE, INTEGER, PERCENT, LONG {
                valueComparator = new DecimalComparator();
            }
            when else {
                valueComparator = new StringComparator();
            }
        }
    }

    public Integer compare(Object left, Object right) {
        return valueComparator.compare(((SObject)left).get(fieldToCompare), ((SObject)right).get(fieldToCompare));
    }

    private class DecimalComparator implements Comparator {
        public Integer compare(Object left, Object right) {
            Decimal result = (Decimal)left - (Decimal)right;
            return result < 0 ? -1 : (result == 0 ? 0 : 1);
        }
    }

    private class StringComparator implements Comparator {
        public Integer compare(Object left, Object right) {
            return String.valueOf(left).compareTo(String.valueOf(right));
        }
    }
}