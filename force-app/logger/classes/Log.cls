/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/04/2020
 * @description Drop a logger in wherever a function might go. Passes through the data and logs it
 */
global class Log implements Function {

    private LoggingLevel level = LoggingLevel.DEBUG;
    private String component;
    private final String formatString;
    private Function mapBeforeOutput = new IdentityFunction();
    private Function relatedTo = new ConstantFunction(null);

    /**
     * @description Creates a Log function with the specified format string
     * @param formatString The format string for log messages (uses String.format)
     */
    global Log(String formatString) {
        this.formatString = formatString;
    }

    /**
     * @description Sets the component name for the log
     * @param component The component name
     * @return This Log instance for method chaining
     */
    global Log setComponent(String component) {
        this.component = component;
        return this;
    }

    /**
     * @description Sets a function to transform the value before logging
     * @param mapBeforeOutput Function to apply before logging
     * @return This Log instance for method chaining
     */
    global Log setMapBeforeOutput(Function mapBeforeOutput) {
        this.mapBeforeOutput = mapBeforeOutput;
        return this;
    }

    /**
     * @description Sets a function to determine the related record Id
     * @param relatedTo Function that returns the related record Id
     * @return This Log instance for method chaining
     */
    global Log setRelatedTo(Function relatedTo) {
        this.relatedTo = relatedTo;
        return this;
    }

    /**
     * @description Sets a constant related record Id
     * @param relatedTo The related record Id or value
     * @return This Log instance for method chaining
     */
    global Log setRelatedTo(Object relatedTo) {
        this.relatedTo = new ConstantFunction(relatedTo);
        return this;
    }

    /**
     * @description Sets the logging level
     * @param level The logging level (DEBUG, INFO, WARN, ERROR, etc.)
     * @return This Log instance for method chaining
     */
    global Log setLoggingLevel(LoggingLevel level) {
        this.level = level;
        return this;
    }

    /**
     * @description Logs the value and passes it through unchanged
     * @param o The value to log
     * @return The same value passed in
     */
    global Object call(Object o) {
        Logger.log(
                level,
                component,
                String.format(formatString, new List<Object>{mapBeforeOutput.call(o)}),
                String.valueOf(relatedTo.call(o))
        );
        return o;
    }
}