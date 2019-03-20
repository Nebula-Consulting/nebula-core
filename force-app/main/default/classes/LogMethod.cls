/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-19
 */

global interface LogMethod {
    void log(System.LoggingLevel logLevel, String component, String body, Id relatedTo);

    void commitLogs();
}