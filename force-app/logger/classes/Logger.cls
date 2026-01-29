/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-19
 * @description Flexible logging framework that uses custom metadata to configure logging methods and levels
 */
global without sharing class Logger {

    /**
     * @description Logs a message with the specified logging level and component
     * @param logLevel The logging level (e.g., DEBUG, INFO, ERROR)
     * @param component The component name for categorizing logs
     * @param body The message or object to log
     */
    global static void log(System.LoggingLevel logLevel, String component, Object body) {
        log(logLevel, component, body, null);
    }

    /**
     * @description Logs a message with the specified logging level, component, and related record
     * @param logLevel The logging level (e.g., DEBUG, INFO, ERROR)
     * @param component The component name for categorizing logs
     * @param body The message or object to log
     * @param relatedTo Optional Id of a related record
     */
    global static void log(System.LoggingLevel logLevel, String component, Object body, Id relatedTo) {
        new LazySObjectIterator(componentToLogSetting.getAll(component))
                .setDefaultIfEmpty(new Log_Setting__mdt(LogMethod_Class__c = DebugLogger.class.getName(), Level__c = logLevel.name()))
                .filter(new IsActiveLogLevel(logLevel))
                .forEach(new WriteLog(logLevel, component, body, relatedTo));
    }

    private class IsActiveLogLevel implements BooleanFunction {

        private LoggingLevel logLevel;

        public IsActiveLogLevel(LoggingLevel logLevel) {
            this.logLevel = logLevel;
        }

        public Boolean isTrueFor(Object o) {
            Log_Setting__mdt thisSetting = (Log_Setting__mdt)o;
            return logLevel.ordinal() >= Logger.logLevelToPriority.get(thisSetting.Level__c);
        }
    }

    private class WriteLog implements VoidFunction {

        private System.LoggingLevel logLevel;
        private String component;
        private Object body;
        private Id relatedTo;

        public WriteLog(System.LoggingLevel logLevel, String component, Object body, Id relatedTo) {
            this.logLevel = logLevel;
            this.component = component;
            this.body = body;
            this.relatedTo = relatedTo;
        }

        public void call(Object o) {
            Log_Setting__mdt thisSetting = (Log_Setting__mdt)o;
            getLogMethod(thisSetting.LogMethod_Class__c).log(logLevel, component, body, relatedTo);
        }
    }

    /**
     * @description Commits all pending logs to their respective log methods
     */
    global static void commitLogs() {
        for(LogMethodObject thisActiveMethod : activeLogMethods.values()) {
            thisActiveMethod.commitLogs();
        }
    }

    private static LogMethodObject getLogMethod(String logMethodName) {
        LogMethodObject activeLogMethod = activeLogMethods.get(logMethodName);
        if(activeLogMethod == null) {
            Type logMethodType = TypeLoader.getType(logMethodName);

            if (logMethodType == null) {
                throw new ClassNotFoundException('No log method found matching class name ' + logMethodName + '. Is the class global? Does it include any required namespace?');
            }

            Object newInstance = logMethodType.newInstance();
            if(newInstance instanceof LogMethodObject) {
                activeLogMethod = ((LogMethodObject)newInstance);
            } else {
                activeLogMethod = new LogMethodToLogMethodObject((LogMethod)newInstance);
            }

            activeLogMethods.put(logMethodName, activeLogMethod);
        }
        return activeLogMethod;
    }

    @TestVisible
    private static List<Log_Setting__mdt> logSettings {get {
        if(logSettings == null) {
            logSettings = [
                    SELECT Component__c, User_Id__c, Level__c, LogMethod_Class__c
                    FROM Log_Setting__mdt
            ];
        }
        return logSettings;
    } set;}

    private static SObjectIndex componentToLogSetting {get {
        if(componentToLogSetting == null) {
            componentToLogSetting = new SObjectIndex(Log_Setting__mdt.Component__c).putAll(logSettings);
        }
        return componentToLogSetting;
    } set;}


    private static Map<String, Integer> logLevelToPriority {get {
        if(logLevelToPriority == null) {
            logLevelToPriority = new Map<String, Integer>();
            List<LoggingLevel> logLevels = LoggingLevel.values();

            for(Integer i=0; i < logLevels.size(); i++) {
                logLevelToPriority.put(logLevels[i].name(), logLevels[i].ordinal());
            }
        }
        return logLevelToPriority;
    } set;}

    private static Map<String, LogMethodObject> activeLogMethods = new Map<String, LogMethodObject>();
}