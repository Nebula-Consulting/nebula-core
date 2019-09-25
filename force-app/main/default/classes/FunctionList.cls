/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 25/09/2019
 * @description A list of functions which may be initialised from Objects, and turned into Constant Functions
 */

public class FunctionList {

    public List<Function> functions;

    public FunctionList(Object o1, Object o2) {
        functions = new List<Function> {
                o1 instanceof Function ? (Function)o1 : new ConstantFunction(o1),
                o2 instanceof Function ? (Function)o2 : new ConstantFunction(o2)
        };
    }
}