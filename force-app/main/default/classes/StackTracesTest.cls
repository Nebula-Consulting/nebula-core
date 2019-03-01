/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 19/11/2018
 */

@IsTest
private class StackTracesTest {

    private final static String MAGIC_STRING = 'magic string!';

    class MyException extends Exception {
        public override String getMessage() {
            return MAGIC_STRING;
        }
    }

    @IsTest static void testGetErrorMessage() {
        Exception testException;

        try {
            try {
                insert new Contact();
            } catch (Exception e) {
                throw new MyException(e);
            }
        } catch (Exception e) {
            testException = e;
        }

        List<String> messages = StackTraces.getErrorMessage(testException);

        System.assert(String.join(messages, ' ').contains(MAGIC_STRING));
    }
}