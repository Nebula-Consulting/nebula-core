/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 */

@IsTest
private class ContactNumberOfContactsRollUpTest {

    static nebc.TestRecordSource testRecordSource = new nebc.TestRecordSource();
    static Account testAccount = (Account)testRecordSource.getRecord(Account.SObjectType).withInsert();

    @IsTest
    static void testInsert() {
        Integer nContacts = 3;

        Test.startTest();
        testRecordSource.getRecord(Contact.SObjectType).withInsert(nContacts);
        Test.stopTest();

        testAccount = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(nContacts, testAccount.Number_of_Contacts__c);
    }
    @IsTest
    static void testUpdateTransfer() {
        nebc.TestRecordSource testRecordSource2 = new nebc.TestRecordSource();
        Account testAccount2 = (Account)testRecordSource2.getRecord(Account.SObjectType).withInsert();

        Integer nContacts = 3;
        List<Contact> testContacts = testRecordSource.getRecord(Contact.SObjectType).withInsert(nContacts);

        Test.startTest();
        testContacts[0].AccountId = testAccount2.Id;
        update testContacts[0];
        Test.stopTest();

        testAccount = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        testAccount2 = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :testAccount2.Id];
        System.assertEquals(nContacts-1, testAccount.Number_of_Contacts__c);
        System.assertEquals(1, testAccount2.Number_of_Contacts__c);
    }
    @IsTest
    static void testUpdateBecomesNull() {
        Integer nContacts = 3;

        List<Contact> testContacts = testRecordSource.getRecord(Contact.SObjectType).withInsert(nContacts);

        Test.startTest();
        testContacts[0].AccountId = null;
        update testContacts[0];
        Test.stopTest();

        testAccount = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(nContacts-1, testAccount.Number_of_Contacts__c);
    }
    @IsTest
    static void testUpdateFromNull() {
        Integer nContacts = 3;

        List<Contact> testContacts = testRecordSource.getRecord(Contact.SObjectType).withoutInsert(nContacts);
        testContacts[0].AccountId = null;
        insert testContacts;

        testAccount = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(nContacts-1, testAccount.Number_of_Contacts__c);

        Test.startTest();
        testContacts[0].AccountId = testAccount.Id;
        update testContacts[0];
        Test.stopTest();

        testAccount = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(nContacts, testAccount.Number_of_Contacts__c);
    }
}