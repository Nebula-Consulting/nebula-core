/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 19/11/2018
 */

@IsTest
private class StackTracesTest {

    private final static String MAGIC_STRING = 'magic string!';

    class MyException extends StackTraceException {
        public override String getMessage() {
            return MAGIC_STRING;
        }
    }

    @IsTest static void testGetErrorMessage() {
        Exception testException;

        try {
            insert new Contact();
        } catch (Exception e) {
            testException = e;
        }

        List<String> messages = StackTraces.getErrorMessage(testException);
        String joinedMessages = String.join(messages, '\n');
        System.debug(joinedMessages);
        System.assert(joinedMessages.contains(StackTraces.class.getName()));
        System.assert(joinedMessages.contains('REQUIRED_FIELD_MISSING'));
    }

    @IsTest static void testGetErrorMessageWrapped() {
        Exception testException;

        try {
            try {
                insert new Contact();
            } catch (Exception e) {
                throw new MyException(e);
            }
        } catch (MyException e) {
            testException = e;
        }

        List<String> messages = StackTraces.getErrorMessage(testException);
        String joinedMessages = String.join(messages, '\n');
        System.debug('\n' + joinedMessages);
        System.assert(joinedMessages.contains(MAGIC_STRING));
        System.assert(joinedMessages.contains(StackTraces.class.getName()));
        System.assert(joinedMessages.contains('REQUIRED_FIELD_MISSING'));
    }
}