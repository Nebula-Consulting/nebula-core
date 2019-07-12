/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description Counts the number of Contacts and rolls up to Account.Number_Of_Contacts_Declarative__c
 */

global without sharing class ContactNumberOfContactsRollUpDeclarative implements AfterInsert, AfterUpdate, AfterDelete, AfterUndelete {

    public void handleAfterInsert(List<Contact> newList) {
        updateAccountRollUps(new LazySObjectIterator(newList));
    }

    public void handleAfterUpdate(List<Contact> oldList, List<Contact> newList) {
        updateAccountRollUps(new LazyTriggerContextPairIterator(oldList, newList)
                        .filter(new IsFieldChangedInTrigger(Contact.AccountId))
                        .expand(new TriggerContextPairExpandToBoth()));
    }

    public void handleAfterDelete(List<Contact> oldList) {
        updateAccountRollUps(new LazySObjectIterator(oldList));
    }

    public void handleAfterUndelete(List<Contact> newList) {
        updateAccountRollUps(new LazySObjectIterator(newList));
    }

    private void updateAccountRollUps(LazyIterator contacts) {
        Set<Id> accountIds = contacts
                .mapValues(new FieldFromSObject(Contact.AccountId))
                .filter(new IsNotNull())
                .toSet(new Set<Id>());

        if(!accountIds.isEmpty()) {
            update new LazyIdIterator(accountIds.iterator())
                    .mapValues(new AccountIdToAccountWithNumberOfContacts(accountIds))
                    .toList(new List<Account>());
        }
    }

    private class AccountIdToAccountWithNumberOfContacts implements Function {

        private SObjectIndex accountIdToContactCount;

        public AccountIdToAccountWithNumberOfContacts(Set<Id> accountIds) {
            accountIdToContactCount = new SObjectIndex('AccountId')
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