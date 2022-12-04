/*
    ContactTriggerHandler
        - Trigger handler for trigger ContactTrigger
        - Test class is ContactTriggerHandlerTest
*/
public inherited sharing class ContactTriggerHandler {

    public static void afterUpdate(List<Contact> newRecords, Map<Id, Contact> oldMap) {        
        // Bulkify by creating relatedAccounts lookup of all related Accounts
        Set<Id> accountIds = new Set<Id>();
        for(Contact updatedContact : newRecords) {
            if(updatedContact.AccountId != NULL) {
                accountIds.add(updatedContact.AccountId);        
            }
        }
        Map<Id, Account> relatedAccounts = new Map<Id, Account>([
            SELECT Id, Total_Contacts__c 
            FROM Account 
            WHERE Id IN :accountIds
        ]);
        
        // Update Accounts
        // Handle multiple updates of same Account with updateAccounts lookup
        Map<Id, Account> updateAccounts = new Map<Id, Account>();
        for(Contact updatedContact : newRecords) {
            Contact prevContact = oldMap.get(updatedContact.Id);           
            if(updatedContact.Active__c && updatedContact.Active__c != prevContact.Active__c) {
                // Active field changed from false to true, so update account if set
                if(updatedContact.AccountId != NULL) {
                    // Update Account Total Contacts                    
                    if(updateAccounts.keySet().contains(updatedContact.AccountId)) {
                        // Have already updated this account in this transaction, continue updating
                        Account updateAccount = updateAccounts.get(updatedContact.AccountId);
                        updateAccount.Total_Contacts__c += 1;
                    } else {
                        // Haven't updated this account yet, so pull from related and add to update
                        Account updateAccount = relatedAccounts.get(updatedContact.AccountId);
                        updateAccount.Total_Contacts__c += 1;
                        updateAccounts.put(updateAccount.Id, updateAccount);
                    }
                }                
            }
        }

        // Only update accounts that have been changed
        List<Account> updateAccountsList = updateAccounts.values();
        if(updateAccountsList.size() > 0) {
            update updateAccountsList;
        }
    }

    public static void afterDelete(List<Contact> oldRecords) {
        // Bulkify by creating relatedAccounts lookup of all related Accounts
        Set<Id> accountIds = new Set<Id>();
        for(Contact prevContact :oldRecords) {
            if(prevContact.AccountId != NULL) {
                accountIds.add(prevContact.AccountId);        
            }
        }
        Map<Id, Account> relatedAccounts = new Map<Id, Account>([
            SELECT Id, Total_Contacts__c 
            FROM Account 
            WHERE Id IN :accountIds
        ]);
        
        // Update Accounts
        // Handle multiple updates of same Account with updateAccounts lookup
        Map<Id, Account> updateAccounts = new Map<Id, Account>();
        for(Contact prevContact : oldRecords) {           
            if(prevContact.Active__c) {
                // Active field was set on Contact being deleted, so update account if set
                if(prevContact.AccountId != NULL) {
                    // Update Account Total Contacts                    
                    if(updateAccounts.keySet().contains(prevContact.AccountId)) {
                        // Have already updated this account in this transaction, continue updating
                        Account updateAccount = updateAccounts.get(prevContact.AccountId);
                        if(updateAccount.Total_Contacts__c > 0) {
                            updateAccount.Total_Contacts__c -= 1;
                        } else {
                            // TODO: Add exception handling per system standard
                            // This is an invalid use case where Total Contacts would go negative
                        }
                    } else {
                        // Haven't updated this account yet, so pull from related and add to update
                        Account updateAccount = relatedAccounts.get(prevContact.AccountId);
                        if(updateAccount.Total_Contacts__c > 0) {
                            updateAccount.Total_Contacts__c -= 1;
                            updateAccounts.put(updateAccount.Id, updateAccount);
                        } else {
                            // TODO: Add exception handling per system standard
                            // This is an invalid use case where Total Contacts would go negative
                        }                        
                    }
                }                
            }
        }

        // Only update accounts that have been changed
        List<Account> updateAccountsList = updateAccounts.values();
        if(updateAccountsList.size() > 0) {
            update updateAccountsList;
        }
    }
}