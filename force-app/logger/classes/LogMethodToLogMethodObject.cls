/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 20/12/2021
 * @description Turns a LogMethod into a LogMethodObject by calling String.valueOf() on the incoming body parameter
 */

public class LogMethodToLogMethodObject implements LogMethodObject {

    private LogMethod logMethod;

    public LogMethodToLogMethodObject(LogMethod logMethod) {
        this.logMethod = logMethod;
    }

    public void log(LoggingLevel logLevel, String component, Object body, Id relatedTo) {
        logMethod.log(logLevel, component, String.valueOf(body), relatedTo);
    }

    public void commitLogs() {
        logMethod.commitLogs();
    }
}