/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-15
 */

@IsTest
public class LoggerTest {

    public static List<String> logs = new List<String>();
    public static List<String> relatedTos = new List<String>();
    public static List<String> logs2 = new List<String>();
    public static List<Integer> integerLog = new List<Integer>();
    static TestIdGenerator accountIdGenerator = new TestIdGenerator(Account.SObjectType);
    @IsTest
    static void testBehavior() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
                Level__c = LoggingLevel.DEBUG.name(),
                Component__c = LoggerTest.class.getName(),
                LogMethod_Class__c = LoggerImplementation.class.getName()
        )};
        String theMessage = 'A message';
        Logger.log(LoggingLevel.DEBUG, LoggerTest.class.getName(), theMessage);

        Assert.areEqual(theMessage, logs[0]);
    }

    @IsTest
    static void nonString() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
                Level__c = LoggingLevel.DEBUG.name(),
                Component__c = LoggerTest.class.getName(),
                LogMethod_Class__c = LoggerImplementation.class.getName()
        )};
        Logger.log(LoggingLevel.DEBUG, LoggerTest.class.getName(), 123);

        Assert.areEqual(String.valueOf(123), logs[0]);
    }

    @IsTest
    static void integerLog() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
                Level__c = LoggingLevel.DEBUG.name(),
                Component__c = LoggerTest.class.getName(),
                LogMethod_Class__c = IntegerLoggerImplementation.class.getName()
        )};
        Logger.log(LoggingLevel.DEBUG, LoggerTest.class.getName(), 123);

        Assert.areEqual(123, integerLog[0]);
    }

    @IsTest
    static void logFunction() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
                Level__c = LoggingLevel.DEBUG.name(),
                Component__c = null,
                LogMethod_Class__c = LoggerImplementation.class.getName()
        )};
        String theMessage = 'A message';
        new LazyIterator(new List<String>{theMessage})
                .mapValues(new Log('{0}'))
                .forEach();

        Assert.areEqual(theMessage, logs[0]);
    }

    @IsTest
    static void logFunctionRelatedToFunction() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
                Level__c = LoggingLevel.DEBUG.name(),
                Component__c = null,
                LogMethod_Class__c = LoggerImplementation.class.getName()
        )};
        List<Account> accounts = new List<Account> {
                new Account(Id = accountIdGenerator.next(), Name = 'Account 1'),
                new Account(Id = accountIdGenerator.next(), Name = 'Account 2')
        };
        new LazyIterator(accounts)
                .mapValues(new Log('{0}')
                        .setMapBeforeOutput(new FieldFromSObject(Account.Name))
                        .setRelatedTo(new IdFromSObject())
                )
                .forEach();

        Assert.areEqual(accounts[0].Name, logs[0]);
        Assert.areEqual(accounts[0].Id, relatedTos[0]);
        Assert.areEqual(accounts[1].Name, logs[1]);
        Assert.areEqual(accounts[1].Id, relatedTos[1]);
    }

    @IsTest
    static void logFunctionRelatedToObject() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
                Level__c = LoggingLevel.DEBUG.name(),
                Component__c = null,
                LogMethod_Class__c = LoggerImplementation.class.getName()
        )};
        List<Account> accounts = new List<Account> {
                new Account(Id = accountIdGenerator.next(), Name = 'Account 1'),
                new Account(Id = accountIdGenerator.next(), Name = 'Account 2')
        };
        new LazyIterator(accounts)
                .mapValues(new Log('{0}')
                        .setMapBeforeOutput(new FieldFromSObject(Account.Name))
                        .setRelatedTo(accounts[0].Id)
                )
                .forEach();

        Assert.areEqual(accounts[0].Name, logs[0]);
        Assert.areEqual(accounts[0].Id, relatedTos[0]);
        Assert.areEqual(accounts[1].Name, logs[1]);
        Assert.areEqual(accounts[0].Id, relatedTos[1]);
    }

    @IsTest
    static void logFunctionWithConfig() {
        Logger.logSettings = new List<Log_Setting__mdt>{ new Log_Setting__mdt(
                Level__c = LoggingLevel.ERROR.name(),
                Component__c = LoggerTest.class.getName(),
                LogMethod_Class__c = LoggerImplementation.class.getName()
        )};
        String theMessage = 'A message';
        new LazyIterator(new List<String>{theMessage})
                .mapValues(new Log('{0}!')
                .setComponent(LoggerTest.class.getName())
                .setLoggingLevel(LoggingLevel.ERROR)
                .setMapBeforeOutput(new JsonSerialize())
        )
                .forEach();

        Assert.areEqual('"' + theMessage + '"!', logs[0]);
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

        Assert.areEqual(theMessage, logs[0]);
        Assert.areEqual(theMessage, logs2[0]);
    }

    public class LoggerImplementation implements LogMethod {

        public void log(LoggingLevel logLevel, String component, String body, Id relatedTo) {
            LoggerTest.logs.add(body);
            LoggerTest.relatedTos.add(relatedTo);
        }

        @SuppressWarnings('PMD.EmptyStatementBlock') // This is a test class
        public void commitLogs() {
        }
    }

    public class LoggerImplementation2 implements LogMethod {

        public void log(LoggingLevel logLevel, String component, String body, Id relatedTo) {
            LoggerTest.logs2.add(body);
        }

        @SuppressWarnings('PMD.EmptyStatementBlock') // This is a test class
        public void commitLogs() {
        }
    }

    public class IntegerLoggerImplementation implements LogMethodObject {

        public void log(LoggingLevel logLevel, String component, Object body, Id relatedTo) {
            LoggerTest.integerLog.add((Integer)body);
        }

        @SuppressWarnings('PMD.EmptyStatementBlock') // This is a test class
        public void commitLogs() {
        }
    }
}