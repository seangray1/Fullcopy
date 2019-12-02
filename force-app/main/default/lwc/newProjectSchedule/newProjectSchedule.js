/**
 * @File Name          : newProjectSchedule.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/6/2019, 1:25:09 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/7/2019   Sean Gray     Initial Version
**/
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import ApprovedOrRejected from '@salesforce/apex/ProjectSchedule.ProjectScheduleInsert';
//import testapexBudgetOutput from '@salesforce/apex/ProjectSchedule.testBudget'

var budgetlength;
var i;
var budgetLineItem;
var budgetlineItemsTest = {};
export default class NewProjectSchedule extends NavigationMixin (LightningElement) {
//     connectedCallback(){
//     this.recordId = this.jobIdtosearch;
//     testapexBudgetOutput({recordId:this.recordId})
//         .then(result => {
//             console.log('First Result is : ' + result);
//             this.budgetlineItemsRecieved = result;
//             console.log('Result is '+ this.budgetlineItemsRecieved);
//             budgetlength = this.budgetlineItemsRecieved.length;
//         // i = 0;
//     for (i = 0; i < budgetlength; i++){
//         this.Budgetlineitems.push({name: this.budgetlineItemsRecieved[i],}) 
//     }
//     /*for(budgetLineItem in budgetlineItemsTest){
//         this.Budgetlineitems.push({name: budgetLineItem})   
//     }*/
//     this.Budgetlineitems.shift();
//         })        
//     }
//     @track loading;
//     @track test = true;
//     @track BudgetLineItemRecieved ="";
//     @track schedulename = 'test';
//     @track recordId;
//     @track data;
//     @track testing = 'test';
//     @track Budgetlineitems = [{}];
//     getcurrentpageurl = (new URL(document.location)).searchParams;
//     @api jobIdtosearch = this.getcurrentpageurl.get('job__id');
//     @track startDate;
//     @track endDate;
//     @track ProjectLineItems = [{}];
    

//     UpdateName(event){
//         this.schedulename = event.detail.value;
//     }
//     handleNameChange(event){
//         this.name = event.detail.value;
//     }
//     handleStartDateChange(event){
//         this.startDate = event.detail.value;
//     }
//     handleEndDateChange(event){
//         this.endDate = event.detail.value;
//     }
//     Cancel(){
//         this[NavigationMixin.Navigate]({
//             type: 'standard__recordPage',
//             attributes: {
//                 recordId: this.recordId,
//                 objectApiName: 'ATI_Job__c',
//                 actionName: 'view',
//             },
//         });
//     }
//     CreateProject(){
//         this.loading = true;
//         let UpdatedJSON = this.GenerateProjectJSON();
//         ApprovedOrRejected({schedulename : this.schedulename, recordId : this.recordId, ProjectJSON:UpdatedJSON})
//         .then(result => {
//             this.data = result;
//             if(this.data !== null){
//             this[NavigationMixin.Navigate]({
//                 type: 'standard__recordPage',
//                 attributes: {
//                     recordId: this.data,
//                     objectApiName: 'inspire1__Project__c',
//                     actionName: 'view',
//                 },
//             });
//         }
//         })
    
    
    
// }
//     testBudgetOutput(){
//         testapexBudgetOutput({bud: this.testing})

//     }
    
// GenerateProjectJSON() {
// var ProjectObject = {
// Budgetlineitems : this.getProjectObjects()
// };
// return JSON.stringify(ProjectObject);

// }

// getProjectObjects() {
//     var Projects = [];
//         let ProjTblRow =  Array.from(this.template.querySelectorAll('table.ProjTbl tbody tr'));
//         console.log('ProjTblRow' + ProjTblRow);
//         let ProjRowCount = ProjTblRow.length;
//         for(let Projindex=0; Projindex<ProjRowCount; Projindex++){
//             let ProjName = ProjTblRow[Projindex].querySelector('.ProjName').value;
//             let ProjStartDate = ProjTblRow[Projindex].querySelector('.ProjStartDate').value;
//             let ProjEndDate = ProjTblRow[Projindex].querySelector('.ProjEndDate').value;
//                 Projects.push({
//                     name: ProjName,
//                     startDate: ProjStartDate,
//                     endDate: ProjEndDate
//                 });
//             }
//             console.log('Projects' + Projects);
//             return Projects;
//         }  
}