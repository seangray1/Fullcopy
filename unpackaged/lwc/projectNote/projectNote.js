/**
 * @File Name          : projectNote.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/8/2019, 11:20:40 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/27/2019   Sean Gray     Initial Version
**/
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import PROJECTNOTEDATE from '@salesforce/apex/JobUtility.projectNoteDate';
import PROJECTNOTEPERCENT from '@salesforce/apex/JobUtility.projectNotePercent';
import Id from '@salesforce/user/Id';
import PROJECTNOTECREATE from '@salesforce/apex/JobUtility.createTaskProjectNote';
export default class ProjectNote extends NavigationMixin (LightningElement) {
    connectedCallback(){
        if(this.jobIdtosearch !== null){
            this.recordId = this.jobIdtosearch;
            
            }
            this.Id = Id;
        PROJECTNOTEDATE({recordId:this.recordId})
            .then(result => {
                this.estimateCompleted = result;
            })
        PROJECTNOTEPERCENT({recordId:this.recordId})
            .then(result => {
                this.jobComplete = result;
            })
        
    }
@track error = false;
@track resulting;
@track disabled= true;
@track loading = false;
@track data;
@api Id;
@track workCompleted;
@track workStarted;
@track repairComments;
@track jobComplete;
@track estimateCompleted;
@api recordId; 
@track ExtraData;
@track hasInsured;
@track potentialSupplement;
getcurrentpageurl = (new URL(document.location)).searchParams;
@api jobIdtosearch = this.getcurrentpageurl.get('job__id');
get options() {
    return [ 
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];
}

handleChangeInsured(event){
    this.hasInsured = event.detail.value;

}
handleChangeSupplement(event){
    this.potentialSupplement = event.detail.value;

}
percentChange(event){
    this.jobComplete = event.detail.value;

}
workChange(event){
    this.workCompleted = event.detail.value;

}
workStartedChange(event){
    this.workStarted = event.detail.value;

}
estimateChange(event){
    this.estimateCompleted = event.detail.value;

}
repairCommentsChange(event){
    this.repairComments = event.detail.value;
   

}
Cancel(){
    this.loading = true;
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'ATI_Job__c',
            actionName: 'view',
        },
    });
}
CreateProject(){
  
    if((!this.repairComments)||(!this.workCompleted)||(!this.workStarted)||(!this.jobComplete)||(!this.estimateCompleted)||(!this.potentialSupplement)||(!this.hasInsured)){
        this.error = true;
    }else{
        this.loading = true;
        PROJECTNOTECREATE({percent : this.jobComplete, recordId : this.recordId, ownerId: this.Id, workCompleted : this.workCompleted, workStarted : this.workStarted, completionDate : this.estimateCompleted, insured: this.hasInsured, supplement:this.potentialSupplement, repairComments : this.repairComments}) 
        .then(result => {
            this.ExtraData = result;
            if(this.ExtraData === 'Success'){
                this.dispatchEvent(new CustomEvent('recordChange'));  
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'ATI_Job__c',
                        actionName: 'view',       
                },
            });   
            }
        });
}
}
}