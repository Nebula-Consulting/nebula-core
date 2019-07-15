/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-15
 */

@IsTest
public class LoggerTest {

    public static List<String> logs = new List<String>();
    public static List<String> logs2 = new List<String>();

    @IsTest
    static void testBehavior() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
                Level__c = LoggingLevel.DEBUG.name(),
                Component__c = LoggerTest.class.getName(),
                LogMethod_Class__c = LoggerImplementation.class.getName()
        )};
        String theMessage = 'A message';
        Logger.log(LoggingLevel.DEBUG, LoggerTest.class.getName(), theMessage);

        System.assertEquals(theMessage, logs[0]);
    }

    @IsTest
    static void twoLogMethods() {
        Logger.logSettings = new List<Log_Setting__mdt>{
                new Log_Setting__mdt(
                        Level__c = LoggingLevel.DEBUG.name(),
                        Component__c = LoggerTest.class.getName(),
                        LogMethod_Class__c = LoggerImplementation.class.getName()
                ),
                new Log_Setting__mdt(
                        Level__c = LoggingLevel.DEBUG.name(),
                        Component__c = LoggerTest.class.getName(),
                        LogMethod_Class__c = LoggerImplementation2.class.getName()
                )
        };
        String theMessage = 'A message';
        Logger.log(LoggingLevel.DEBUG, LoggerTest.class.getName(), theMessage);

        System.assertEquals(theMessage, logs[0]);
        System.assertEquals(theMessage, logs2[0]);
    }

    public class LoggerImplementation implements LogMethod {

        public void log(LoggingLevel logLevel, String component, String body, Id relatedTo) {
            LoggerTest.logs.add(body);
        }

        public void commitLogs() {
        }
    }

    public class LoggerImplementation2 implements LogMethod {

        public void log(LoggingLevel logLevel, String component, String body, Id relatedTo) {
            LoggerTest.logs2.add(body);
        }

        public void commitLogs() {
        }
    }
}