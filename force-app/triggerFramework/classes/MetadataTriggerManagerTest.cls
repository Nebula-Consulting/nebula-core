/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-04
 */

@IsTest
private class MetadataTriggerManagerTest {

    public static Set<String> lastNamesSeen = new Set<String>();

    public class TestHandler implements AfterDelete, AfterInsert, AfterUndelete, AfterUpdate, BeforeDelete, BeforeInsert, BeforeUpdate {

        public void handleAfterDelete(List<Contact> oldList) {
            handle(oldList);
        }

        public void handleAfterInsert(List<Contact> newList) {
            handle(newList);
        }

        public void handleAfterUndelete(List<Contact> newList) {
            handle(newList);
        }

        public void handleAfterUpdate(List<SObject> oldList, List<SObject> newList) {
            handle(newList);
        }

        public void handleBeforeDelete(List<Contact> oldList) {
            handle(oldList);
        }

        public void handleBeforeInsert(List<Contact> newList) {
            handle(newList);
        }

        public void handleBeforeUndelete(List<Contact> newList) {
            handle(newList);
        }

        public void handleBeforeUpdate(List<SObject> oldList, List<SObject> newList) {
            handle(newList);
        }

        private void handle(List<Contact> aList) {
            for(Contact c : aList) {
                MetadataTriggerManagerTest.lastNamesSeen.add(c.LastName);
            }
        }
    }

    @IsTest
    public static void basic() {
        MetadataTriggerManager.mockMetadata = new List<Trigger_Handler__mdt>();

        for(TriggerOperation thisTriggerOperation : TriggerOperation.values()) {
            MetadataTriggerManager.mockMetadata.add(new Trigger_Handler__mdt(
                Event__c = thisTriggerOperation.name(),
                    SObject__c = 'Contact',
                    Apex_Class__c = MetadataTriggerManagerTest.TestHandler.class.getName()
            ));
        }

        MetadataTriggerManager manager = new MetadataTriggerManager(Contact.SObjectType);

        String lastName = 'Simpson';

        List<Contact> contactList = new List<Contact>{new Contact(LastName = lastName)};

        for(TriggerOperation thisTriggerOperation : TriggerOperation.values()) {
            lastNamesSeen = new Set<String>();
            manager.handle(thisTriggerOperation, contactList, contactList);

            System.assert(lastNamesSeen.contains(contactList[0].LastName));
        }

    }

    @IsTest
    public static void noSuchHandler() {

        MetadataTriggerManager.mockMetadata = new List<Trigger_Handler__mdt>{
                new Trigger_Handler__mdt(
                        Event__c = TriggerOperation.AFTER_UPDATE.name(),
                        SObject__c = 'Contact',
                        Apex_Class__c = 'NoSuchClass'
                )
        };

        MetadataTriggerManager manager = new MetadataTriggerManager(Contact.SObjectType);

        String lastName = 'Simpson';

        List<Contact> contactList = new List<Contact>{new Contact(LastName = lastName)};

        try {
            manager.handle(TriggerOperation.AFTER_UPDATE, contactList, contactList);
        } catch(ClassNotFoundException e) {
            // expected this!
            return;
        }

        System.assert(false, 'Expected a ClassNotFoundException');
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // Just testing that there is no exception
    @IsTest
    public static void noHandlers() {

        MetadataTriggerManager.mockMetadata = new List<Trigger_Handler__mdt>();

        MetadataTriggerManager manager = new MetadataTriggerManager(Contact.SObjectType);

        String lastName = 'Simpson';

        List<Contact> contactList = new List<Contact>{new Contact(LastName = lastName)};

        manager.handle(TriggerOperation.AFTER_UPDATE, contactList, contactList);
        // no result
    }
}