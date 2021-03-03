/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 03/03/2021
 * @description Applies a function to all elements of a Tuple, returning a new Tuple of the results. Each call to the
 * function receives just one element, not the whole Tuple
 */

global class TupleApplyToAll implements Function {

    private nebc.Function function;

    global TupleApplyToAll(nebc.Function function) {
        this.function = function;
    }

    global Tuple call(Object o) {
        Tuple inputTuple = (Tuple)o;
        List<Object> result = new List<Object>(inputTuple.size());

        for(Integer i=0, size=result.size(); i < size; i++) {
            result[i] = function.call(inputTuple.get(i));
        }

        return new ListTuple(result);
    }

}