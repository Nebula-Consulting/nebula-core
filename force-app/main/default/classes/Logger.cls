/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-19
 */

global without sharing class Logger {

    global static void log(System.LoggingLevel logLevel, String component, String body) {
        log(logLevel, component, body, null);
    }

    global static void log(System.LoggingLevel logLevel, String component, String body, Id relatedTo) {
        Log_Setting__mdt thisSetting = componentToLogSetting.get(component);
        if(thisSetting == null) {
            thisSetting = new Log_Setting__mdt(LogMethod_Class__c = DebugLogger.class.getName(), Level__c = logLevel.name());
        }

        if(logLevel.ordinal() >= logLevelToPriority.get(thisSetting.Level__c)) {
            getLogMethod(thisSetting.LogMethod_Class__c).log(logLevel, component, body, relatedTo);
        }
    }

    global static void commitLogs() {
        for(LogMethod thisActiveMethod : activeLogMethods.values()) {
            thisActiveMethod.commitLogs();
        }
    }

    private static LogMethod getLogMethod(String logMethodName) {
        LogMethod activeLogMethod = activeLogMethods.get(logMethodName);
        if(activeLogMethod == null) {
            Type logMethodType = TypeLoader.getType(logMethodName);
            if (logMethodType == null) {
                throw new ClassNotFoundException('No log method found matching class name ' + logMethodName + '. Is the class global? Does it include any required namespace?');
            }
            activeLogMethod = ((LogMethod) logMethodType.newInstance());
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

    private static Map<String, Log_Setting__mdt> componentToLogSetting {get {
        if(componentToLogSetting == null) {
            componentToLogSetting = new Map<String, Log_Setting__mdt>();
            for(Log_Setting__mdt thisSetting : logSettings) {
                componentToLogSetting.put(thisSetting.Component__c, thisSetting);
            }
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

    private static Map<String, LogMethod> activeLogMethods = new Map<String, LogMethod>();
}