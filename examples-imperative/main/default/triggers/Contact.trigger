/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 */

trigger Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new MetadataTriggerManager(Contact.SObjectType).handle();
}