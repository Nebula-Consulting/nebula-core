/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 15/10/2019
 * @description Calls JSON.deserialize
 */
global class JsonDeserialize implements Function {

    private Type outputType;

    global JsonDeserialize(Type outputType) {
        this.outputType = outputType;
    }

    global Object call(Object o) {
        return JSON.deserialize((String)o, outputType);
    }
}