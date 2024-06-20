/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-05
 */
global class SObjectAddError implements nebc.VoidFunction {

    private String errorLabel;

    global SObjectAddError(String errorLabel) {
        this.errorLabel = errorLabel;
    }

    global void call(Object o) {
        ((SObject)o).addError(errorLabel);
    }
}
