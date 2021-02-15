/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 15/02/2021
 * @description Reverses the results from a given comparator
 */

public class ReverseComparator implements Comparator {

    private Comparator comparator;

    public ReverseComparator(Comparator comparator) {
        this.comparator = comparator;
    }

    public Integer compare(Object object1, Object object2) {
        return -comparator.compare(object1, object2);
    }
}