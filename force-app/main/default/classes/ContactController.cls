public with sharing class ContactController {

    private static Integer maxCases = 0;
    private static Integer MAX_CONTACTS = 50000;

    @AuraEnabled(cacheable = true)
    public static List<Contact> getAllContacts(){
        return [SELECT Id, FirstName, LastName, a.Name, Phone, Email
        FROM Contact c, c.Account a            
        WITH SECURITY_ENFORCED ORDER BY LastName LIMIT :MAX_CONTACTS];
    }

    @AuraEnabled(cacheable = false)
    public static List<Contact> start(List<Contact> selectedContacts){
        if (selectedContacts.isEmpty()) {
            AuraHandledException e = new AuraHandledException('');
            e.setMessage('No one contacts are selected!');
            throw e;
        }else {
            try {
                List<Case> updateCases = new List<Case>();
                List<Id> accountsId = getAccountsId(selectedContacts);
                Map <Id, List<Contact>> accountToContacts = getColleagues(selectedContacts, accountsId);
                List<Id> allContactsId = getAllContactsId(selectedContacts, accountToContacts);
                Map<Contact, List<Case>> contactToCases = getAllCases(allContactsId);  
                
                          
                Map<Contact, List<Case>> delContactsToCases = getSpecificContactsWithCases(true, contactToCases, selectedContacts);
                Map<Contact,List<Case>> stayContactsToCases = getSpecificContactsWithCases(false, contactToCases, selectedContacts);
                
                for(Contact delContact : delContactsToCases.keySet()){
                    if(delContactsToCases.get(delContact).size() != 0){
                        List<Contact> colleagues = accountToContacts.get(delContact.AccountId);
                        if (colleagues == null || colleagues.isEmpty()) {
                            AuraHandledException e = new AuraHandledException('');
                            e.setMessage('first error: DELETE_FAILED, Your attempt to delete this contact could not be completed because it is associated with some cases');
                            throw e;
                        } else {
                            Contact newExecutor = getNewExecutor(colleagues, stayContactsToCases);
                            for(Case contactCase : delContactsToCases.get(delContact)){
                                
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
                throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
            }
        }       
    }

    private static List<Id> getAccountsId(List<Contact> contactsToDelete){
        Set<Id> accountsId = new Set<Id>();
        for (Contact delContact : contactsToDelete) {
            accountsId.add(delContact.AccountId);
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

    private static Map<Contact, List<Case>> getAllCases(List<Id> allContactsId){
        Map<Contact, List<Case>> contactToCases = new Map<Contact, List<Case>>();
        for(Contact con : [SELECT Id, AccountId, (SELECT Id, Status, ContactId FROM Cases) FROM Contact WHERE Id IN :allContactsId]){
            contactToCases.put(new Contact(Id = con.Id, AccountId = con.AccountId), con.Cases);
            if(con.Cases.size() > maxCases){
                maxCases = con.Cases.size();
            }
        }            
        return contactToCases;
    }

    private static Map<Contact, List<Case>> getSpecificContactsWithCases(Boolean check, Map<Contact, List<Case>> contactToCases, List<Contact> delContacts){
        Map<Contact, List<Case>> specContactToCases = new Map<Contact, List<Case>>();
        Map<Contact, List<Case>> del = new Map<Contact, List<Case>>();
        Map<Contact, List<Case>> stay = new Map<Contact, List<Case>>();
        for(Contact con : contactToCases.keySet()){
            if (delContacts.contains(con)) {
                del.put(con, contactToCases.get(con));
            }else {
                stay.put(con, contactToCases.get(con));
            }            
        }
        specContactToCases = check ? del : stay;
        return specContactToCases;
    }

   private static Contact getNewExecutor(List<Contact> coll, Map<Contact, List<Case>> stayContactsToCases){
        Integer min = maxCases;
        Contact newExecutor = new Contact();
        for(Contact con : coll){
            if(stayContactsToCases.get(con).size() <= min){
                min = stayContactsToCases.get(con).size();
                newExecutor = con;
            }
        }
        return newExecutor;
    }    
}
