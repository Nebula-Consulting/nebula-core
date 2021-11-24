/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/11/2021
 */

global class IsRegexMatch implements BooleanFunction {

    private Pattern regexToMatch;

    global IsRegexMatch(String regexToMatch) {
        this.regexToMatch = Pattern.compile(regexToMatch);
    }

    global Boolean isTrueFor(Object o) {
        return regexToMatch.matcher((String)o).matches();
    }
}