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
     * @return the type, messages, and stack traces from e and all nested Exceptions inside it
     */
    global static List<String> getErrorMessage(Exception e) {
        List<String> returnVal = new List<String>();
        Integer exceptionCount = 0;
        do {
            returnVal.add(String.format('type[{0}]: {1}', new List<Object>{ exceptionCount, e.getTypeName()}));
            returnVal.add(String.format('message[{0}]: {1}', new List<Object>{ exceptionCount, e.getMessage()}));
            returnVal.add(String.format('stack trace[{0}]:\n{1}', new List<Object>{ exceptionCount, e.getStackTraceString()}));
            e = e.getCause();
            ++exceptionCount;
        } while(e != null);
        return returnVal;
    }
}