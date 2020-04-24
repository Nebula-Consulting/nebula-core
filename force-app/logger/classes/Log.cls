/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/04/2020
 * @description Drop a logger in wherever a function might go. Passes through the data and logs it
 */

global class Log implements Function {

    private LoggingLevel level = LoggingLevel.DEBUG;
    private String component;
    private String formatString;
    private Function mapBeforeOutput = new IdentityFunction();

    global Log(String formatString) {
        this.formatString = formatString;
    }

    global Log setComponent(String component) {
        this.component = component;
        return this;
    }

    global Log setMapBeforeOutput(Function mapBeforeOutput) {
        this.mapBeforeOutput = mapBeforeOutput;
        return this;
    }

    global Log setLoggingLevel(LoggingLevel level) {
        this.level = level;
        return this;
    }

    global Object call(Object o) {
        Logger.log(level, component, String.format(formatString, new List<Object>{mapBeforeOutput.call(o)}));
        return o;
    }
}