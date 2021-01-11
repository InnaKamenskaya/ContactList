@isTest
private class ContactControllerTest {
    
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
    static void getAllContactListTest() {
        Test.startTest();
        List<Contact> conts = ContactController.getAllContacts();
        Test.stopTest();
        System.assertEquals(4, conts.size(), 'The contact list size should be 4');
    }

    @isTest
    static void startNegativeWithNullTest(){
        List<Contact> conts = ContactController.deleteContacts(null);
        System.assertEquals(null, conts, 'The contact list should be null');        
    }

    @isTest
    static void startPositiveTest(){
        Contact temp = [SELECT Id FROM Contact WHERE LastName = 'Third' LIMIT 1];
        List<Contact> contacts = new List<Contact>();
        contacts.add(temp);
        Test.startTest();
        List<Contact> resConts = ContactController.deleteContacts(contacts);
        Test.stopTest();
        System.assertEquals(temp, resConts.get(0),'The same contact should be expected');
    }
}