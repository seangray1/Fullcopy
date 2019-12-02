/**
 * @File Name          : CaseButton.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/26/2019, 12:55:49 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/28/2019   Sean Gray     Initial Version
**/
import { LightningElement, track, api, wire } from 'lwc';
import JobCaseInfo from '@salesforce/apex/JobUtility.JobCaseInfo';
import ContactAccount from '@salesforce/apex/JobUtility.ContactAccount';
import CaseChatterTaskCreation from '@salesforce/apex/JobUtility.CaseChatterTaskCreation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
export default class caseButton extends NavigationMixin (LightningElement) {
    connectedCallback(){
        
        JobCaseInfo({recordId:this.recordId})
        .then(result => {
            this.contact = result;
    })
        ContactAccount({recordId:this.recordId})
        .then(result => {
            this.accountId = result;
})
}
@api objectApiName;
@track objectInfo;
@track ownerId;
@track accountId;
@track job;
@track caseOrigin;
@track priority = null;
@track businessCategory;
@track resolutionType;
@track nextActionDateTime;
@track status;
@track subject;
@track description;
@track contact;
@api recordId;
@track loading = false;
@track returnedData;
@track priority1 = true;
@track recordTypeId = '0120g000000EAlyAAG';


@wire(getObjectInfo, { objectApiName: CASE_OBJECT })
objectInfo;

get recordTypeId() {
    // Returns a map of record type Ids 
    const rtis = this.objectInfo.data.recordTypeInfos;
    return Object.keys(rtis).find(rti => rtis[rti].name === 'Contact Center Case');
    
}
subjectChange(event){
    this.subject = event.detail.value;
    
}
descriptionChange(event){
    this.description = event.detail.value;
    
    
}
priorityChange(){
    this.priority1 = false;
}

ButtonClicked(){
    if(this.subject.length !== 0 && this.description.length !== 0 && this.priority1 === false){
        this.loading = true;
    }
    
 
   
}
handleSuccess(){
    
    CaseChatterTaskCreation({recordId : this.recordId, subject : this.subject, description : this.description, ownerId : this.ownerId})
    .then(result => {
        this.returnedData = result;
        if(this.returnedData !== null){

        console.log(this.returnedData);
   // this.dispatchEvent(new CustomEvent('recordChange'));
    const event = new ShowToastEvent({
        title:'Success',
        message: 'Case Created',
        variant:'Success',
    });
    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.returnedData,
                            objectApiName: 'Case',
                            actionName: 'view',
                        },
                    });
    this.dispatchEvent(event);
}else{
    this.dispatchEvent(new CustomEvent('recordChange'));
    const event = new ShowToastEvent({
        title:'Failure',
        message: 'Error, Contact Your Administrator'
    });
    this.dispatchEvent(event);
}
})
    
    
}
Cancel(){
    this.dispatchEvent(new CustomEvent('cancelChange'));
}
}