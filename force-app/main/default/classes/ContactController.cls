public with sharing class ContactController {

    private static Boolean check = true;

    @AuraEnabled
    public static List<Contact> start(List<Id> source){
        if(check){
            System.debug('Inside start method');
            return deleteContacts(source);
        }else{
            return bung(source);
        }
    }

    @AuraEnabled
    public static List<Contact> bung(Id[] lstConIds){
        try {
            list<Contact> lstConsToDelete = new list<Contact>();
            for(Id idCon : lstConIds) {
                lstConsToDelete.add(new Contact(Id = idCon));
            }
            if(!lstConsToDelete.isEmpty()) {
                delete lstConsToDelete;
            }
            return lstConsToDelete;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Contact> getAllContacts(){
        try {
            return [SELECT Id, FirstName, LastName, a.Name, Phone, Email
            FROM Contact c, c.Account a            
            WITH SECURITY_ENFORCED ORDER BY LastName LIMIT 20];
            
        } catch (Exception e) {
            throw new AuraHandledException('Could not get all contacts, reason: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Account findAccountByContactId(Id contactId){
        try {
            Contact temp = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId][0];
            Id accId = temp.AccountId;
            return new Account( Id = accId);
        } catch (Exception e) {
            throw new AuraHandledException('Could not find account by ContactId:' + contactId + ', reason: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Contact> deleteContacts(List<Id> source){
        List<Contact> delContacts = new List<Contact>();        
        try{
            for(Id contactId : source){
                List<Case> updatedCases = new List<Case>();
                List<Case> delCases = new List<Case>();
                List<Case> allAccountCases = CaseController.findAllAccountCasesByContactId(contactId);
                if(!isContactHasCases(allAccountCases, contactId)){
                    delContacts.add(new Contact(Id = contactId));
                }else if(!isContactHasUnclosedCases(allAccountCases, contactId)){
                    delCases.addAll(CaseController.findClosedCasesByContactId(allAccountCases, contactId));
                    delContacts.add(new Contact(Id = contactId));
                }else{          
                    List<Case> unclosedCases = CaseController.findUnclosedCasesByContactId(allAccountCases, contactId);
                    Contact newCaseExecutor = findContactWithMinCases(contactId);
                    if(newCaseExecutor == null){
                        delCases.addAll(unclosedCases);
                        delCases.addAll(CaseController.findClosedCasesByContactId(allAccountCases, contactId));
                        delContacts.add(new Contact(Id = contactId));
                    }else{                        
                        for (Case c : unclosedCases) {
                            c.ContactId = newCaseExecutor.Id;
                            updatedCases.add(c);
                        }
                        delCases.addAll(CaseController.findClosedCasesByContactId(allAccountCases, contactId));
                        delContacts.add(new Contact(Id = contactId)); 
                    }
                }
                if (!updatedCases.isEmpty()) {
                    update updatedCases;
                }
                if(!delCases.isEmpty()){
                    delete delCases;
                }              
            } 
            
            delete delContacts;
            return delContacts;
        } catch (Exception e) {
                throw new AuraHandledException(' delete Contacts' + e.getMessage() + e.getStackTraceString());
        }    
    }
    
    @AuraEnabled
    public static List<Contact> findContactColleagues(Id contactId){
        try {
            Account contactAccount = findAccountByContactId(contactId);
            return [
                SELECT Id FROM Contact WHERE AccountId = :contactAccount.Id AND Id != :contactId
            ];          
        } catch (Exception e) {
            throw new AuraHandledException('findContactColleagues' + e.getMessage());
        }
    }
    
    private static Boolean isContactHasUnclosedCases(List<Case> source, Id contactId){
        Boolean result = true;
        List<Case> unclosedCases = CaseController.findUnclosedCasesByContactId(source, contactId);
        if (unclosedCases == null) {
            result = false;
        }
        return result;
    } 

    private static Boolean isContactHasCases(List<Case> source, Id contactId){
        Boolean result = true;
        List<Case> contactCases = CaseController.findCasesByContactId(source, contactId);
        if (contactCases == null) {
            result = false;
        }
        return result;
    }

    private static Contact findContactWithMinCases (Id contactId){        
        List<Contact> source = findContactColleagues(contactId);        
        if (source.size() == 0) {
            return null;
        }else {   
            Contact result; 
            Map<Id, Contact> contactsWithCountCases = new Map<Id, Contact>(source);
            List<Contact> resList = [SELECT Id, (SELECT Id FROM Cases) FROM Contact WHERE Id IN :contactsWithCountCases.keySet()];
            Map<Contact, Integer> resMap = new Map<Contact, Integer>();
            for(Contact c : resList){
                resMap.put(c, c.Cases.size());
            }
            List<Contact> contactList = new List<Contact>(resMap.keySet());
            List<Integer> caseQuantity = resMap.values();
            Integer count = 2147483646;
            Integer tmp;
            for(Integer i = 0; i < caseQuantity.size(); i++){
                if (caseQuantity.get(i) < count) {
                    count = caseQuantity.get(i);
                    tmp = i;
                }
            }
            result = contactList.get(tmp);
           return result;
        }        
    }
}