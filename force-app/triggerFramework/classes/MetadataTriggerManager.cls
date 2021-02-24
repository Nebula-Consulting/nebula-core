/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 * @description Use custom metadata to specify trigger handler classes to run, making the
* 	actual triggers into one-line pieces of code.
*
* 	Example:
*
* trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
* 	(new MetadataTriggerManager(Contact.sObjectType)).handle(Trigger.operationType);
* }
*
* 	Write your trigger handler by implementing the interfaces such as AfterInsert, then
* 	link it to the trigger by creating a Trigger_Handler__mdt custom metadata record for each
*	event when you handler needs to run.
*/

global with sharing class MetadataTriggerManager {

    // Don't really want this to be global, but other packages in the nebc namespace need to use it
    global static List<Trigger_Handler__mdt> mockMetadata;

    private SObjectIndex theseTriggers;
    private static SObjectIndex sObjectTypeNameToEventToTriggerList { get {
        if (sObjectTypeNameToEventToTriggerList == null) {
            sObjectTypeNameToEventToTriggerList = new SObjectIndex(Trigger_Handler__mdt.SObject__c, Trigger_Handler__mdt.Event__c)
                    .putAll(mockMetadata != null ? mockMetadata :
                            [
                                    SELECT DeveloperName, NamespacePrefix, Event__c, SObject__c, Apex_Class__c, Order__c,
                                            Parameters__c
                                    FROM Trigger_Handler__mdt
                                    WHERE Active__c = TRUE
                                    ORDER BY Order__c ASC
                            ]);
        }
        return sObjectTypeNameToEventToTriggerList;
    } set;}

    global MetadataTriggerManager(SObjectType objectType) {
        String sObjectName = objectType.getDescribe().getName();

        theseTriggers = sObjectTypeNameToEventToTriggerList.getSubIndex(sObjectName);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private void handleInstance(Object handlerInstance, TriggerOperation triggerOperation, List<SObject> oldList, List<SObject> newList){
        switch on triggerOperation {
            when BEFORE_UPDATE {
                ((BeforeUpdate)handlerInstance).handleBeforeUpdate(oldList, newList);
            }
            when BEFORE_INSERT {
                ((BeforeInsert)handlerInstance).handleBeforeInsert(newList);
            }
            when BEFORE_DELETE {
                ((BeforeDelete)handlerInstance).handleBeforeDelete(oldList);
            }
            when AFTER_UPDATE {
                ((AfterUpdate)handlerInstance).handleAfterUpdate(oldList, newList);
            }
            when AFTER_INSERT {
                ((AfterInsert)handlerInstance).handleAfterInsert(newList);
            }
            when AFTER_DELETE {
                ((AfterDelete)handlerInstance).handleAfterDelete(oldList);
            }
            when AFTER_UNDELETE {
                ((AfterUndelete)handlerInstance).handleAfterUndelete(newList);
            }
        }
    }

    global void handle() {
        handle(Trigger.operationType, Trigger.old, Trigger.new);
    }

    global void handle(TriggerOperation triggerOperation, List<SObject> oldList, List<SObject> newList) {
        if(theseTriggers == null) {
            return;
        }

        List<Trigger_Handler__mdt> handlerDescriptions = theseTriggers.getAll(triggerOperation.name());

        for(Trigger_Handler__mdt thisHandlerDescription : handlerDescriptions) {

            Type handlerType = TypeLoader.getType(thisHandlerDescription.Apex_Class__c);

            if(handlerType == null) {
                throw new ClassNotFoundException('MetadataTriggerManager: handler class not found for ' + thisHandlerDescription + '. Is it global? Does it need to include a namespace?');
            } else {
                Object handlerInstance;
                try {
                    handlerInstance = TypeLoader.getInstance(handlerType, thisHandlerDescription.Parameters__c);
                } catch (JSONException e) {
                    throw new JSONException('MetadataTriggerManager: handler class must be annotated with @JsonAccess(deserializable=\'always\')', e);
                }
                handleInstance(handlerInstance, triggerOperation, oldList, newList);
            }
        }
    }
}