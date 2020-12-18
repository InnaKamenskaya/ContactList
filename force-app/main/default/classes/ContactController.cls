public with sharing class ContactController {

    private static final Integer MAX_CONTACTS = 50000;

    @AuraEnabled(cacheable = true)
    public static List<Contact> getAllContacts(){
        return [SELECT Id, FirstName, LastName, a.Name, Phone, Email
        FROM Contact c, c.Account a            
        WITH SECURITY_ENFORCED ORDER BY LastName LIMIT :MAX_CONTACTS];
    }

    @AuraEnabled
    public static List<Contact> deleteContacts(List<Contact> selectedContacts){
        if (selectedContacts == null) {
            return null;
        }
        List<Case> updateCases = new List<Case>();
        for (Case updateCase : [SELECT Id, ContactId FROM Case WHERE ContactId IN :selectedContacts]) {            
            updateCase.ContactId = null;
            updateCases.add(updateCase);            
        }
        update updateCases;
        delete selectedContacts;
        return selectedContacts;      
    }
}