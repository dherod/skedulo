/*
    ContactTrigger
        - Trigger on Contact object
        - Delegates to trigger handler class ContractTriggerHandler
        - Test class is ContactTriggerHandlerTest
*/
trigger ContactTrigger on Contact (after update, after delete) { 
    switch on Trigger.operationType {
        when AFTER_UPDATE {
            ContactTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        
        when AFTER_DELETE {
            ContactTriggerHandler.afterDelete(Trigger.old);
        }
    }
}