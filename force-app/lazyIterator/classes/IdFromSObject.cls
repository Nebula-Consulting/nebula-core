/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 19/06/2023
 * @description Returns the Id from an SObject (faster than FieldFromSObject)
 */
global class IdFromSObject implements Function {
    global Object call(Object o) {
        return ((SObject) o).Id;
    }
}