/*
    ContactTriggerHandlerTest
        - Test class for both ContactTrigger and ContactTriggerHandler
        - If ContactTrigger is refactored into more than a delegation pass-through to 
          ContactTriggerHandler, then refactor its tests from here into a separate test 
          class ContactTriggerTest
*/
@isTest
private class ContactTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        // Accounts
        List<Account> accounts = new List<Account>();
        Account account1 = new Account(
            Name = 'Account1'
        );
        accounts.add(account1);
        Account account2 = new Account(
            Name = 'Account2'
        );
        accounts.add(account2);
        insert accounts;
        
        // Contacts
        List<Contact> contacts = new List<Contact>();
        // No Account
        Contact contactNoAccount = new Contact(
            FirstName = 'Account0',
            LastName = 'Test'
        );
        contacts.add(contactNoAccount);
        // Contact with unique Account
        Contact contact1 = new Contact(
            AccountId = account1.Id,
            FirstName = 'Account1',
            LastName = 'Test'
        );
        contacts.add(contact1);
        // Contacts with duplicate Account
        Contact contact21 = new Contact(
            AccountId = account2.Id,
            FirstName = 'Account2',
            LastName = 'Test1'
        );
        contacts.add(contact21);
        Contact contact22 = new Contact(
            AccountId = account2.Id,
            FirstName = 'Account2',
            LastName = 'Test2'
        );
        contacts.add(contact22);
        insert contacts;         
    }

    @isTest
    static void testTriggerUpdate_Update1() {
        Integer expectedTotalContacts = 1;

        Contact contact = [
            SELECT Id, FirstName, Active__c 
            FROM Contact
            WHERE FirstName = 'Account1'
            LIMIT 1
        ];
        contact.Active__c = true;

        test.startTest();
        update contact;
        test.stopTest();

        Account account = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = :contact.FirstName
            LIMIT 1
        ];
        System.assertEquals(expectedTotalContacts, account.Total_Contacts__c);
    }

    @isTest
    static void testAfterUpdate_Update2() {
        Integer expectedTotalContacts = 2;

        Map<Id, Contact> oldMap = new Map<Id, Contact>([
            SELECT Id, FirstName, Active__c, AccountId
            FROM Contact
            WHERE FirstName = 'Account2'
        ]);
        List<Contact> newRecords = [
            SELECT Id, FirstName, Active__c, AccountId
            FROM Contact
            WHERE FirstName = 'Account2'
        ];
        for(Contact updatedContact : newRecords) {
            updatedContact.Active__c = true;
        }
        
        test.startTest();
        ContactTriggerHandler.afterUpdate(newRecords, oldMap);
        test.stopTest();
        
        Account account = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = 'Account2'
            LIMIT 1
        ];
        System.assertEquals(expectedTotalContacts, account.Total_Contacts__c);
    }

    @isTest
    static void testAfterUpdate_Update0() {
        Integer expectedTotalContacts = 0;

        Map<Id, Contact> oldMap = new Map<Id, Contact>([
            SELECT Id, FirstName, Active__c, AccountId
            FROM Contact
            WHERE FirstName = 'Account0'
        ]);
        List<Contact> newRecords = [
            SELECT Id, FirstName, Active__c, AccountId
            FROM Contact
            WHERE FirstName = 'Account0'
        ];
        for(Contact updatedContact : newRecords) {
            updatedContact.Active__c = true;
        }

        test.startTest();
        ContactTriggerHandler.afterUpdate(newRecords, oldMap);
        test.stopTest();
        
        List<Account> account0 = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = 'Account0'
        ];
        System.assertEquals(expectedTotalContacts, account0.size());
    }

    @isTest
    static void testTriggerDelete_Update1() {
        Integer expectedUpdateTotalContacts = 1;
        Integer expectedDeleteTotalContacts = 0;

        Contact contact = [
            SELECT Id, FirstName, Active__c 
            FROM Contact
            WHERE FirstName = 'Account1'
            LIMIT 1
        ];
        contact.Active__c = true;

        update contact;

        Account accountUpdated = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = :contact.FirstName
            LIMIT 1
        ];
        System.assertEquals(expectedUpdateTotalContacts, accountUpdated.Total_Contacts__c);

        test.startTest();
        delete contact;
        test.stopTest();

        Account accountDeleted = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = :contact.FirstName
            LIMIT 1
        ];
        System.assertEquals(expectedDeleteTotalContacts, accountDeleted.Total_Contacts__c);
    }

    @isTest
    static void testAfterDelete_Update2() {        
        Integer expectedUpdateTotalContacts = 2;
        Integer expectedDeleteTotalContacts = 0;

        Map<Id, Contact> oldMap = new Map<Id, Contact>([
            SELECT Id, FirstName, Active__c, AccountId
            FROM Contact
            WHERE FirstName = 'Account2'
        ]);
        List<Contact> newRecords = [
            SELECT Id, FirstName, Active__c, AccountId
            FROM Contact
            WHERE FirstName = 'Account2'
        ];
        for(Contact updatedContact : newRecords) {
            updatedContact.Active__c = true;
        }

        ContactTriggerHandler.afterUpdate(newRecords, oldMap);
        
        Account accountUpdated = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = 'Account2'
            LIMIT 1
        ];
        System.assertEquals(expectedUpdateTotalContacts, accountUpdated.Total_Contacts__c);

        // These have Active__c set to true
        List<Contact> oldRecords = newRecords;

        test.startTest();
        ContactTriggerHandler.afterDelete(oldRecords);
        test.stopTest();

        Account accountDeleted = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = 'Account2'
            LIMIT 1
        ];
        System.assertEquals(expectedDeleteTotalContacts, accountDeleted.Total_Contacts__c);    
    }

    @isTest
    static void testAfterDelete_Update0() {
        Integer expectedTotalContacts = 0;

        Map<Id, Contact> oldMap = new Map<Id, Contact>([
            SELECT Id, FirstName, Active__c, AccountId
            FROM Contact
            WHERE FirstName = 'Account0'
        ]);
        List<Contact> newRecords = [
            SELECT Id, FirstName, Active__c, AccountId
            FROM Contact
            WHERE FirstName = 'Account0'
        ];
        for(Contact updatedContact : newRecords) {
            updatedContact.Active__c = true;
        }

        ContactTriggerHandler.afterUpdate(newRecords, oldMap);
        
        List<Account> accountUpdated = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = 'Account0'
        ];
        System.assertEquals(expectedTotalContacts, accountUpdated.size());

        // These have Active__c set to true
        List<Contact> oldRecords = newRecords;

        test.startTest();
        ContactTriggerHandler.afterDelete(oldRecords);
        test.stopTest();

        List<Account> accountDeleted = [
            SELECT Id, Total_Contacts__c
            FROM Account
            WHERE Name = 'Account0'
        ];
        System.assertEquals(expectedTotalContacts, accountDeleted.size());
    }
}