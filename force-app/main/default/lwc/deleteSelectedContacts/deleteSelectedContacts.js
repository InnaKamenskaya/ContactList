import { LightningElement, track, wire, api } from 'lwc';
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
    columns = COLUMNS;
    @track data = [];
    @track recordsCount = 0;
    @track page = 1;
    @track pages = [];
    contactSet = new Set();
    @track selections = [];
    perpage = 5;
    selectedRecords = [];
    refreshTable;
    error;


    @wire(getAllContacts)
    contacts(result) {        
        this.refreshTable = result;
        if(result.data){
            // let preparedContacts = [];
            // result.data.forEach(contact => {
            // let preparedContact = {};
            // preparedContact.Id = contact.Id;
            // preparedContact.AccountId = contact.AccountId;
            // preparedContact.FirstName = contact.FirstName;
            // preparedContact.LastName = contact.LastName;
            // preparedContact.AccountName = contact.Account.Name;
            // preparedContact.Phone = contact.Phone;
            // preparedContact.Email = contact.Email;
            // preparedContacts.push(preparedContact);
        //});
        this.data = result.data;
        this.setPages(this.data); 
        this.error = undefined;
        }else if (result.error){
            this.error = result.error;
            this.data = undefined;
        }
    }
    // async connectedCallback(){
    //     this.data = await getAllContacts(); 
    //     let preparedContacts = [];
    //     this.data.forEach(contact => {
    //         let preparedContact = {};
    //         preparedContact.Id = contact.Id;
    //         preparedContact.AccountId = contact.AccountId;
    //         preparedContact.FirstName = contact.FirstName;
    //         preparedContact.LastName = contact.LastName;
    //         preparedContact.AccountName = contact.Account.Name;
    //         preparedContact.Phone = contact.Phone;
    //         preparedContact.Email = contact.Email;
    //         preparedContacts.push(preparedContact);
    //     });
    //     this.data = preparedContacts;
    //     console.log(this.data);
    //     this.setPages(this.data);        
    // }

    getSelectedRecords(event) {
        let selectedRows = event.detail.selectedRows;
        this.recordsCount = event.detail.selectedRows.length;
        for (let i = 0; i < selectedRows.length; i++) {
            let contact = {              
                Id : selectedRows[i].Id,
                AccountId: selectedRows[i].AccountId,
                attributes: {
                    type: "Contact"
                }                
            };
           this.contactSet.add(contact);
           this.selections[i] = contact;          
        }
        console.log("Set: " + this.contactSet.size);
        console.log("Selections: " + this.selections.forEach(c => console.log("Contact from array!!! Id: " + c.Id + ", AccountId: " + c.AccountId)));
        if(this.contactSet){
            this.selectedRecords = Array.from(this.contactSet);
        }
            
        console.log('selectedRecords ====> ' + this.selectedRecords);
    }

    deleteAll() {       
        start({frontSource: JSON.stringify(this.selectedRecords)})
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
    
    pageData = ()=>{
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let count = endIndex - startIndex;
        let temp = [];
        for(let i = 0; i < count; i++){
            if((startIndex + i) < this.data.length - 1){
                temp[i] = this.data[startIndex + i];
            }else{
                return;
            }            
        }
         //Array.from(this.data.slice(startIndex,endIndex));
        console.log("this.data: " + temp);
        return temp;
    }

    setPages = (data)=>{
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }  
    
    get hasPrev(){
        return this.page > 1;
    }
    
    get hasNext(){
        return this.page < this.pages.length
    }

    handleNextPage = ()=>{
        ++this.page;
    }

    handlePrevPage = ()=>{
        --this.page;
    }

    get currentPageData(){
        return this.data = this.pageData();
    }  
}