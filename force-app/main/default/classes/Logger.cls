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
            Type logMethodType = TypeLoader.getType(thisSetting.LogMethod_Class__c);
            if(logMethodType == null) {
                throw new ClassNotFoundException('No log method found matching class name ' + thisSetting.LogMethod_Class__c + '. Is the class global? Does it include any required namespace?');
            }
            ((LogMethod) logMethodType.newInstance()).log(logLevel, component, body, relatedTo);
        }
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
}