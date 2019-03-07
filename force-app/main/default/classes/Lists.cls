/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-07
 * @description Functions on Lists
 */

global class Lists {

    global static List<Object> sort(List<Object> toSort, Comparator comparator) {
        return new QuickSort(comparator).quickSort(toSort);
    }

    private class QuickSort {

        private Comparator comparator;

        public QuickSort(Comparator comparator) {
            this.comparator = comparator;
        }

        // Sorts in-place, and returns the original array
        public List<Object> quickSort(List<Object> toSort) {
            quickSort(toSort, 0, toSort.size()-1);
            return toSort;
        }

        private void quickSort(List<Object> toSort, Integer low, Integer high) {
            if(low < high) {
                Integer newPivot = partition(toSort, low, high);
                quickSort(toSort, low, newPivot);
                quickSort(toSort, newPivot + 1, high);
            }
        }

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