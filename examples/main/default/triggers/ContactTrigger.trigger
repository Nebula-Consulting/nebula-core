/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 */

trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new nebc.MetadataTriggerManager(Contact.SObjectType).handle();
}
