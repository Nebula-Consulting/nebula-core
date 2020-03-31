/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2019
 */

@IsTest
private class LazyExpansionIteratorTest {

    @IsTest static void expand() {
        List<List<Integer>> data = new List<List<Integer>>{
                new List<Integer> {0},
                new List<Integer> {1, 2},
                new List<Integer> {3, 4},
                new List<Integer> {5}
        };

        List<Integer> flattened = (List<Integer>)new LazyIterator((List<Object>)data)
                .expand(new ListExpander())
                .toList(new List<Integer>());

        System.assertEquals(6, flattened.size());
        for (Integer i = 0; i < 6; i++) {
            System.assertEquals(i, flattened[i]);
        }
    }
    @IsTest static void expandWithEmptyAtEnd() {
        List<List<Integer>> data = new List<List<Integer>>{
                new List<Integer> {0},
                new List<Integer> {1, 2},
                new List<Integer> {3, 4},
                new List<Integer> {5},
                new List<Integer> {}
        };

        List<Integer> flattened = (List<Integer>)new LazyIterator((List<Object>)data)
                .expand(new ListExpander())
                .toList(new List<Integer>());

        System.assertEquals(6, flattened.size());
        for (Integer i = 0; i < 6; i++) {
            System.assertEquals(i, flattened[i]);
        }
    }

    @IsTest static void expandWithEmptyAtStart() {
        List<List<Integer>> data = new List<List<Integer>>{
                new List<Integer> {},
                new List<Integer> {0},
                new List<Integer> {1, 2},
                new List<Integer> {3, 4},
                new List<Integer> {5}
        };

        List<Integer> flattened = (List<Integer>)new LazyIterator((List<Object>)data)
                .expand(new ListExpander())
                .toList(new List<Integer>());

        System.assertEquals(6, flattened.size());
        for (Integer i = 0; i < 6; i++) {
            System.assertEquals(i, flattened[i]);
        }
    }

    @IsTest static void expandWithEmptyInMiddle() {
        List<List<Integer>> data = new List<List<Integer>>{
                new List<Integer> {0},
                new List<Integer> {1, 2},
                new List<Integer> {},
                new List<Integer> {3, 4},
                new List<Integer> {5}
        };

        List<Integer> flattened = (List<Integer>)new LazyIterator((List<Object>)data)
                .expand(new ListExpander())
                .toList(new List<Integer>());

        System.assertEquals(6, flattened.size());
        for (Integer i = 0; i < 6; i++) {
            System.assertEquals(i, flattened[i]);
        }
    }
    @IsTest static void emptyList() {
        List<List<Integer>> data = new List<List<Integer>>{
        };

        List<Integer> flattened = (List<Integer>)new LazyIterator((List<Object>)data)
                .expand(new ListExpander())
                .toList(new List<Integer>());

        System.assertEquals(0, flattened.size());
    }

    private class ListExpander implements ExpansionFunction {

        private Iterator<Integer> iterator;

        public void setValue(Object value) {
            iterator = ((List<Integer>)value).iterator();
        }

        public Boolean hasNext() {
            return iterator.hasNext();
        }

        public Object next() {
            return iterator.next();
        }
    }
}