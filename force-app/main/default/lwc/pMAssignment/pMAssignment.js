/**
 * @File Name          : pMAssignment.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/8/2019, 11:13:03 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/4/2019   Sean Gray     Initial Version
**/
import { LightningElement, track, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import PMAssignmentChatter from '@salesforce/apex/JobUtility.PMAssignmentChatter';
import PMAssignmentQuery from '@salesforce/apex/JobUtility.PMAssignmentQuery';

var PDQueryResult;
export default class PMAssignment extends NavigationMixin(LightningElement) {
    connectedCallback(){
        if(this.jobIdtosearch !== null){
        this.recordId = this.jobIdtosearch;
        
        }
        this.Id = Id;
        PMAssignmentQuery({recordId : this.recordId})
        .then(result => {
            this.PDQueryResults = result;
            console.log(this.PDQueryResults+ 'PM results');
            PDQueryResult = JSON.parse(this.PDQueryResults);
            console.log(this.PMQueryResult+ 'PM result');
            console.log('Insurance     Before  '+ this.Insurance);
            this.Insurance = PDQueryResult.Insurance;
            if(this.Insurance === 'null'){
                this.Insurance = 'None';
            }
            console.log('Insurance   ' + this.Insurance);
            this.Fees= PDQueryResult.Fees;
            this.Allocation= PDQueryResult.Allocation;
            this.Price= PDQueryResult.Price;
            if(this.Price === 'null'){
                this.Price = 0;
            }
            this.Budget= PDQueryResult.Budget;
            this.Forecast= PDQueryResult.Forecast;
              
            console.log(' Budget' + this.Budget);
           // this.classValue = ClassCategory.class;
           
            //this.categoryValue = ClassCategory.category;
        })
        .catch(error => {
            this.error = error;
        });
    }
@track ExtraData;
@track loading = false;
@track error = false;
@api recordId;
getcurrentpageurl = (new URL(document.location)).searchParams;
@api jobIdtosearch = this.getcurrentpageurl.get('job__id');
@track contactInfo;
@track notes;
@track briefScope;
@track startDate;
@track completionDate;
@track projectManager;
@track PMQueryResults;
@track Budget;
@track Fees;
@track Allocation;
@track Forecast;
@track Price;
@track Insurance;

startDateChange(event){
    this.startDate = event.detail.value;

}
completionDateChange(event){
    this.completionDate = event.detail.value;

}
contactInfoChange(event){
    this.contactInfo = event.detail.value;

}
briefScopeChange(event){
    this.briefScope = event.detail.value;

}
notesChange(event){
    this.notes = event.detail.value;

}
projectManagerChange(event){
    this.projectManager = event.detail.value;

}

createPMAssignment(){
    if((!this.notes)||(!this.startDate)||(!this.completionDate)||(!this.briefScope)||(!this.contactInfo)){
        this.error = true;
    }else{
        this.loading = true;
    PMAssignmentChatter({startDate:this.startDate, completionDate:this.completionDate,recordId:this.recordId,ownerId:Id,notes:this.notes,briefScope:this.briefScope,contactInfo:this.contactInfo,projectManager:this.projectManager})
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

}