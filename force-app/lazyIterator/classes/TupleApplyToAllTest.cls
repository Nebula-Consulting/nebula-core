/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 03/03/2021
 */

@IsTest
private class TupleApplyToAllTest {

    @IsTest
    static void testBehavior() {
        ListTuple values = new ListTuple('a', 'b');
        Tuple result = new TupleApplyToAll(new StringFormat('Val: {0}')).call(values);

        System.assertEquals('Val: a', result.get(0));
        System.assertEquals('Val: b', result.get(1));
    }
}