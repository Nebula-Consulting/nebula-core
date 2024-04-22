/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 11/11/2019
 * @description For accumulating, where the object itself is the accumulated result, rather than returning the accumulation
 * like in AccumulatorFunction
 */
global interface AccumulatorObject {
    void accumulate(Object o);
}