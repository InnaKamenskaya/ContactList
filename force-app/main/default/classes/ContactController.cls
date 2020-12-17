public with sharing class ContactController {

    public class NewExecutorNotFoundException extends Exception{}
    private static Integer maxCases = 0;
    private static final Integer MAX_CONTACTS = 50000;
    private static final String ERROR_MESSAGE = 'first error: DELETE_FAILED, Your attempt to delete contact with Id {0} could not be completed because it is associated with some cases';
    @testVisible
    private static String errorMessageTest = '';

    @AuraEnabled(cacheable = true)
    public static List<Contact> getAllContacts(){
        return [SELECT Id, FirstName, LastName, a.Name, Phone, Email
        FROM Contact c, c.Account a            
        WITH SECURITY_ENFORCED ORDER BY LastName LIMIT :MAX_CONTACTS];
    }

    @AuraEnabled(cacheable = false)
    public static List<Contact> start(List<Contact> selectedContacts){
        if (selectedContacts == null) {
            return null;
        }else {            
                List<Id> accountsId = getAccountsId(selectedContacts);
                Map <Id, List<Contact>> accountToContacts = getColleagues(selectedContacts, accountsId);
                List<Id> allContactsId = getAllContactsId(selectedContacts, accountToContacts);
                Map<Id, List<Case>> contactToCases = getAllCases(allContactsId);
                Map<Id, List<Case>> delContactsToCases = getSpecificContactsWithCases(true, contactToCases, selectedContacts);
                Map<Id, List<Case>> stayContactsToCases = getSpecificContactsWithCases(false, contactToCases, selectedContacts);
            try {
                List<Case> updateCases = new List<Case>();               
                for(Id delContactId : delContactsToCases.keySet()){
                    if(delContactsToCases.get(delContactId).size() != 0){
                        Contact delContact = new Contact();
                        for(Contact con : selectedContacts){
                            if(delContactId == con.Id){
                                delContact = con;
                            }
                        }
                        List<Contact> colleagues = accountToContacts.get(delContact.AccountId);
                        if (colleagues == null || colleagues.isEmpty()) {
                            String message = String.format(ERROR_MESSAGE, new List<Object>{delContactId});
                            throw new NewExecutorNotFoundException(message);
                        } else {
                            Contact newExecutor = getNewExecutor(colleagues, stayContactsToCases);
                            for(Case contactCase : delContactsToCases.get(delContactId)){                                
                                contactCase.ContactId = newExecutor.Id;
                                updateCases.add(contactCase);
                            }
                        }
                    }                
                } 
                update updateCases;
                delete selectedContacts;    
                return selectedContacts;    
            } catch (Exception e) {
                String message = e.getMessage();                
                AuraHandledException ex = new AuraHandledException(message);
                if(Test.isRunningTest()){ 
                    errorMessageTest = message;
                }
                throw ex;
            }
        }       
    }

    private static List<Id> getAccountsId(List<Contact> contactsToDelete){
        Set<Id> accountsId = new Set<Id>();
        for (Contact delContact : contactsToDelete) {
            if (delContact.AccountId != null) {
                accountsId.add(delContact.AccountId);
            }            
        }
        return new List<Id>(accountsId);
    }

    private static Map<Id, List<Contact>> getColleagues(List<Contact> contactsToDelete, List<Id> accountsId){
        List<Contact> colleagues = [SELECT Id, AccountId FROM Contact c WHERE c.AccountId IN :accountsId AND Id NOT IN :contactsToDelete];
        Map<Id, List<Contact>> accountsToContacts = new Map<Id, List<Contact>>();
        for (Contact coll : colleagues) {
            if (accountsToContacts.containsKey(coll.AccountId)) {
                List<Contact> tmp = accountsToContacts.get(coll.AccountId);
                tmp.add(coll);
            }else {
                accountsToContacts.put(coll.AccountId, new List<Contact>{coll});
            }
        }        
        return accountsToContacts;
    }

    private static List<Id> getAllContactsId(List<Contact> delContacts, Map<Id, List<Contact>> accountToContacts){
        List<Id> allContactsId = new List<Id>();
        List<Contact> tempContacts = new List<Contact>();
        for(List<Contact> temp : accountToContacts.values()){
            tempContacts.addAll(temp);
        }
        tempContacts.addAll(delContacts);
        return new List<Id>(new Map<Id, Contact>(tempContacts).keySet());
    }

    private static Map<Id, List<Case>> getAllCases(List<Id> allContactsId){
        Map<Id, List<Case>> contactToCases = new Map<Id, List<Case>>();
        for(Contact con : [SELECT Id, (SELECT Id, Status, ContactId FROM Cases) FROM Contact WHERE Id IN :allContactsId]){
            contactToCases.put(con.Id, con.Cases);
            if(con.Cases.size() > maxCases){
                maxCases = con.Cases.size();
            }
        }            
        return contactToCases;
    }

    private static Map<Id, List<Case>> getSpecificContactsWithCases(Boolean check, Map<Id, List<Case>> contactToCases, List<Contact> delContacts){
        List<Id> delContactsId = new List<Id>();
        for (Contact con : delContacts) {
            delContactsId.add(con.Id);
        }
        Map<Id, List<Case>> specContactToCases = new Map<Id, List<Case>>();
        Map<Id, List<Case>> del = new Map<Id, List<Case>>();
        Map<Id, List<Case>> stay = new Map<Id, List<Case>>();
        for(Id contactId : contactToCases.keySet()){
            if (delContactsId.contains(contactId)) {
                del.put(contactId, contactToCases.get(contactId));
            }else {
                stay.put(contactId, contactToCases.get(contactId));
            }            
        }
        specContactToCases = check ? del : stay;        
        return specContactToCases;
    }

   private static Contact getNewExecutor(List<Contact> coll, Map<Id, List<Case>> stayContactsToCases){
        Integer min = maxCases;
        Contact newExecutor = new Contact();
        for(Contact con : coll){
            if(stayContactsToCases.get(con.Id).size() <= min){
                min = stayContactsToCases.get(con.Id).size();
                newExecutor = con;
            }
        }
        return newExecutor;
    }    
}