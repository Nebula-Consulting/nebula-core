## Logging with the Logger class

The [Logger](force-app/main/default/classes/Logger.cls) provides a single entry point for writing logs, and uses Custom Metadata records to configure how/when logs are written.

Each log is written with one of the following two methods:

```
void log(System.LoggingLevel logLevel, String component, String body)
```

```
void log(System.LoggingLevel logLevel, String component, String body,  Id relatedTo)
```

Where `component` is your own reference for the component writing the log (e.g. a class, a functional module - however you want to break down your application into components).

What happens next depends on the configuration of the Log Setting custom metadata record. For each Log_Setting__mdt which matches on component and is of an applicable log level, an instance of the provided LogMethod_Class__c is run to do the logging. 

If no applicable setting is found, a default logger which prints with `System.debug` is used.