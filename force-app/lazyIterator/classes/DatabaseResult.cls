/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/09/2020
 * @description Common interface to bring together Database.SaveResult, Database.UpsertResult and so on
 */

global interface DatabaseResult {
    SObject getRecord();
    Boolean isSuccess();
    List<Database.Error> getErrors();
}