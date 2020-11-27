public with sharing class ContactController {

    private static Integer maxCases = 0;

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

    @AuraEnabled(cacheable = false)
    public static List<Contact> start(List<String> frontSource){
        try {
            List<Case> updateCases = new List<Case>();
            List<Contact> source = getContactsFromFront(frontSource);
            List<Id> accountsId = getAccountsId(source);
            Map <Id, List<Contact>> accountsWithContacts = getColleagues(source, accountsId);
            List<Id> allContactsId = getAllContactsId(source, accountsWithContacts);
            Map<Contact, List<Case>> contactsWithCases = getAllCases(allContactsId);            
            Map<Contact, List<Case>> delContactsWithCases = getSpecificContactsWithCases(true, contactsWithCases, source);
            Map<Contact,List<Case>> stayContactsWithCases = getSpecificContactsWithCases(false, contactsWithCases, source);
            for(Contact c : delContactsWithCases.keySet()){
                if(delContactsWithCases.get(c).size() == 0){
                    continue;
                }else {
                    List<Contact> colleagues = accountsWithContacts.get(c.AccountId);
                    if (colleagues.size() == 0) {
                        throw new AuraHandledException('ACHAHCAHA');
                    } else {
                        Contact newExecutor = getNewExecutor(colleagues, stayContactsWithCases);
                        for(Case cs : delContactsWithCases.get(c)){
                            cs.ContactId = newExecutor.Id;
                            updateCases.add(cs);
                        }
                    }
                }                
            } 
            update updateCases;
            delete source;     
            return source;           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    private static List<Contact> getContactsFromFront(List<String> source){
        List<Contact> result = new List<Contact>();
        for(String str : source){
            List<String> strList = str.split(' ');
            Contact tmp = new Contact();
            tmp.Id = strList.get(0);
            tmp.AccountId = strList.get(1);
            result.add(tmp);
        }
        return result;
    }

    private static List<Id> getAccountsId(List<Contact> source){
        Set<Id> result = new Set<Id>();
        for (Contact c : source) {
            result.add(c.AccountId);
        }
        return new List<Id>(result);
    }

    private static Map<Id, List<Contact>> getColleagues(List<Contact> source, List<Id> accountsId){
        List<Contact> temp = [SELECT Id, AccountId FROM Contact c WHERE c.AccountId IN :accountsId AND Id NOT IN :source];
        Map<Id, List<Contact>> result = new Map<Id, List<Contact>>();
        for (Contact c : temp) {
            if (result.keySet().contains(c.AccountId)) {
                List<Contact> tmp = result.get(c.AccountId);
                tmp.add(c);
            }else {
                result.put(c.AccountId, new List<Contact>{c});
            }
        }        
        return result;
    }

    private static List<Id> getAllContactsId(List<Contact> delContacts, Map<Id, List<Contact>> accountWithContacts){
        List<Id> result = new List<Id>();
        List<Contact> tempContacts = new List<Contact>();
        for(List<Contact> temp : accountWithContacts.values()){
            tempContacts.addAll(temp);
        }
        tempContacts.addAll(delContacts);
        for(Contact c : tempContacts){
            result.add(c.Id);
        }
        return result;
    }

    private static Map<Contact, List<Case>> getAllCases(List<Id> allContactsId){
        List<Contact> allContacts = [SELECT Id, AccountId, (SELECT Id, Status, ContactId FROM Cases) FROM Contact WHERE Id IN :allContactsId];
        Map<Contact, List<Case>> result = new Map<Contact, List<Case>>();
        for(Contact c : allContacts){
            result.put(new Contact(Id = c.Id, AccountId = c.AccountId), c.Cases);
            if(c.Cases.size() > maxCases){
                maxCases = c.Cases.size();
            }
        }            
        return result;
    }

    private static Map<Contact, List<Case>> getSpecificContactsWithCases(Boolean check, Map<Contact, List<Case>> source, List<Contact> delContacts){
        Map<Contact, List<Case>> result = new Map<Contact, List<Case>>();
        Map<Contact, List<Case>> del = new Map<Contact, List<Case>>();
        Map<Contact, List<Case>> stay = new Map<Contact, List<Case>>();
        for(Contact c : source.keySet()){
            if (delContacts.contains(c)) {
                del.put(c, source.get(c));
            }else {
                stay.put(c, source.get(c));
            }            
        }
        if (check) {
            result = del;
        }else {
            result = stay;
        }
        return result;
    }


   private static Contact getNewExecutor(List<Contact> coll, Map<Contact, List<Case>> source){
        Integer min = maxCases;
        Contact result = new Contact();
        for(Contact c : coll){
            if(source.get(c).size() < min){
                result = c;
            }
        }
        return result;
    }    
}
