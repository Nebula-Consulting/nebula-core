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
        return new QuickSort(comparator).sort(toSort);
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

    private class QuickSort {

        private Comparator comparator;

        public QuickSort(Comparator comparator) {
            this.comparator = comparator;
        }

        // Sorts in-place, and returns the original array
        public List<Object> sort(List<Object> toSort) {
            sort(toSort, 0, toSort.size()-1);
            return toSort;
        }

        private void sort(List<Object> toSort, Integer low, Integer high) {
            if(low < high) {
                Integer newPivot = partition(toSort, low, high);
                sort(toSort, low, newPivot);
                sort(toSort, newPivot + 1, high);
            }
        }

        @SuppressWarnings('PMD.WhileLoopsMustUseBraces, PMD.EmptyWhileStmt') // low-level algorithm using whiles
        private Integer partition(List<Object> toSort, Integer low, Integer high) {
            Object pivotVal = toSort[low];
            Integer upwards = low - 1;
            Integer downwards = high + 1;

            while(true) {
                while(comparator.compare(toSort[++upwards], pivotVal) < 0);

                while(comparator.compare(toSort[--downwards], pivotVal) > 0);

                if(upwards >= downwards) {
                    return downwards;
                }

                Object tmp = toSort[upwards];
                toSort[upwards] = toSort[downwards];
                toSort[downwards] = tmp;
            }
            return null;
        }
    }
}