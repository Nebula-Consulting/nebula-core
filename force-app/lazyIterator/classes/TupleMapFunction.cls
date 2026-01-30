/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 03/02/2021
 * @description Applies a tuple of Functions to a tuple of data, returning a tuple of mapped data. Each Function will
 * receive the entire tuple as its calling parameter i.e. TupleMapFunction(f1, ...,fn) called on <o1, ..., on> will
 * return <f1(<o1, ... on>), ..., fn(<o1, ..., on>)>
 */
global with sharing class TupleMapFunction implements Function {

    private Tuple functions;
    private NewInstance tupleNewInstance = ListTuple.newInstance;

    global TupleMapFunction(Tuple functions) {
        this.functions = functions;
    }

    global TupleMapFunction(Function function1, Function function2) {
        this.functions = new TwoTuple(function1, function2);
    }

    global TupleMapFunction setTupleNewInstance(NewInstance tupleNewInstance) {
        this.tupleNewInstance = tupleNewInstance;
        return this;
    }

    global Tuple call(Object o) {
        Tuple inputTuple = (Tuple)o;
        List<Object> result = new List<Object>(inputTuple.size());

        for(Integer i=0, size=result.size(); i < size; i++) {
            result[i] = ((Function)functions.get(i)).call(inputTuple);
        }

        return (Tuple)tupleNewInstance.newInstance(result);
    }
}