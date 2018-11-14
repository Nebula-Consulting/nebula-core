/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/11/2018
 */
@IsTest
public class TestObjectGenerator {

    private Account testAccount;
    private Contact testContact;
    private Lead testLead;

    public virtual Account getAccount() {
        if(testAccount == null) {
            testAccount = getAccountNoInsert();
            insert testAccount;
        }

        return testAccount;
    }

    public virtual Account getAccountNoInsert() {
        return new Account(Name = 'Test Account');
    }

    public virtual Contact getContact() {
        if(testContact == null) {
            testContact = getContactNoInsert();
            insert testContact;
        }

        return testContact;
    }

    public virtual Contact getContactNoInsert() {
        return new Contact(LastName = 'Test Contact LastName', AccountId = getAccount().Id);
    }

    public virtual Lead getLead() {
        if(testLead == null) {
            testLead = getLeadNoInsert();
            insert testLead;
        }

        return testLead;
    }

    public virtual Lead getLeadNoInsert() {
        return new Lead(LastName = 'Test Lead LastName', Company = 'Test Lead Company');
    }
}