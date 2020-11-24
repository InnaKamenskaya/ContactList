public with sharing class Util {
    @AuraEnabled
    public static Boolean fillRecords(){
        try {
            List<Contact> newContacts = new List<Contact>();
            List<Case> newCases = new List<Case>();
            Contact c = new Contact(FirstName = 'OpenCases', LastName = '1', AccountId = '001090000059gHUAAY');
            Contact c1 = new Contact(FirstName = 'NonCases', LastName = '1', AccountId = '001090000059gHUAAY');
            Contact c2 = new Contact(FirstName = 'ClosedCases', LastName = '1', AccountId = '001090000059gHUAAY');

            Case cs = new Case(ContactId = c.Id, Status = 'New', Origin = 'Email', AccountId = '001090000059gHUAAY');
            Case cs1 = new Case(ContactId = c2.Id, Status = 'Closed', Origin = 'Email', AccountId = '001090000059gHUAAY');

            Contact c3 = new Contact(FirstName = 'OpenCases', LastName = '2', AccountId = '001090000059gHeAAI');
            Contact c4 = new Contact(FirstName = 'NonCases', LastName = '2', AccountId = '001090000059gHeAAI');
            Contact c5 = new Contact(FirstName = 'ClosedCases', LastName = '2', AccountId = '001090000059gHeAAI');

            Case cs2 = new Case(ContactId = c3.Id, Status = 'New', Origin = 'Email', AccountId = '001090000059gHeAAI');
            Case cs3 = new Case(ContactId = c5.Id, Status = 'Closed', Origin = 'Email', AccountId = '001090000059gHeAAI');

            Contact c6 = new Contact(FirstName = 'OpenCases', LastName = '3', AccountId = '001090000041Pa6AAE');
            Contact c7 = new Contact(FirstName = 'NonCases', LastName = '3', AccountId = '001090000041Pa6AAE');
            Contact c8 = new Contact(FirstName = 'ClosedCases', LastName = '3', AccountId = '001090000041Pa6AAE');

            Case cs4 = new Case(ContactId = c6.Id, Status = 'New', Origin = 'Email', AccountId = '001090000041Pa6AAE');
            Case cs5 = new Case(ContactId = c8.Id, Status = 'Closed', Origin = 'Email', AccountId = '001090000041Pa6AAE');

            Contact c9 = new Contact(FirstName = 'OpenCases', LastName = '4', AccountId = '00109000004HElkAAG');
            Contact c10 = new Contact(FirstName = 'NonCases', LastName = '4', AccountId = '00109000004HElkAAG');
            Contact c11 = new Contact(FirstName = 'ClosedCases', LastName = '4', AccountId = '00109000004HElkAAG');

            Case cs6 = new Case(ContactId = c9.Id, Status = 'New', Origin = 'Email', AccountId = '00109000004HElkAAG');
            Case cs7 = new Case(ContactId = c11.Id, Status = 'Closed', Origin = 'Email', AccountId = '00109000004HElkAAG');

            newContacts.add(c);
            newContacts.add(c1);
            newContacts.add(c2);
            newContacts.add(c3);
            newContacts.add(c4);
            newContacts.add(c5);
            newContacts.add(c6);
            newContacts.add(c7);
            newContacts.add(c8);
            newContacts.add(c9);
            newContacts.add(c10);
            newContacts.add(c11);

            newCases.add(cs);
            newCases.add(cs1);
            newCases.add(cs2);
            newCases.add(cs3);
            newCases.add(cs4);
            newCases.add(cs5);
            newCases.add(cs6);
            newCases.add(cs7);

            insert newContacts;
            insert newCases;  
            
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
