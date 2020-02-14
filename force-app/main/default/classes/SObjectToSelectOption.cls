/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/02/2020
 * @description Converts an SObject to a SelectOption for use in Visualforce
 */

public with sharing class SObjectToSelectOption implements nebc.Function {

    private nebc.Function valueFunction;
    private nebc.Function labelFunction;

    public SObjectToSelectOption(nebc.Function valueFunction, nebc.Function labelFunction) {
        this.valueFunction = valueFunction;
        this.labelFunction = labelFunction;
    }

    public SObjectToSelectOption(SObjectField valueField, SObjectField labelField) {
        this.valueFunction = new nebc.FieldFromSObject(valueField);
        this.labelFunction = new nebc.FieldFromSObject(labelField);
    }

    public SObjectToSelectOption() {
        this.valueFunction = new nebc.FieldFromSObjectString('Id');
        this.labelFunction = new nebc.FieldFromSObjectString('Name');
    }

    public Object call(Object o) {
        return new SelectOption((String)valueFunction.call(o), (String)labelFunction.call(o));
    }
}