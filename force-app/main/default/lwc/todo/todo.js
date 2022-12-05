import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getToDoList from '@salesforce/apex/ToDoController.getToDoList';
import TODO_OBJECT from '@salesforce/schema/To_Do__c';
import NAME_FIELD from '@salesforce/schema/To_Do__c.Name';
import CONTACT_FIELD from '@salesforce/schema/To_Do__c.Contact__c';
import ACTIONS_FIELD from '@salesforce/schema/To_Do__c.Actions__c';
import STATUS_FIELD from '@salesforce/schema/To_Do__c.Status__c';

export default class Todo extends NavigationMixin(LightningElement) {
    todos;
    error;
    
    @api userId;
    userId = Id;
    editId = null;
    objectApiName = TODO_OBJECT;
    fields = [NAME_FIELD, CONTACT_FIELD, ACTIONS_FIELD, STATUS_FIELD];
    showCreateEdit = false;

    /** Wired Apex result so it can be refreshed programmatically */
    wiredToDosResult;

    @wire(getToDoList, {userId: "$userId"})
    wiredToDos(result) {
        this.wiredToDosResult = result;
        if (result.data) {
            this.todos = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.todos = undefined;
        }
    }

    deleteToDo(event) {
        const recordId = event.target.dataset.recordid;
        deleteRecord(recordId)
            .then(() => {                
                return refreshApex(this.wiredToDosResult);
            })
            .catch((error) => {
                // Add error handling as per environment specification

                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Error deleting record',
                //         message: error,
                //         variant: 'error'
                //     })
                // );
            });
    }

    createToDo() {
        this.editId = null;
        this.showCreateEdit = true;
    }

    editToDo(event) {
        const recordId = event.target.dataset.recordid;
        this.editId = recordId;
        this.showCreateEdit = true;    
    }

    handleSuccess() {        
        this.showCreateEdit = false;
        return refreshApex(this.wiredToDosResult);
    }

    handleCancel() {        
        this.showCreateEdit = false;
    }

    viewRecord(event) {
        // Navigate to ToDo record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "To_Do__c",
                "actionName": "view"
            },
        });
    }
}