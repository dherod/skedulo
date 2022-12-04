/*
    Post-Deployment Step for Task 1

    TODO: Need to update previously created accounts and contacts with correct 
    Active and Total Contacts values so will track correctly.  
    Add Apex to correctly count and add value on each Account.

    For now, just update existing accounts to default 0 so won't get exception if use them when
    creating contacts.  "Total Contacts" for now will then be since started tracking!
*/

List<Account> existingAccounts = [
    SELECT Id, Total_Contacts__c
    FROM Account
    WHERE Total_Contacts__c = NULL
];

for(Account existingAccount : existingAccounts) {
    existingAccount.Total_Contacts__c = 0;
}

update existingAccounts;