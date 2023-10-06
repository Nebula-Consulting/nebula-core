/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-07
 * @description Compares its two arguments for ordering. Returns a negative integer, zero, or a positive integer when the
 * first argument is less than, equal to, or greater than the second.
 */

global interface Comparator extends System.Comparator<Object> {
    Integer compare(Object object1, Object object2);
}