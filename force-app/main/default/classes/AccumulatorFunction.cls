/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-24
 */

global interface AccumulatorFunction {
    Object nextValue(Object valueSoFar, Object thisValue);
}