/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/09/2020
 */

global class ObjectPair implements Pair {

    private Object left;
    private Object right;

    global ObjectPair(Object left, Object right) {
        this.left = left;
        this.right = right;
    }

    global Object left() {
        return left;
    }

    global Object right() {
        return right;
    }
}