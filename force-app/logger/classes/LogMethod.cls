/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-19
 * @description A log method for String logs
 */
global interface LogMethod {
    void log(System.LoggingLevel logLevel, String component, String body, Id relatedTo);

    void commitLogs();
}