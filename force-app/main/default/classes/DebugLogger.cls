/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-19
 * @description Logs via System.debug
 */

public with sharing class DebugLogger implements LogMethod {
    public void log(LoggingLevel logLevel, String component, String body, Id relatedTo) {
        System.debug(logLevel, body);
    }
}