/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 19/11/2018
 * @description Serializer that converts non-null values to lower case
 */

public class LowerCaseSerializer implements Serializer {
    public String serialize(Object o) {
        if(o == null) {
            return null;
        } else {
            return String.valueOf(o).toLowerCase();
        }
    }
}