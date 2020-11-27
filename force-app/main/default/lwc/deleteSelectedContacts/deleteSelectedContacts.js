import { LightningElement, track, wire, api } from 'lwc';
import getAllContacts from '@salesforce/apex/ContactController.getAllContacts';
import start from '@salesforce/apex/ContactController.start';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import{ refreshApex } from '@salesforce/apex';
const COLUMNS = [
    {label: 'FirstName', fieldName: 'FirstName', type: 'text'},
    {label: 'LastName', fieldName: 'LastName', type: 'text'},
    {label: 'Account Name', fieldName: 'AccountId', type: 'text'},
    {label: 'Phone', fieldName: 'Phone', type: 'text'},
    {label: 'Email', fieldName: 'Email', type: 'text'}
];

export default class DeleteSelectedContacts extends LightningElement {
    @track columns = COLUMNS;
    @track data = [];
    @track recordsCount = 0;
    selectedRecords = [];
    refreshTable;
    error;

    @wire(getAllContacts)
    contacts(result) {
        this.refreshTable = result;
        if(result.data){
            this.data = result.data;
            this.error = undefined;
        }else if (result.error){
            this.error = result.error;
            this.data = undefined;
        }
    }
    
    getSelectedRecords(event) {
        const selectedRows = event.detail.selectedRows;
        this.recordsCount = event.detail.selectedRows.length;
        let contactSet = new Set();
        for (let i = 0; i < selectedRows.length; i++) {
            window.console.log(selectedRows[i].Id + ' ' + selectedRows[i].AccountId);
            contactSet.add(selectedRows[i].Id + ' ' + selectedRows[i].AccountId);            
        }
        if(contactSet){
            this.selectedRecords = Array.from(contactSet);
        }
        window.console.log('selectedRecords ====> ' + this.selectedRecords);
    }

    deleteAll() {
        start({frontSource: this.selectedRecords})
        .then(result => {
            window.console.log('result ====> ' + result.body);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!', 
                    message: this.recordsCount + ' Contacts are deleted.', 
                    variant: 'success'
                }),
            );
                   
            this.template.querySelector('lightning-datatable').selectedRows = [];

            return refreshApex(this.refreshTable);

        })
        .catch(error => {
            window.console.log(error);
            let tmp = error.body.message.split(':')
            let res = tmp.slice(1).join(' ');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: res, 
                    message: error.message, 
                    variant: 'error'
                }),
            );
        });
    }
}