/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 11/05/2018
 * @description Utilities around getting stack traces and error messages
 */

global class StackTraces {

    /**
     * Takes an Exception which may have a cause exception inside it, and builds a string of all messages + traces
     * inside it by calling getCause() until there are no more.
     *
     * @param e an Exception
     * @return the messages and stack traces from e and all nested Exceptions inside it
     */
    global static String getErrorMessage(Exception e) {
        String returnVal = '';
        do {
            returnVal = e.getMessage() + '\n' + e.getStackTraceString() + returnVal;
            e = e.getCause();
        } while(e != null);
        return returnVal;
    }
}