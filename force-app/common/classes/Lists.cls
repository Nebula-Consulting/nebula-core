/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-07
 * @description Functions on Lists
 */
global class Lists {

    global abstract class FilterFunction {
        global virtual Boolean matches(Object element, Integer index, List<Object> theList) {
            return matches(element, index);
        }
        global virtual Boolean matches(Object element, Integer index) {
            return matches(element);
        }
        global virtual Boolean matches(Object element) {
            throw new NoSuchMethodException('Implementations of ' + Lists.FilterFunction.class.getName() + ' must '
                    + 'override at least one of the matches() methods');
        }
    }

    /**
     * @description Sorts a list using the provided comparator
     * @param toSort The list to sort
     * @param comparator The comparator to use for sorting
     * @return The sorted list
     */
    global static List<Object> sort(List<Object> toSort, Comparator comparator) {
        toSort.sort(comparator);
        return toSort;
    }

    /**
     * @description Filters a list based on the provided filter function
     * @param toFilter The list to filter
     * @param filterFunction The filter function to apply
     * @return A new list containing only matching elements
     */
    global static List<Object> filter(List<Object> toFilter, FilterFunction filterFunction) {
        List<Object> returnVal = new List<Object>();
        for(Integer i=0; i < toFilter.size(); i++) {
            Object thisElement = toFilter[i];
            if(filterFunction.matches(thisElement, i, toFilter)) {
                returnVal.add(thisElement);
            }
        }
        return returnVal;
    }
}