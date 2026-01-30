/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 29/01/2021
 * @description Checks whether an SObjectField is accessible for querying by the current user
 */
global class IsFieldAccessible implements Function, BooleanFunction {

    global Object call(Object o) {
        return ((SObjectField)o).getDescribe().isAccessible();
    }

    global Boolean isTrueFor(Object o) {
        return ((SObjectField)o).getDescribe().isAccessible();
    }
}