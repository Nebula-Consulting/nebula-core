/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 03/02/2021
 * @description Calls String.format() on the given format string. The string should contains {0} to inject
 * the value provided to call(Object o)
 */
global class StringFormat implements Function {

    private String formatString;

    global StringFormat(String formatString) {
        this.formatString = formatString;
    }

    global Object call(Object o) {
        return String.format(formatString, new List<String>{String.valueOf(o)});
    }
}