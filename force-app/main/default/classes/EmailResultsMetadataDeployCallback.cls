/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-08
 * @description Emails the given address with the results of a metadata deployment (see
 * Metadata.Operations.enqueueDeployment)
 */

global class EmailResultsMetadataDeployCallback implements Metadata.DeployCallback{

    private String emailAddress;

    global EmailResultsMetadataDeployCallback(String emailAddress) {
        this.emailAddress = emailAddress;
    }

    global void handleResult(metadata.DeployResult deployResult, Metadata.DeployCallbackContext context) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new List<String>{emailAddress});
        message.setSubject('Metadata deployment complete: '
                + (deployResult.status == Metadata.DeployStatus.Succeeded ? 'Success' : 'Failed'));
        message.setPlainTextBody(JSON.serializePretty(deployResult));
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
    }
}