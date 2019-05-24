/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-05-24
 * @description Custom exceptions do not include stack traces (https://success.salesforce.com/issues_view?id=a1p300000008dVIAAY)
 * This works around that
 */

global abstract class StackTraceException extends Exception {

    private String stackTrackString = createStackTraceString();

    private String createStackTraceString() {
        stackTrackString = new DmlException().getStackTraceString();
        // The first thee lines are this method, the Exception constructor, and the subclass. So, discard them
        return stackTrackString.replaceFirst('(?m)(.*\\n){3}?', '');
    }

    public override String getStackTraceString() {
        return stackTrackString;
    }
}