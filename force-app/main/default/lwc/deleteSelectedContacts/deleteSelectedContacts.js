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
    
    @track dataPerPage = [];
    @track recordsCount = 0;
    @track page = 0;
    @track pages = [];

    columns = COLUMNS;
    data = [];
    arrayDataPerPage = [];
    perpage = 5;
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
                this.arrayDataPerPage.push(tmp);
            }
            this.pageData();
        }else if (result.error){
            this.error = result.error;
            this.data = undefined;
        }
    }

    getSelectedRecords(event) {
        const selectedRows = event.detail.selectedRows;
        if(selectedRows.length === 0){
            this.selection[this.page] = [];
        }
            let contactSet = new Set();
            for (let i = 0; i < selectedRows.length; i++) {
                let contact = {              
                    Id : selectedRows[i].Id,
                    AccountId: selectedRows[i].AccountId,
                    attributes: {
                        type: "Contact"
                    }                
                };
            contactSet.add(contact);            
        }
        this.allSelectedRecords[this.page] = Array.from(contactSet);
        this.recordsCount = this.allSelectedRecords.flat().length;
    }

    fillSelectionArray(){
        if(this.allSelectedRecords[this.page].length > 0){
            let temp = [];
            for(let i = 0; i < this.allSelectedRecords[this.page].length; i++){
                temp[i] = this.allSelectedRecords[this.page][i].Id+"";
            }
            this.selection[this.page] = temp;
        } 
    }

    deleteAll() { 
        this.fillSelectionArray();     
        start({frontSource: JSON.stringify(this.allSelectedRecords.flat())})
        .then(result => {
            window.console.log('result ====> ' + result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!', 
                    message: this.recordsCount + ' Contacts are deleted.', 
                    variant: 'success'
                }),
            );                   
            this.template.querySelector('lightning-datatable').selectedRows = [];
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
        refreshApex(this.refreshTable);
    }
    
    pageData = ()=>{      
        this.dataPerPage = this.arrayDataPerPage[this.page];
        if(this.selection[this.page]){
            this.template.querySelector('lightning-datatable').selectedRows = this.selection[this.page];
        }else{
            this.allSelectedRecords[this.page] = [];
            this.template.querySelector('lightning-datatable').selectedRows = [];
        }   
    }
    
    get hasPrev(){
        return this.page > 0;
    }
    
    get hasNext(){
        return this.page < this.pages.length-1;
    }

    handleNextPage = ()=>{
        this.fillSelectionArray();
        ++this.page;        
        this.pageData();
    }

    handlePrevPage = ()=>{ 
        this.fillSelectionArray();       
        --this.page;       
        this.pageData();
    } 
}