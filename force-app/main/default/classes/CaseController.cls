public with sharing class CaseController {

    @AuraEnabled(cacheable=false)
    public static List<Case> findAllAccountCasesByContactId(Id contactId){
        try {
            Contact source = [SELECT Id, AccountId From Contact WHERE Id = :contactId];
            List<Case> caseList = [SELECT Id, ContactId, Status FROM Case c, c.Contact con WHERE con.AccountId = :source.AccountId];
            return caseList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = false)
    public static List<Case> findCasesByContactId(List<Case> accountCases, Id contactId, List<String> caseStatuses){
        try {
            List<Case> result = new List<Case>();
            if (accountCases.size() == 0) {
                result = null;
            }
             for(String str : caseStatuses){
                for (Case c : accountCases) {
                    if (c.ContactId == contactId && c.Status.equals(str)) {
                       result.add(c); 
                    }
                }                   
            }              
            return result;        
        } catch (Exception e) {
            throw new AuraHandledException('Could not find cases by ContactId:' + contactId + ', reason: ' + e.getMessage());
        }
    }  
}
