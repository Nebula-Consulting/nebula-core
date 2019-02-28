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
                System.debug('11111111111111111111111111111111111111111111111111111111');
                System.debug(e.getStackTraceString());
                throw new MyException(e);
            }
        } catch (Exception e) {
            testException = e;
        }

        String message = StackTraces.getErrorMessage(testException);

        System.assert(message.contains(MAGIC_STRING));
        System.debug('33333333333333333333333333333333333333333333333333333333');
        System.debug(message);
    }
}