/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 03/02/2021
 * @description Applies a tuple of Functions to a tuple of data, returning a tuple of mapped data. Each Function will
 * receive the entire tuple as its calling parameter
 */

global with sharing class TupleMapFunction implements Function {

    private Tuple functions;

    global TupleMapFunction(Tuple functions) {
        this.functions = functions;
    }

    global Tuple call(Object o) {
        Tuple inputTuple = (Tuple)o;
        List<Object> result = new List<Object>(inputTuple.size());

        for(Integer i=0, size=result.size(); i < size; i++) {
            result[i] = ((Function)functions.get(i)).call(inputTuple);
        }

        return new ListTuple(result);
    }
}