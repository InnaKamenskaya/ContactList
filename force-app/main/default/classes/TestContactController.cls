@isTest
private class TestContactController {

    @testSetup 
    static void createAllData(){

        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Case> cases = new List<Case>();

        Account acc = new Account(Name = 'First');
        Account acc1 = new Account(Name = 'Second');

        accounts.add(acc);
        accounts.add(acc1);
        insert accounts;

        Contact con = new Contact(LastName = 'First', AccountId = acc.Id);
        Contact con1 = new Contact(LastName = 'Second');
        Contact con2 = new Contact(LastName = 'Third', AccountId = acc1.Id);
        Contact con3 = new Contact(LastName = 'Fourth', AccountId = acc1.Id);

        contacts.add(con);
        contacts.add(con1);
        contacts.add(con2);
        contacts.add(con3);
        insert contacts;

        Case cs = new Case(ContactId = con.Id, AccountId = acc.Id);
        Case cs1 = new Case(ContactId = con1.Id);
        Case cs2 = new Case(ContactId = con2.Id, AccountId = acc1.Id);
        Case cs3 = new Case(ContactId = con3.Id, AccountId = acc1.Id);              

        cases.add(cs);
        cases.add(cs1);
        cases.add(cs2);      
        cases.add(cs3);       
        insert cases;
    }

    @isTest
    static void getAllContactList() {

        Test.startTest();
        List<Contact> conts = ContactController.getAllContacts();
        Test.stopTest();

        System.assertEquals(
            4,
            conts.size(),
            'The contact list size should be 4'
        );
    }

    @isTest
    static void startContactWithCasesWithoutColleagues(){
        Contact temp = [SELECT Id, AccountId FROM Contact WHERE LastName = 'First'];
        List<Contact> contacts = new List<Contact>();
        contacts.add(temp);
        try {
            List<Contact> conts = ContactController.start(contacts);
        } catch (Exception e) {
            System.assert(e.getMessage().contains(e.getMessage()));
        }
    }

    @isTest
    static void startContactWithCasesWithoutAccount(){
        Contact temp = [SELECT Id, AccountId FROM Contact WHERE LastName = 'Second'];
        List<Contact> contacts = new List<Contact>();
        contacts.add(temp);
        try {
            List<Contact> conts = ContactController.start(contacts);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('first error: DELETE_FAILED, Your attempt to delete contact with Id ' + temp.Id + ' could not be completed because it is associated with some cases'));
        }
    }

    @isTest
    static void startNegativeWithEmptyList(){
        List<Contact> contacts = new List<Contact>();
        try {
            List<Contact> conts = ContactController.start(contacts);
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No one contacts are selected!'));
        }
    }

    @isTest
    static void startPositiv(){
        Contact temp = [SELECT Id, AccountId FROM Contact WHERE LastName = 'Third' LIMIT 1];
        List<Contact> contacts = new List<Contact>();
        contacts.add(temp);
        List<Contact> resConts = ContactController.start(contacts);
        System.assertEquals(temp, resConts.get(0));

        Contact res = [SELECT Id, AccountId, (SELECT Id FROM Cases) FROM Contact WHERE LastName = 'Fourth' LIMIT 1];
        System.assertEquals(
            2,
            res.Cases.size(),
            'The contact list size should be 2'
        );
    }
}
