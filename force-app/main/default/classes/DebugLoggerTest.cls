/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-19
 */

@IsTest
private class DebugLoggerTest {

    @IsTest
    static void testBehavior() {
        Logger.log(LoggingLevel.DEBUG, DebugLoggerTest.class.getName(), 'A message');
    }

    @IsTest
    static void noSuchLoggerClass() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
            Level__c = LoggingLevel.DEBUG.name(),
                Component__c = DebugLoggerTest.class.getName(),
                LogMethod_Class__c = 'noSuchClass'
        )};
        try {
            Logger.log(LoggingLevel.DEBUG, DebugLoggerTest.class.getName(), 'A message');
        } catch (ClassNotFoundException e) {
            return;
        }
        System.assert(false, 'Expected a ClassNotFoundException');
    }
}