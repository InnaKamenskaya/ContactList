import { LightningElement, track, wire } from 'lwc';
import getAllContacts from '@salesforce/apex/ContactController.getAllContacts';
import start from '@salesforce/apex/ContactController.start';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import{ refreshApex } from '@salesforce/apex';

const COLUMNS = [
    {label: 'FirstName', fieldName: 'FirstName', type: 'text'},
    {label: 'LastName', fieldName: 'LastName', type: 'text'},
    {label: 'Account Name', fieldName: 'AccountName', type: 'text'},
    {label: 'Phone', fieldName: 'Phone', type: 'phone'},
    {label: 'Email', fieldName: 'Email', type: 'email'}
];

export default class DeleteSelectedContacts extends LightningElement {
    
    allData = [];
    @track dataPerPage = [];
    @track recordsCount = 0;
    @track page = 0;
    @track pages = [];

    columns = COLUMNS;
    data = [];
    allSelection = new Set();
    allSelectionContacts = new Set();
    perpage = 10;
    selection = [];
    allSelectedRecords = [];
    refreshTable;
    error;

    @wire(getAllContacts)
    contacts(result) {
        this.refreshTable = result;
        if(result.data){
            this.data = result.data;
            this.error = undefined;
            let preparedContacts = [];
            this.data.forEach(contact => {
                let preparedContact = {};
                preparedContact.Id = contact.Id;
                preparedContact.AccountId = contact.AccountId;
                preparedContact.FirstName = contact.FirstName;
                preparedContact.LastName = contact.LastName;
                preparedContact.AccountName = contact.Account.Name;
                preparedContact.Phone = contact.Phone;
                preparedContact.Email = contact.Email;
                preparedContacts.push(preparedContact);
            });
            this.data = preparedContacts;
            let numberOfPages = Math.ceil(this.data.length / this.perpage);
            for (let i = 0; i < numberOfPages; i++) {
                this.pages.push(i);
                let startIndex = ((i+1)*this.perpage) - this.perpage;
                let endIndex = ((i+1)*this.perpage);
                let tmp = this.data.slice(startIndex, endIndex);
                this.allData[i] = tmp;
            }
            this.pageData();
        }else if (result.error){
            this.error = result.error;
            this.data = undefined;
        }
    }

    getSelectedRecords(event) {
        this.allSelectedRecords = [];
        this.selection = [];
        const selectedRows = event.detail.selectedRows;
            for (let i = 0; i < selectedRows.length; i++) {
                let contact = {              
                    Id : selectedRows[i].Id,
                    AccountId: selectedRows[i].AccountId,
                    attributes: {
                        type: "Contact"
                    }                
                };
            this.allSelectionContacts.add(contact); 
            this.allSelection.add(contact.Id+""); 
            console.log(this.allSelection.size);         
        }
        this.allSelectedRecords = Array.from(this.allSelectionContacts);
        this.selection = Array.from(this.allSelection);
        for (let i = 0; i < this.selection.length; i++) {
            console.log("++++++++++++++++++++++++++++++++");
            console.log(this.selection[i] + " selected");
            
        }
        this.recordsCount = this.allSelectedRecords.length;
    }

    deleteAll() {   
        start({frontSource: JSON.stringify(this.allSelectedRecords)})
        .then(result => {
            window.console.log('result ====> ' + result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!', 
                    message: this.recordsCount + ' Contacts are deleted.', 
                    variant: 'success'
                }),
            ); 
            this.selection = []; 
            this.refreshContactList();
        })
        .catch(error => {
            window.console.log(error);
            let tmp = error.body.message.split(':')
            let res = tmp.slice(1).join(' ');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: res, 
                    message: error.body.message, 
                    variant: 'error'
                }),
            );
        });
    }

    refreshContactList(){  
        this.data = [];
        this.allData = [];
        this.selection = [];
        this.allSelectedRecords = [];
        this.dataPerPage = [];
        this.recordsCount = 0;
        this.page = 0;
        this.pages = [];
        refreshApex(this.refreshTable);
    }
    
    pageData = ()=>{      
        this.dataPerPage = this.allData[this.page];
    }
    
    get hasPrev(){
        return this.page > 0;
    }
    
    get hasNext(){
        return this.page < this.pages.length-1;
    }

    handleNextPage = ()=>{
        ++this.page;        
        this.pageData();
    }

    handlePrevPage = ()=>{       
        --this.page;       
        this.pageData();
    } 
}