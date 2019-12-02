/* eslint-disable no-alert */
/* eslint-disable no-undef */
/* eslint-disable no-console */
import { LightningElement, wire,api,track} from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import relatedTimesheetsforJobRecord from '@salesforce/apex/dailyTimeSheetlistview.relatedTimesheetsforJobRecord';
import relatedJobNAme from '@salesforce/apex/dailyTimeSheetlistview.relatedJobNAme';
import OnchangeTimesheetDetails from '@salesforce/apex/DailyTimesheetController.OnchangeTimesheetDetails';
import currentUserProfileName from '@salesforce/apex/DailyTimesheetController.currentUserProfileName';
import { loadStyle } from 'lightning/platformResourceLoader';
import lwcOverrideInputStyle from '@salesforce/resourceUrl/OverRideLightningInputStyle';

 const actions = [
    { label: 'Generate PDF', name: 'Generate_PDF' },
    { label: 'Edit', name: 'Edit'},
];

const columns = [
    { label: 'TimeSheet', fieldName: 'Name',type:'Name' },
    { label: 'Start Date', fieldName: 'StartDate__c',type:'date-local'},
    { label: 'End Date', fieldName: 'EndDate__c',type:'date-local'},
    { label: 'Final', fieldName: 'Final__c', type:'boolean'},
    {type: 'action',typeAttributes: { rowActions: actions },
    },
];

export default class DailyTimeSheetlistViewJobpage extends NavigationMixin(LightningElement) {
    
    getcurrentpageurl = (new URL(document.location)).searchParams;

    @api recordId;
   // @api jobIdtosearch = this.getcurrentpageurl.get('ati__jobid');
    @api jobIdtosearch = this.recordId;
    @track dailyTimesheetIdToSearch ;
    @track systemAdministrator;
    @track timesheetDetailList="";
    @track JobDetailList=" ";
    @track displayJobname=" ";
    @track testRow=" ";
    @track columns = columns;
    @track rowOffset = 0;
    @track restrict = false;
    @track userProfile;
    @track record = {};
    @track finalvalue;
    @track dailyTimesheetDetailList='';
    @track openmodel = false;
    @track openmodelalert = false;
    @track dailyTimesheetIdUsedToNavigate;
    
    renderedCallback(){
        loadStyle(this, lwcOverrideInputStyle + '/css/OverRideStyleListView.css');
    }
    
  
/*    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference.state.ati__jobid;
        alert(this.jobIdtosearch);
        alert(this.currentPageReference);
        alert('test -->'+this.currentPageReference);
       // alert(Json.stringify(currentPageReference));
        console.log('Page Reference'+this.currentPageReference);
        console.log(this.currentPageReference);

    } */

    navigateToDailyTimesheetFromEdit(Idvalue) {
           // alert(Idvalue);   
           console.log(Idvalue);        
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'https://' + window.location.hostname + '/lightning/n/dailyTimesheet?dt__id='+this.dailyTimesheetIdUsedToNavigate+'&ati__jobid='+this.jobIdtosearch,
                    replace: false
                }
            });
        
    }

    navigateToDailyTimesheetFromVFPage(Idvalue) {
       
      //  alert(Idvalue);   
      console.log(Idvalue);     
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'https://' + window.location.hostname + '/apex/DailyTimesheetPDFpage?dt__id='+this.dailyTimesheetIdUsedToNavigate,
                    replace: false
                }
            });
        
    }


    @wire(CurrentPageReference)

    setCurrentPageReference(currentPageReference) {

        this.currentPageReference = this.recordId;
        //alert(this.jobIdtosearch);
       // alert(this.currentPageReference);
        console.log('test reference -->'+currentPageReference);
        this.jobIdtosearch = this.currentPageReference;
       // alert(Json.stringify(currentPageReference));
        console.log('Page Reference'+this.currentPageReference);
        console.log(this.currentPageReference);
    }

    @wire (relatedJobNAme , {jobId : '$jobIdtosearch'})
    wiredrelatedJobNAme({ error, data }) {
        if (data) {
           this.JobDetailList = data;
           for(this.i=0;this.i<this.JobDetailList.length;this.i++){  
            this.displayJobname = this.JobDetailList[this.i].Name; 
           }
                    
        } else if (error) {
            this.error = error;
            
        }
        
    }
    
    @wire (relatedTimesheetsforJobRecord , {jobId : '$jobIdtosearch'})
    wiredrelatedTimesheetsforJobRecord({ error, data }) {
        if (data) {
            this.timesheetDetailList = data;
            console.log(this.timesheetDetailList);
            this.AssignCurrentTimesheetIDInNewTimesheetButton();
            
                    
        } else if (error) {
            this.error = error;
            
        }
        
    }

    @wire(currentUserProfileName,{user : 'user'})
    wiredcurrentUserProfileName({error,data })
    {
        
        if(data)
        {
           
            console.log(data);
            this.userProfile = data;
            if(this.userProfile === 'System Administrator')
            {
            this.systemAdministrator=true;
            console.log('systemAdministrator --> '+this.systemAdministrator);
            console.log('profile = '+this.userProfile);
        }
        else if(this.userProfile !== 'System Administrator')
            this.systemAdministrator=false;
            console.log('systemAdministrator --> '+this.systemAdministrator);
            console.log('profile = '+this.userProfile);
        }
        else if(error)
        {
            console.log('error');
        }
    }

    

    AssignCurrentTimesheetIDInNewTimesheetButton()
    {
        var curr1;
        var monday1;
        var first1;
        var d1; 
        var  Date_startDate1;
        curr1 = new Date();         
        d1 = parseFloat(curr1.getDay());
        if(d1 === 0)
        {
            d1 = 7;
        }
        first1 = curr1.getDate() - d1;   
        first1 = first1 + 1;
         monday1 = new Date(curr1.setDate(first1));
        Date_startDate1 = monday1.getFullYear()+'-'+[monday1.getMonth()+1]+'-'+monday1.getDate();
        console.log(Date_startDate1);

        OnchangeTimesheetDetails({
            jobIdtosearch: this.jobIdtosearch,
            StartDate: Date_startDate1,
            })
            .then(result => {
                console.log(result);
                for(this.i=0;this.i<result.length;this.i++){  
                    this.dailyTimesheetIdToSearch= result[0].Id;
                }
            })
            .catch(error => {
                console.log('error');
                console.log(error);
            });
    }
  
    handleActions(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        switch (actionName) {
            case 'Generate_PDF':
               
                this.generatePDF(row);
            //    navigateToDailyTimesheetFromVFPage(row);
                break;
            case 'Edit':
                this.edit(row);
            //   navigateToDailyTimesheetFromEdit(row);
                break;
            default:
        }
     
    }
    generatePDF(row){
        this.record=row;
        this.finalvalue = this.record.Final__c;
        if(this.finalvalue === true || this.systemAdministrator === true)
        {
            this.restrict = false;
            this.record=row;      
          //  alert('test pdf');
            console.log(row);
            this.dailyTimesheetIdUsedToNavigate = this.record.Id;
          window.location= window.location.origin +'/apex/DailyTimesheetPDFpage?dt__id='+this.record.Id ;
          //this.navigateToDailyTimesheetFromVFPage(row);
 
          //  console.log('restrict --> '+this.restrict);
        }
        else{
            this.restrict = true;
            this.openmodelalert = true;
            console.log('restrict --> '+this.restrict);
        }


     /*   if(this.finalvalue){
        this.record=row;      
        window.location= window.location.origin +'/apex/DailyTimesheetPDFpage?dt__id='+this.record.Id ; 
       
    }
    else {
        this.openmodelalert = true;

    }*/
    }
    edit(row){
        this.record=row;
        this.finalvalue = this.record.Final__c;
        console.log('Final Value '+this.finalvalue );
        console.log('System Administrator Value '+this.systemAdministrator);
        if(this.finalvalue === true && this.systemAdministrator === false)
        {
            this.restrict = true;
            this.openmodel = true
            console.log('restrict --> '+this.restrict);
        }
        else{
            
            this.restrict = false;
            this.dailyTimesheetIdUsedToNavigate = this.record.Id;
         //    location.href=window.location.origin + '/lightning/n/dailyTimesheet?dt__id='+this.record.Id+'&ati__jobid='+this.jobIdtosearch;
        // row.action= this.location;  
       //  alert('test edit');
      //  console.log(row);
        this.navigateToDailyTimesheetFromEdit(row);
     //   console.log('Test'+row.Id);
     //       console.log('restrict --> '+this.restrict);
        }

    /*   if(this.finalvalue){
        this.openmodel = true
       }
       else{
        location.href=window.location.origin + '/lightning/n/dailyTimesheet?dt__id='+this.record.Id+'&ati__jobid='+this.jobIdtosearch;
        row.action= this.location;  
        console.log('Test'+this.record.Id);
        
       } */

    }
    closeModal() {
        this.openmodel = false
        this.openmodelalert = false;
    } 


    navigateToDailyTimesheet(event) {
       // alert(event.target.value);
       console.log(event.target.value);
        if(this.dailyTimesheetIdToSearch == null)
        {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'https://' + window.location.hostname + '/lightning/n/dailyTimesheet?ati__jobid='+this.jobIdtosearch,
                        replace: false
                }
            });
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'https://' + window.location.hostname + '/lightning/n/dailyTimesheet?dt__id='+this.dailyTimesheetIdToSearch+'&ati__jobid='+this.jobIdtosearch,
                        replace: false
                }
            });
        }
        
    }

    goToTimeSheet(event){  
        if(this.dailyTimesheetIdToSearch == null)
        {
            alert(this.getcurrentpageurl);
          //  alert(jobIdtosearch);
            alert(this.jobIdtosearch);
            location.href=window.location.origin + '/lightning/n/dailyTimesheet?ati__jobid='+this.jobIdtosearch;  
        }
        else 
        {
            alert(this.getcurrentpageurl);
          //  alert(jobIdtosearch);
            alert(this.jobIdtosearch);
              location.href=window.location.origin + '/lightning/n/dailyTimesheet?dt__id='+this.dailyTimesheetIdToSearch+'&ati__jobid='+this.jobIdtosearch;
        
        }
        event.action= this.location;
         
    }
}