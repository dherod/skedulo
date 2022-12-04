# Technical Assessment (verbatim)

Task 1
=====
Add a custom field Total Contacts of type Number on Account object with default value 0.

Add a custom field Actve of type Boolean on Contact object with default value false. On creation
of a contact for an account, automatically trigger an approval process to approve the contact. If
the contact is approved, set the active fat to true and increment the value of feld Total Contacts
on Account by 1.

On deleting the active contact, decrement the value of feld Total Contacts on the Account by 1.
Write the logic to increment and decrement the total contacts count using bulk pattern.

Task 2
=====
Create a custom object “To Do”, this custom object has 2 custom fields:
- Contact (Lookup) - required
- Actions (Multi-picklist) - required - has 3 picklist values: Action 1, Action 2, Action 3
- Status (picklist) - required - has 2 picklist values: To Do, Done

Develop Lightning Web Component to display all To Do records created by login user, sort by
Created Date (Latest first).

This component need to show below information:
- To Do Record Name - URL to Salesforce record page
- Contact
- Actions
- Status
- Develop a “New” button which will open a form-model (with validation) to create “To Do”
record.
- User interaction: Edit button and Delete button
