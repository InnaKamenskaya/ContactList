import { LightningElement, wire } from 'lwc';
import getAllContacts from '@salesforce/apex/ContactController.getAllContacts';
import deleteContacts from '@salesforce/apex/ContactController.deleteContacts';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import{ refreshApex } from '@salesforce/apex';

const COLUMNS = [
    {label: 'Name', fieldName: 'nameLink', type: 'url', typeAttributes: 
    { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" }},
    {label: 'Account Name', fieldName: 'AccountName', type: 'text'},
    {label: 'Phone', fieldName: 'Phone', type: 'phone'},
    {label: 'Email', fieldName: 'Email', type: 'email'}
];

export default class DeleteSelectedContacts extends LightningElement {

    columns = COLUMNS;
    data = [];
    dataPerPage = [];
    recordsCount = 0;
    page = 0;
    pages = [];
    allDataPerPage = [];
    perpage = 10;
    selection = [];
    allContactsMap = new Map();
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
                preparedContact.nameLink = "/" + contact.Id;
                preparedContact.AccountId = contact.AccountId;
                preparedContact.Name = contact.FirstName + " " + contact.LastName;
                preparedContact.AccountName = contact.Account ? contact.Account.Name : "";               
                preparedContact.Phone = contact.Phone;
                preparedContact.Email = contact.Email;
                preparedContacts.push(preparedContact);
                let temp = {              
                    Id : contact.Id,
                    sobjectType: "Contact"
                };
                this.allContactsMap.set(contact.Id, temp);
            });
            this.data = preparedContacts;
            let numberOfPages = Math.ceil(this.data.length / this.perpage);
            for (let i = 0; i < numberOfPages; i++) {
                this.pages.push(i);
                let startIndex = ((i+1)*this.perpage) - this.perpage;
                let endIndex = ((i+1)*this.perpage);
                let tmp = this.data.slice(startIndex, endIndex);
                this.allDataPerPage.push(tmp);
            }
            this.pageData();
        }else if (result.error){
            this.error = result.error;
            this.data = undefined;
        }
    }

    getSelectedRecords(event) {
        const selectedRows = event.detail.selectedRows;
        if(this.selection[this.data] === undefined || selectedRows.length != this.selection[this.data].length){
            let contactSetId = new Set();
            for (let i = 0; i < selectedRows.length; i++) {
            contactSetId.add(selectedRows[i].Id);           
            }
        this.selection[this.page] = Array.from(contactSetId);
        this.recordsCount = this.selection.flat().length;
        }                     
    }

    getFinalSelectedContacts(){
        let contactsId = this.selection.flat();
        let finalSelectedContacts = [];
        if(contactsId.length === 0){
            this.error = new Error("No one contacts are selected!");
             this.dispatchEvent(
             new ShowToastEvent({
                    title: 'Error!', 
                    message: this.error.message, 
                    variant: 'error'
                }),
           );           
           throw this.error;
        }else{
            for (let i = 0; i < contactsId.length; i++) {
                finalSelectedContacts.push(this.allContactsMap.get(contactsId[i])); 
            }
        }
        return finalSelectedContacts;
    }

    deleteAll() {        
        deleteContacts({selectedContacts: this.getFinalSelectedContacts()})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!', 
                    message: this.recordsCount + ' Contacts are deleted.', 
                    variant: 'success'
                }),
            ); 
            this.refreshContactList();
        })
        .catch(error => {
            let tmp = error.body.message.split(':').slice(1).join(' ');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: tmp, 
                    message: error.body.message, 
                    variant: 'error'
                }),
            );
        });
    }       

    refreshContactList(){  
        this.dataPerPage = [];
        this.recordsCount = 0;
        this.page = 0;
        this.pages = [];
        this.data = [];
        this.allDataPerPage = []; 
        this.selection = [];     
        refreshApex(this.refreshTable);
    }
    
    pageData = ()=>{      
        this.dataPerPage = this.allDataPerPage[this.page];
        if(this.selection[this.page]){
            this.template.querySelector('lightning-datatable').selectedRows = this.selection[this.page];
        }else{
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
        ++this.page;        
        this.pageData();
    }

    handlePrevPage = ()=>{      
        --this.page;       
        this.pageData();
    } 
}