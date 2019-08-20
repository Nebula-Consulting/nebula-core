/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description Counts the number of Contacts and rolls up to Account.Number_Of_Contacts__c
 */

global without sharing class ContactNumberOfContactsRollUp implements nebc.AfterInsert, nebc.AfterUpdate, nebc.AfterDelete, nebc.AfterUndelete {

    public void handleAfterInsert(List<Contact> newList) {
        handleAllContacts(newList);
    }

    public void handleAfterUpdate(List<Contact> oldList, List<Contact> newList) {
        Set<Id> accountIds = new Set<Id>();
        for(Integer i=0; i < newList.size(); i++) {
            Contact oldContact = oldList[i];
            Contact newContact = newList[i];

            if(oldContact.AccountId != newContact.AccountId) {
                accountIds.add(oldContact.AccountId);
                accountIds.add(newContact.AccountId);
            }
        }
        updateAccountRollUps(accountIds);
    }

    public void handleAfterDelete(List<Contact> oldList) {
        handleAllContacts(oldList);
    }

    public void handleAfterUndelete(List<Contact> newList) {
        handleAllContacts(newList);
    }

    private void handleAllContacts(List<Contact> contacts) {
        Set<Id> accountIds = new Set<Id>();
        for(Contact thisContact : contacts) {
            accountIds.add(thisContact.AccountId);
        }
        updateAccountRollUps(accountIds);
    }

    private void updateAccountRollUps(Set<Id> accountIds) {
        accountIds.remove(null);

        if(!accountIds.isEmpty()) {
            nebc.SObjectIndex accountIdToContactCount = new nebc.SObjectIndex('AccountId')
                    .putAll([
                            SELECT COUNT(Id) contactCount,
                                    AccountId
                            FROM Contact
                            WHERE AccountId IN :accountIds
                            GROUP BY AccountId
                    ]);

            List<Account> accountsToUpdate = new List<Account>();
            for(Id thisAccountId : accountIds) {
                Account thisAccountToUpdate = new Account(Id = thisAccountId, Number_of_Contacts__c = 0);
                AggregateResult thisContactCount = (AggregateResult)accountIdToContactCount.get(thisAccountId);
                if(thisContactCount != null) {
                    thisAccountToUpdate.Number_of_Contacts__c = (Decimal)thisContactCount.get('contactCount');
                }
                accountsToUpdate.add(thisAccountToUpdate);
            }
            update accountsToUpdate;
        }
    }
}