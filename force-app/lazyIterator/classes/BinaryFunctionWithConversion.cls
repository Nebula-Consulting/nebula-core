/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 */

global abstract class BinaryFunctionWithConversion implements BinaryFunction {

    global abstract Object call(Object o1, Object o2);

    global Object call(Object o) {
        if(o instanceof Tuple) {
            Tuple t = (Tuple) o;
            return call(t.get(0), t.get(1));
        } else {
            return call(o, NoResult.NO_RESULT);
        }
    }
}