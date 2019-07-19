/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-18
 * @description Example of an Iterator as a data-source function
 */

public class PositiveIntegers implements Iterator<Integer> {

    private Integer x = 0;

    public Boolean hasNext() {
        return true;
    }

    public Integer next() {
        return ++x;
    }
}