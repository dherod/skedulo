/*
    ToDoController
        - Apex controller for LWC todo
        - TODO: Add this test class
        - Test class is ToDoControllerTest
*/
public with sharing class ToDoController {
    @AuraEnabled(cacheable=true)
    public static List<To_Do__c> getToDoList(Id userId) {
        return [
            SELECT Id, Name, Contact__c, Actions__c, Status__c,
                Contact__r.Name
            FROM To_Do__c
            WHERE CreatedById = :userId
            ORDER BY CreatedDate DESC
        ];
    }
}
