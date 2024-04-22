/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 11/10/2019
 * @description Calls JSON.serialize()
 */
global class JsonSerialize implements Function, Serializer {

    private Boolean suppressApexObjectNulls;

    global JsonSerialize() {
        this.suppressApexObjectNulls = false;
    }

    global JsonSerialize(Boolean suppressApexObjectNulls) {
        this.suppressApexObjectNulls = suppressApexObjectNulls;
    }

    global Object call(Object o) {
        return serialize(o);
    }
    global String serialize(Object o) {
        return JSON.serialize(o);
    }
}