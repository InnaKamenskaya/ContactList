public with sharing class CaseController {

    @AuraEnabled(cacheable=false)
    public static List<Case> findAllAccountCasesByContactId(Id contactId){
        try {
            Contact c = [SELECT Id, AccountId From Contact WHERE Id = :contactId];
            List<Case> caseList = [SELECT Id, ContactId, Status FROM Case c, c.Contact con WHERE con.AccountId = :c.AccountId];
            return caseList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Case> findCasesByContactId(List<Case> accountCases, Id contactId){
        try {
            List<Case> result = new List<Case>();
              if (accountCases.size() == 0) {
                  result = null;
              } else {
                  for (Case c : accountCases) {
                      if (c.ContactId == contactId) {
                         result.add(c); 
                      }
                  }
              }
              return result;        
        } catch (Exception e) {
            throw new AuraHandledException('Could not find cases by ContactId:' + contactId + ', reason: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable = false)
    public static List<Case> findUnclosedCasesByContactId(List<Case> accountCases, Id contactId){
        try {    
            List<Case> result = new List<Case>();        
            if (accountCases.size() == 0) {
                return null;
            }else {
               for (Case c : accountCases) {
                   if (!(c.Status.equals('Closed')) && c.ContactId == contactId) {
                       result.add(c);
                   }
               }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Could not find unclosed cases by ContactId:' + contactId + ', reason: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Case> findClosedCasesByContactId(List<Case> accountCases, Id contactId){
        try {    
            List<Case> result = new List<Case>();        
            if (accountCases.size() == 0) {
                return null;
            }else {
               for (Case c : accountCases) {
                   if (c.Status.equals('Closed') && c.ContactId == contactId) {
                       result.add(c);
                   }
               }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Could not find closed cases by ContactId:' + contactId + ', reason: ' + e.getMessage());
        }
    }
}
