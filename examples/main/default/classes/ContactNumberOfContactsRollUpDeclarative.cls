/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description Counts the number of Contacts and rolls up to Account.Number_Of_Contacts_Declarative__c
 */

global without sharing class ContactNumberOfContactsRollUpDeclarative implements nebc.AfterInsert, nebc.AfterUpdate, nebc.AfterDelete, nebc.AfterUndelete {

    public void handleAfterInsert(List<Contact> newList) {
        updateAccountRollUps(new nebc.LazySObjectIterator(newList));
    }

    public void handleAfterUpdate(List<Contact> oldList, List<Contact> newList) {
        updateAccountRollUps(new nebc.LazyTriggerContextPairIterator(oldList, newList)
                .filter(new nebc.IsFieldChangedInTrigger(Contact.AccountId))
                .expand(new nebc.TriggerContextPairExpandToBoth()));
    }

    public void handleAfterDelete(List<Contact> oldList) {
        updateAccountRollUps(new nebc.LazySObjectIterator(oldList));
    }

    public void handleAfterUndelete(List<Contact> newList) {
        updateAccountRollUps(new nebc.LazySObjectIterator(newList));
    }

    private void updateAccountRollUps(nebc.LazyIterator contacts) {
        Set<Id> accountIds = contacts
                .mapValues(new nebc.FieldFromSObject(Contact.AccountId))
                .filter(new nebc.IsNotNull())
                .toSet(new Set<Id>());

        if(!accountIds.isEmpty()) {
            update new nebc.LazyIdIterator(accountIds.iterator())
                    .mapValues(new AccountWithNumberOfContactsFromAccountId(accountIds))
                    .toList(new List<Account>());
        }
    }

    private class AccountWithNumberOfContactsFromAccountId implements nebc.Function {

        private nebc.SObjectIndex accountIdToContactCount;

        public AccountWithNumberOfContactsFromAccountId(Set<Id> accountIds) {
            accountIdToContactCount = new nebc.SObjectIndex('AccountId')
                    .putAll([
                            SELECT COUNT(Id) contactCount,
                                    AccountId
                            FROM Contact
                            WHERE AccountId IN :accountIds
                            GROUP BY AccountId
                    ]);
        }
        public Object call(Object o) {
            Account thisAccountToUpdate = new Account(Id = (Id)o, Number_of_Contacts_Declarative__c = 0);
            AggregateResult thisContactCount = (AggregateResult)accountIdToContactCount.get(thisAccountToUpdate.Id);
            if(thisContactCount != null) {
                thisAccountToUpdate.Number_of_Contacts_Declarative__c = (Decimal)thisContactCount.get('contactCount');
            }
            return thisAccountToUpdate;
        }
    }
}