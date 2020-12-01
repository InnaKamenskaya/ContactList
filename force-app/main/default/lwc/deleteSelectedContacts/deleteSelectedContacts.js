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
    @track page = 1;
    @track pages = [];
    perpage = 2;
    selectedRecords = [];
    refreshTable;
    error;

    async connectedCallback(){
        this.data = await getAllContacts();
        this.setPages(this.data);
        
    }

    getSelectedRecords(event) {
        let selectedRows = event.detail.selectedRows;
        this.recordsCount = event.detail.selectedRows.length;
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
        if(contactSet){
            this.selectedRecords = Array.from(contactSet);
        }
            
        window.console.log('selectedRecords ====> ' + this.selectedRecords);
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


    get pagesList(){
        let mid = Math.floor(this.set_size/2) + 1 ;
        if(this.page > mid){
            return this.pages.slice(this.page-mid, this.page+mid-1);
        } 
        return this.pages.slice(0,this.set_size);
    }
    
    pageData = ()=>{
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        return this.data.slice(startIndex,endIndex);
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
        return this.pageData();
    }  
}