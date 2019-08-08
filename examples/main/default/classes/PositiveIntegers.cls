/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-18
 * @description Example of an Iterator as a data-source function
 */

public class PositiveIntegers implements Iterator<Object> {

    private Integer x = 0;

    public PositiveIntegers(Integer startValue) {
        x = startValue;
    }

    public Boolean hasNext() {
        return true;
    }

    public Object next() {
        return x++;
    }
}