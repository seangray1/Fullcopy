/**
 * @File Name          : bigTimeForceSync.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/1/2019, 8:36:43 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/12/2019   Sean Gray     Initial Version
**/
import { LightningElement, track, api } from 'lwc';
//import spinny from '@salesforce/resourceUrl/spinny';
//import Loading_SIGN from '@salesforce/resourceUrl/Loading_Sign';
import SendToBigTime from '@salesforce/apex/BigTime_Callout_Integration.invokeCallout';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class BigTimeForceSync extends NavigationMixin(LightningElement) {
@track start = true;
@api recordId;

@track loading = false;
@track data;
@track responseMessage = false;
@track error;

//@track Loading_Sign;
//Loading_Sign = Loading_SIGN;

create(){
    console.log('Record Id is ' + this.recordId);
    this.loading = true;
    this.start=false;
    SendToBigTime({jobId : this.recordId})
    this.dispatchEvent(new CustomEvent('recordChange'));
            const event = new ShowToastEvent({
                title:'Success',
                message: 'Job Uploaded'
            });
            this.dispatchEvent(event);
        
}
cancel(){
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'ATI_Job__c',
            actionName: 'view',
        },
    });
}
}