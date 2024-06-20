/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 02/07/2021
 * @description A tuple for just two items. If possible, use this instead of ListTuple with two items.
 */
global virtual class TwoTuple implements Tuple {

    global Object left {get; private set;}
    global Object right {get; private set;}

    global static NewInstance newInstance = new NewTwoTuple();

    global TwoTuple(Object left, Object right) {
        this.left = left;
        this.right = right;
    }

    global Object get(Integer n) {
        return n == 0 ? left : right;
    }

    global Integer size() {
        return 2;
    }

    global Iterator<Object> iterator() {
        return new List<Object>{left, right}.iterator();
    }

    private class NewTwoTuple implements NewInstance {
        public Object newInstance(List<Object> parameters) {
            return new TwoTuple(parameters[0], parameters[1]);
        }
    }
}
