/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-15
 */

@IsTest
private class ListsTest {

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // asserts are in delegate function
    @IsTest static void sortEvenArrayLength() {
        runSortTests(10, 1000);
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // asserts are in delegate function
    @IsTest static void sortOddArrayLength() {
        runSortTests(9, 1000);
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // asserts are in delegate function
    @IsTest static void sortLengthOne() {
        runSortTests(1, 1);
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // asserts are in delegate function
    @IsTest static void sortEmpty() {
        runSortTests(0, 1);
    }

    @IsTest static void filter() {
        List<Integer> testList = new List<Integer>{
                1, 2, 3, 4, 5
        };
        List<Object> result = Lists.filter(testList, new EvenFilterFunction());

        System.assertEquals(2, result.size());
        System.assertEquals(2, result[0]);
        System.assertEquals(4, result[1]);
    }

    @IsTest static void invalidFilter() {
        List<Integer> testList = new List<Integer>{
                1, 2, 3, 4, 5
        };
        try {
            Lists.filter(testList, new InvalidFilterFunction());
        } catch (NoSuchMethodException e) {
            return;
        }
        System.assert(false, 'Should have thrown exception');
    }

    private static void runSortTests(Integer arrayLength, Integer nTests) {
        for (Integer t = 0; t < nTests; t++) {
            List<Integer> originalArray = new List<Integer>();
            List<Integer> testArray = new List<Integer>();
            List<Integer> expectedArray = new List<Integer>();


            for (Integer i = 0; i < arrayLength; i++) {
                Integer val = (Integer) (Math.random() * 1000);
                testArray.add(val);
                expectedArray.add(val);
                originalArray.add(val);
            }

            expectedArray.sort();
            Lists.sort(testArray, new IntegerComparator());

            System.assert(testArray.equals(expectedArray),
                    'Expected: ' + JSON.serialize(expectedArray)
                            + ' Got: ' + JSON.serialize(testArray)
                            + ' Original: ' + JSON.serialize(originalArray));
        }
    }

    public class IntegerComparator implements Comparator {
        public Integer compare(Object o1, Object o2) {
            return (Integer) o1 - (Integer) o2;
        }
    }

    public class EvenFilterFunction extends Lists.FilterFunction {
        public override Boolean matches(Object element) {
            return Math.mod((Integer) element, 2) == 0;
        }
    }

    public class InvalidFilterFunction extends Lists.FilterFunction {

    }
}