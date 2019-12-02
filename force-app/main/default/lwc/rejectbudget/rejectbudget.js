/**
 * @File Name          : rejectbudget.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/6/2019, 7:57:54 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/5/2019   Sean Gray     Initial Version
**/
import { LightningElement, track, api } from 'lwc';
import REJECTBUDGET from '@salesforce/apex/BudgetFieldUpdate.rejectBudget'; 
import { NavigationMixin } from 'lightning/navigation';
import ApprovedOrRejected from '@salesforce/apex/BudgetFieldUpdate.retrieveBudgetStatus';
//import testLWC from '@salesforce/apex/BudgetFieldUpdate.insertLineItem'; 
var a;
var b;
var c;
var packagedString;
var jsObject;
export default class Rejectbudget extends NavigationMixin (LightningElement) {
    connectedCallback(){ 
        ApprovedOrRejected({recordId : this.recordId}) 
        .then(result => {
            this.data = result;
            a = result;
        if(a === '2'){this.ApprovedOrRejected = false}
        })
        .catch(error => {
            this.error = error;
        });
    }
@track ExtraData;
@api recordId;
@track Comments;
@track commentsBlank = true;
@track data;
@track a;
@track ApprovedOrRejected = true;
@api lineitem;
@track lineitemarray;
@track testtt;
@track loading;


updateComments(event){
    this.Comments = event.detail.value;
    this.commentsBlank = false;

}
// clickInsert(){
//     testLWC({lineitemId : packagedString, recordId : this.recordId})
   

// }
// test(event){
//     this.lineitem = event.detail.value;
//     jsObject= { 'key1' : this.lineitem};
//     packagedString = JSON.stringify(jsObject);
    //c = JSON.parse(this.lineitem);
    //console.log('c ' + c);
    /*b = this.lineitem;
    //this.lineitemarray.push(this.lineitem);
    console.log('line item array ' + this.lineitemarray);
    console.log('line item ' + this.lineitem);
    console.log('line item ' + b);
    this.lineitem.toString();
    this.testtt = this.lineitem.valueOf();
    console.log('TYPE OF ' + typeof(this.lineitem));
    console.log('line item ' + this.lineitem);
    console.log('line item ' + this.testtt);
    console.log('JSON STRINGIFY  ' + JSON.stringify(this.lineitem));
    c = {name: this.lineitem};
    console.log('c is ' + c);
    JSON.stringify(this.lineitem);
    JSON.stringify(c);
    console.log('c after '+c);

    console.log('After json ' + this.lineitem);
    //console.log('After json1 ' + this.lineitem[0]);
   // console.log('After json 2' + this.lineitem.length);
   // console.log('SIZE' + this.lineitemarray.length);

   // console.log('TEST!@#'+ this.lineitemarray);
   // console.log(this.lineitemarray[0]);

    
    //this.testtt.valueOf(this.lineitem);

}*/

submitRejectBudget(){
    this.loading = true;
   REJECTBUDGET({budgetId : this.recordId, comments : this.Comments})
   .then(result => {
    this.ExtraData = result;
    if(this.ExtraData === 'Success'){
        this.dispatchEvent(new CustomEvent('recordChange'));     
    }
//     else{
//         this[NavigationMixin.Navigate]({
//             type: 'standard__recordPage',
//             attributes: {
//                 recordId: this.recordId,
//                 objectApiName: 'Budget__c',
//                 actionName: 'view',
//             },
//         });
        
//     }
// })
   //this.dispatchEvent(new CustomEvent('recordChange'));
    // this[NavigationMixin.Navigate]({
    //     type: 'standard__recordPage',
    //     attributes: {
    //         recordId: this.recordId,
    //         objectApiName: 'Budget__c',
    //         actionName: 'view',
    //     },
    // });
  //  this.dispatchEvent(new CustomEvent('recordChange'));

});
}
ClosePage(){
    
    this.dispatchEvent(new CustomEvent('cancelChange')); 
}
}