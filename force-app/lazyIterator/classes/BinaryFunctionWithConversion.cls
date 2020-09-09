/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 */

global abstract class BinaryFunctionWithConversion implements BinaryFunction {

    global abstract Object call(Object o1, Object o2);

    global Object call(Object o) {
        if(o instanceof Pair) {
            Pair p = (Pair) o;
            return call(p.left(), p.right());
        } else {
            return call(o, NoResult.NO_RESULT);
        }
    }
}