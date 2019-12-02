/**
 * @File Name          : logCall.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/25/2019, 9:43:16 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/12/2019   Sean Gray     Initial Version
**/
import { LightningElement,track,api, wire } from 'lwc';
import LogACall from '@salesforce/apex/TaskTriggerUtility.LogACall'; 
import getContact from '@salesforce/apex/TaskTriggerUtility.getContacts'; 
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
var today = new Date();
var dd = today.getDate();

var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
var ContactJSON;
var PackagedString;
const DELAY = 300;
const fields = [
	'Case__c.ContactId',
];
export default class logCall extends LightningElement {
    connectedCallback(){
        getContact({recordId: this.recordId })
    .then(result => {
        //this.contacts = result;
        ContactJSON = JSON.parse(result);
        this.ContactId = ContactJSON.ContactId;
    })
    .catch(error => {
        this.error = error;
    });

    }
@api recordId;
@track ContactId;
@track Type;
@track Priority = 'Normal';
@track DueDate = date;
@track MarketingType;
@track ServiceClass;
@track PaymentCallType;
@track Subject = 'Call';
@track Comments;
@track loading = false;
@track search = '';
@track error;
@track contacts;
@track contactChange = false;

@track selectedAccount;
@track showAccountsListFlag = false;

// @wire(getRecord, { recordId: '$recordId', fields })
// 	loadJob({ error, data }) {
// 		if (error) {
//             console.log('Error : ' + error);
// 			// TODO: handle error
// 		} else if (data) {
//             // Get Bear data
//             console.log('Data : ' + data);
//            // console.log('Data : ' + data.fields.ContactId.value);
//             //this.ContactId = data.fields.ContactId.value;
//             console.log('ContactId is ' + this.ContactId);
//             Object.defineProperty(data, 'property1');
//             console.log('ContactId ' + this.ContactId + '    Property 1 is ' + this.data.property1);
// 			// Transform bear data into map markers	
// 		}
// 	}
    // @wire(getContact, { recordId: '$recordId'})
	// cont({ error, data }) {
	// 	if (error) {
    //         console.log('Error : ' + error);
	// 		// TODO: handle error
	// 	} else if (data) {
    //         // Get Bear data
    //         ContactJSON = JSON.parse(this.data);
    //         this.ContactId = ContactJSON.ContactId;
            
              
    //         console.log('Data : ' + data);
    //        // console.log('Data : ' + data.fields.ContactId.value);
    //         //this.ContactId = data.fields.ContactId.value;
    //         console.log('ContactId is ' + this.ContactId);
    //         this.contactId = data;
    //         console.log('ContactId is ' + this.ContactId);
            
	// 		// Transform bear data into map markers	
	// 	}
    // }
    
// @wire(getContacts, { searchText: '$search' })
// contacts;

// ChangeSearchKey(event){
//     this.searchKey = event.target.value;
// }


    

get TypeOptions() {
    return [ 
        { label: 'Accounting Note', value: 'Accounting Note' },
        { label: 'Project Note', value: 'Project Note' },
        { label: 'Marketing Note', value: 'Marketing Note' },
        { label: 'Sent Email', value: 'Sent Email' },
        { label: 'Customer Service Note', value: 'Customer Service Note' },
        { label: 'Angry Customer', value: 'Angry Customer' },
        { label: 'Collection Issues', value: 'Collection Issues' },
        { label: 'Lunch and Learn', value: 'Lunch and Learn' },
        { label: 'Contact Center', value: 'Contact Center' },
        { label: 'LinkedIn InMail', value: 'LinkedIn InMail' },
        { label: 'LinkedIn Message', value: 'LinkedIn Message' },
        { label: 'Email', value: 'Email' },
        { label: 'Create Document', value: 'Create Document' },
        { label: 'Code Fix', value: 'Code Fix' },
        { label: 'Create Automation', value: 'Create Automation' },
        { label: 'QA', value: 'QA' },
        { label: 'Custom Object', value: 'Custom Object' },
        { label: 'Custom Field', value: 'Custom Field' },
        { label: 'New Process', value: 'New Process' },
        { label: 'Call', value: 'Call' },
        { label: 'Job not complete/Billed early', value: 'Job not complete/Billed early' },
        { label: 'Missing required payment or program documentation.', value: 'Missing required payment or program documentation.' },
        { label: 'Need response/info from PD', value: 'Need response/info from PD' },
        { label: 'Work not completed/credit needed', value: 'Work not completed/credit needed' },
        { label: 'Billing/customer service issues', value: 'Billing/customer service issues' },
        { label: 'MSA/ERA', value: 'MSA/ERA' },
    ];
}
get PriorityOptions() {
    return [ 
        { label: 'High', value: 'High' },
        { label: 'Normal', value: 'Normal' },
        { label: 'Low', value: 'Low' },
    ];
}
get MarketingTypeOptions() {
    return [ 
        { label: 'Association', value: 'Association' },
        { label: 'ATI Hosted Event', value: 'ATI Hosted Event' },
        { label: 'Breakfast', value: 'Breakfast' },
        { label: 'Coffee', value: 'Coffee' },
        { label: 'Conference', value: 'Conference' },
        { label: 'Dinner', value: 'Dinner' },
        { label: 'Email', value: 'Email' },
        { label: 'ERA Executed', value: 'ERA Executed' },
        { label: 'Family Event', value: 'Family Event' },
        { label: 'Golf', value: 'Golf' },
        { label: 'In-Person Meeting', value: 'In-Person Meeting' },
        { label: 'Lunch', value: 'Lunch' },
        { label: 'Lunch & Learn', value: 'Lunch & Learn' },
        { label: 'Mail', value: 'Mail' },
        { label: 'Office Visit', value: 'Office Visit' },
        { label: 'Phone Call', value: 'Phone Call' },
        { label: 'Sporting Event', value: 'Sporting Event' },
        { label: 'Spouse Event', value: 'Spouse Event' },
        { label: 'Tradeshow', value: 'Tradeshow' },
        { label: 'Other', value: 'Other' },
        { label: 'Business Verticals', value: 'Business Verticals' },
    ];
}

get ServiceClassOptions() {
    return [ 
        { label: 'Database Update', value: 'Database Update' },
        { label: 'Request for Email', value: 'Request for Email' },
        { label: 'Request for Info', value: 'Request for Info' },
        { label: 'Payments', value: 'Payments' },
        { label: 'Survey', value: 'Survey' },
        { label: 'Job Progress', value: 'Job Progress' },
    ];
}
get PaymentCallTypeOptions() {
    return [ 
        { label: 'Disputed Invoice', value: 'Disputed Invoice' },
        { label: 'Left Message', value: 'Left Message' },
        { label: 'Paid', value: 'Paid' },
        { label: 'Sent Copy of Invoice', value: 'Sent Copy of Invoice' },
        { label: 'Forwarded to PD/PM/RM/AR', value: 'Forwarded to PD/PM/RM/AR' },
        { label: 'Open Issues', value: 'Open Issues' },
        
    ];
}

handleContact(event){
this.ContactId = event.detail.value;
this.contactChange = true;

}
handleType(event){
this.Type = event.detail.value;
}
handlePriority(event){
    this.Priority = event.detail.value;
}
handleDueDate(event){
    this.DueDate = event.detail.value;
}
handleMarketingType(event){
    this.MarketingType = event.detail.value;
}
handleServiceClass(event){
    this.ServiceClass = event.detail.value;
}
handlePaymentCallType(event){
    this.PaymentCallType = event.detail.value;
}
handleSubject(event){
    this.Subject = event.detail.value;
}
handleComments(event){
    this.Comments = event.detail.value;
}

LogACall(){
   //if(this.ContactId.length() > 0){
    ContactJSON = {'ContactString': this.ContactId};
    console.log('ContactJSON is   ' + ContactJSON);
    PackagedString = JSON.stringify(ContactJSON);
    this.loading = true;
    
    
    console.log('Before Log a call contactId is ' + this.ContactId + '   and JSON is ' + PackagedString);
    LogACall({recordId:this.recordId, ContactJSON: PackagedString, Type1: this.Type, Priority1: this.Priority, DueDate1 : this.DueDate, MarketingType1: this.MarketingType,ServiceClass1: this.ServiceClass, PaymentCallType1: this.PaymentCallType, Subject1:this.Subject, Comments1:this.Comments, ContactChange:this.contactChange})
    .then(result => {
    
        if(result === 'Success'){
            this.loading = false;
            const event = new ShowToastEvent({
                title:'Success',
                message: 'Saved',
                variant: 'success',
            });
            this.dispatchEvent(event);
            //this.dispatchEvent(new CustomEvent('recordChange'));
            this.ContactId = '';
            this.Type = '';
            this.Priority = 'Normal';
            this.DueDate = date;
            this.MarketingType = '';
            this.ServiceClass= '';
            this.PaymentCallType = '';
            this.Subject = 'Call';
            this.Comments = '';
        }else{
            this.loading = false;
            const event = new ShowToastEvent({
                title:'Failure',
                message: 'Error, Contact Your Administrator'
            });
            this.dispatchEvent(event);
        }
    })
// }else{
//     LogACall({recordId:this.recordId, ContactJSON: '', Type1: this.Type, Priority1: this.Priority, DueDate1 : this.DueDate, MarketingType1: this.MarketingType,ServiceClass1: this.ServiceClass, PaymentCallType1: this.PaymentCallType, Subject1:this.Subject, Comments1:this.Comments})
//     .then(result => {
        
//         if(result === 'Success'){
//             this.loading = false;
//             const event = new ShowToastEvent({
//                 title:'Success',
//                 message: 'Saved',
//                 variant: 'success',
//             });
//             this.dispatchEvent(event);
//             //this.dispatchEvent(new CustomEvent('recordChange'));
//             this.ContactId = '';
//             this.Type = '';
//             this.Priority = 'Normal';
//             this.DueDate = date;
//             this.MarketingType = '';
//             this.ServiceClass= '';
//             this.PaymentCallType = '';
//             this.Subject = 'Call';
//             this.Comments = '';
//         }else{
//             this.loading = false;
//             const event = new ShowToastEvent({
//                 title:'Failure',
//                 message: 'Error, Contact Your Administrator'
//             });
//             this.dispatchEvent(event);
//         }
//     })
// }
}
    
}