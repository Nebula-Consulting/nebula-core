/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 31/10/2019
 * @description A function which creates instances of Pair. When created with function f, calling on object o returns
 * the pair <o, f(o)>
 */

global class ToPair implements Function {

    private Function mapO1ToO2Function;

    global ToPair(Function mapO1ToO2Function) {
        this.mapO1ToO2Function = mapO1ToO2Function;
    }

    public Object call(Object o) {
        return new ObjectPair(o, mapO1ToO2Function.call(o));
    }
}