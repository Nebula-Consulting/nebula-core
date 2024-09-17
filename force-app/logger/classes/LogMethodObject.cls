/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 20/12/2021
 * @description A log method where the storage method may handle different bodies differently, instead of treating
 * them all as strings
 */
global interface LogMethodObject extends LogMethod {
    void log(System.LoggingLevel logLevel, String component, Object body, Id relatedTo);

    void commitLogs();
}