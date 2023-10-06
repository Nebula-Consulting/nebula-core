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

    global static List<Object> sort(List<Object> toSort, Comparator comparator) {
        toSort.sort(comparator);
        return toSort;
    }

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