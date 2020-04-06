## Trigger Handlers with MetadataTriggerManager

A trigger handling framework configured by custom metadata records. 

A trigger implemented in the framework requires three things:

 1. A trigger on the relevant object, invoking the framework's handler class [MetadataTriggerManager](classes/MetadataTriggerManager.cls) e.g. [ContactTrigger](../../examples/main/default/triggers/ContactTrigger.trigger). You only need one per object.    
 1. A class implementing some of the trigger handler interfaces   e.g. [ContactNumberOfContactsRollUp](../../examples/main/default/classes/ContactNumberOfContactsRollUp.cls) implements [AfterInsert](classes/AfterInsert.cls) and others.
 1. A metadata record telling the framework about your class e.g. [ContactNumberOfContactsRollUpAI](../../examples/main/default/customMetadata/Trigger_Handler.ContactNumberOfContactsRollUpAI.md-meta.xml)
 
### Notes

The actual trigger invoking the framework should handle all events, and pass in the `SObjectType`.

If you have multiple triggers on the same object, they should reside in separate classes to keep concerns separate.

Your trigger handler class should be `global`, or the framework won't be able to create an instance of it. It should 
probably also be `without sharing` so that it runs in system mode.

The metadata record includes an Order field. Triggers are run in ascending order on that field. When you don't care 
about order, you can leave this as 0. Negative numbers are acceptable, so if you have some triggers at 0 and need to add
one which runs before them, you can make it -10.  
