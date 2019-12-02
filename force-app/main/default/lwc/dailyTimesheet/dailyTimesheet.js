/* eslint-disable no-unused-vars */
/* eslint-disable no-else-return */
/* eslint-disable no-empty */
/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement, wire, track,api} from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import saveDailyTimesheet from '@salesforce/apex/DailyTimesheetController.saveDailyTimesheet';
import currentTimesheetDetails from '@salesforce/apex/DailyTimesheetController.currentTimesheetDetails';
import OnchangeTimesheetDetails from '@salesforce/apex/DailyTimesheetController.OnchangeTimesheetDetails';
import currentJobDetails from '@salesforce/apex/DailyTimesheetController.currentJobDetails';
import currentUserProfileName from '@salesforce/apex/DailyTimesheetController.currentUserProfileName';
import attachonly from '@salesforce/apex/DailyTimesheetPDFController.attachonly';
import { loadStyle } from 'lightning/platformResourceLoader';
import lwcOverrideInputStyle from '@salesforce/resourceUrl/OverRideLightningInputStyle';

export default class DailyTimesheet extends NavigationMixin(LightningElement) {
    @track dailyTimesheetrecord;
    @track error;
    @track test;
    @track restrict = false;
    @track userProfile;
    @track systemAdministrator = false;
    @track recordSavedMessage;
    @track dailyTimesheetId = 'a7G5B0000008nXWUAY';
    @track dailyTimesheetTest = '';
    @track dailyTimesheetJson = '';
    @track dailyTimesheetJobID = '';
    @track dailyTimesheetJobStartDate;
    @track dailyTimesheetJobEndDate;
    @track displayJobname;
    @track displayJobnumber;
    @track displayProjectDirector;
    @track displayProjectSiteAddress;
    @track displayJobStartDate;
    @track displayJobClosetDate;
    @track dailyTimesheetShift;
    @api dailyTimesheetLocation='Day';
    @track dailyTimesheetFinalCheckbox;
    @track dailyTimesheetDetailList="";
    @track dailyTimesheetJobDetails;
    @track jobDetailsfromDailyTimesheetId = '';
    @track ProjectManagers = {};
    @track Supervisors = {};
    @track CrewMembers = {};
    @track Disval;
    @track NextWeekBlock = false;

    @track todayDate;
    @track thisWeekstart;
    @track Date_startDate;
    @track Date_endDate;
    @track loadresult='';
    @track loaderror = '';
    @track comments;
    @track openmodel = false;
    @track SaveComments = '';
    @track MonToCheck; @track TueToCheck; @track WedToCheck; @track ThuToCheck; @track FriToCheck; @track SatToCheck; @track SunToCheck;
    @track DownPDFBtn = false; @track DisableMon =false; @track DisableTue = false; @track DisableWed = false; @track DisableThu = false; @track DisableFri = false; @track DisableSat = false; @track DisableSun = false;

    getcurrentpageurl = (new URL(document.location)).searchParams;
    @api dailyTimesheetIdtosearch= this.getcurrentpageurl.get('dt__id');
    @api jobIdtosearch = this.getcurrentpageurl.get('ati__jobid');
    
    

 /*    curr1 = new Date();         
    @api d1 = parseFloat(curr1.getDay());
    @api first1 = this.curr1.getDate() - this.d1;   
    first1 = this.first1 + 1;
    @api  monday1 = new Date(this.curr1.setDate(this.first1));
    @api Date_startDate1 = this.monday1.getFullYear()+'-'+[this.monday1.getMonth()+1]+'-'+this.monday1.getDate(); */

    
    renderedCallback(){
    var curr1;
    var monday1;
    var first1;
    var d1; 
    var  Date_startDate1;
    curr1 = new Date();         
    d1 = parseFloat(curr1.getDay());
     first1 = curr1.getDate() - d1;   
    first1 = first1 + 1;
     monday1 = new Date(curr1.setDate(first1));
    Date_startDate1 = monday1.getFullYear()+'-'+[monday1.getMonth()+1]+'-'+monday1.getDate();
       console.log('date'+Date_startDate1);

       loadStyle(this, lwcOverrideInputStyle + '/css/OverRideLightningInputStyle.css');
    }
    
    constructor(){
        super();
        this.todayDate = new Date(); 
    }

    @wire(CurrentPageReference)

    setCurrentPageReference(currentPageReference) {
        var dailyTimesheetIdFromNavigateUrl='';
        this.currentPageReference = currentPageReference.state.ati__jobid;
		this.dailyTimesheetIdFromNavigateUrl = currentPageReference.state.dt__id;
        // alert(this.jobIdtosearch);
       //  alert(this.currentPageReference);
      //  alert('test reference -->'+this.currentPageReference);
     //   alert('test reference DT_Id'+this.dailyTimesheetIdFromNavigateUrl);
		this.dailyTimesheetIdtosearch = this.dailyTimesheetIdFromNavigateUrl;
        this.jobIdtosearch = this.currentPageReference;
       // alert(Json.stringify(currentPageReference));
        console.log('Page Reference'+this.currentPageReference);
        console.log(this.currentPageReference);
    }


Datefill(e){
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    var sdate = new Date(e.target.value);
    this.Date_mon = months[sdate.getMonth()]+' '+sdate.getDate();
    this.sdate = sdate.setDate(sdate.getDate() +1);
    this.Date_tue = months[sdate.getMonth()]+' '+sdate.getDate();
    this.sdate = sdate.setDate(sdate.getDate() +1);
    this.Date_wed = months[sdate.getMonth()]+' '+sdate.getDate();
    this.sdate = sdate.setDate(sdate.getDate() +1);
    this.Date_thu = months[sdate.getMonth()]+' '+sdate.getDate();
    this.sdate = sdate.setDate(sdate.getDate() +1);
    this.Date_fri = months[sdate.getMonth()]+' '+sdate.getDate();
    this.sdate = sdate.setDate(sdate.getDate() +1);
    this.Date_sat = months[sdate.getMonth()]+' '+sdate.getDate();
    this.sdate = sdate.setDate(sdate.getDate() +1);
    this.Date_sun = months[sdate.getMonth()]+' '+sdate.getDate();
    // this.Date_endDate = months[sdate.getMonth()]+' '+sdate.getDate()+', '+sdate.getFullYear();
    this.Date_endDate = sdate.getFullYear()+'-'+[sdate.getMonth()+1]+'-'+sdate.getDate();
}

RestrictUIInput()
{
    if(this.dailyTimesheetFinalCheckbox === true && this.systemAdministrator === false)
    {
        this.restrict = true;
        console.log('restrict --> '+this.restrict);
    }
    else{
        this.restrict = false;
        console.log('restrict --> '+this.restrict);
    }
}

PrevWeek(){
    var ss = this.template.querySelector('.StartDate').value;
    var test;
    var d;
    var first;
    var testday;
    var ActualJobStartWeek;
    var ActualJobStartWeek1;
    var UIStartDate1;
    var UIStartDate = new Date(this.template.querySelector('.StartDate').value);
    this.template.querySelector('.DateRit').disabled=false;
    console.log(this.template.querySelector('.StartDate').value);
    
    test = new Date(this.displayJobStartDate);
    
    testday = test.getDay();
    d = parseFloat(testday);
    first = test.getDate() - d;   
    first = first + 1;
    ActualJobStartWeek = new Date(test.setDate(first));
    this.JSdate = ActualJobStartWeek.getDate();
    this.JSmonth = ActualJobStartWeek.getMonth(); //Be careful! January is 0 not 1
    this.JSyear = ActualJobStartWeek.getFullYear();
    ActualJobStartWeek1 = this.JSyear + "-" +(this.JSmonth + 1) + "-" + this.JSdate;

    this.UIdate = UIStartDate.getDate();
    this.UImonth = UIStartDate.getMonth(); //Be careful! January is 0 not 1
    this.UIyear = UIStartDate.getFullYear();
    UIStartDate1 = this.UIyear + "-" +(this.UImonth + 1) + "-" + this.UIdate;
    
    if(ActualJobStartWeek1 === UIStartDate1){
        this.template.querySelector('.DateLeft').disabled=true;
        return;
    }
    // this.date = this.Date_startDate.getDate();
    // this.month = this.Date_startDate.getMonth(); //Be careful! January is 0 not 1
    // this.year = this.Date_startDate.getFullYear();
    // this.Date_startDate = this.year + "-" +(this.month + 1) + "-" + this.date;
    // if(UIStartDate === ActualJobStartWeek){
    //     this.template.querySelector('.DateRit').disabled=true;
    //     return;
    // }
    ss = new Date(ss+' 00:00');
    console.log('line : 157 ss date --------> '+this.ss);
    this.ss = ss.setDate(ss.getDate() -7);
    this.Date_startDate = new Date(ss);

    console.log('line : 161 ss date --------> '+this.ss);
    this.date = this.Date_startDate.getDate();
    this.month = this.Date_startDate.getMonth(); //Be careful! January is 0 not 1
    this.year = this.Date_startDate.getFullYear();
    this.Date_startDate = this.year + "-" +(this.month + 1) + "-" + this.date;
    this.DatefilledOnload();
    this.Disval = 'false';
    console.log(this.Date_startDate);
    let timesheetdata = {};
   // let timesheeterror = {};
    OnchangeTimesheetDetails({
        jobIdtosearch : this.jobIdtosearch,
        StartDate : this.Date_startDate
        })
        .then(result => {

            this.dailyTimesheetDetailList = result; 
          //  console.log('Current timesheet');
          //  console.log(this.dailyTimesheetDetailList);
            
            for(this.i=0;this.i<this.dailyTimesheetDetailList.length;this.i++){  
                this.dailyTimesheetIdtosearch = this.dailyTimesheetDetailList[this.i].Id;
                this.dailyTimesheetJobStartDate = this.dailyTimesheetDetailList[this.i].StartDate__c;
                this.dailyTimesheetJobEndDate = this.dailyTimesheetDetailList[this.i].EndDate__c;
                this.dailyTimesheetLocation = this.dailyTimesheetDetailList[this.i].Location__c;
                this.dailyTimesheetShift = this.dailyTimesheetDetailList[this.i].Shift__c;
                this.comments = this.dailyTimesheetDetailList[this.i].comments__c;

             //   console.log('Line 206 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
                this.dailyTimesheetFinalCheckbox = this.dailyTimesheetDetailList[this.i].Final__c;
                //alert('Final Checkbox:'+this.dailyTimesheetFinalCheckbox);
            //    console.log('Line 213 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
                console.log('Line : 210 dailyTimesheetLocation --> '+this.dailyTimesheetLocation);
               console.log('Line : 211 dailyTimesheetShift --> '+this.dailyTimesheetShift);
              //  this.StartdateOnLoad();
                this.DatefilledOnload(); 
                let dailyTimesheetRecordJson = this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c;
                this.dailyTimesheetrecord = dailyTimesheetRecordJson;
              
              //  console.log('test 2');
            //    console.log('line:190 json Value 1 --> '+this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c);
            //    console.log('line:191 json Value 2 --> '+dailyTimesheetRecordJson.length);

                if(dailyTimesheetRecordJson === 'noData')
                {
                    console.log('Line:194 Append Rows');
                   // this.OverrideEmptyRows();
                    let locationValue = this.template.querySelector('.loc').value;
                    let shiftValue = this.template.querySelector('.shift').value;
                    let commentsValue = this.template.querySelector('.Comments').value;
                    this.template.querySelector('.cpyhoursMon').checked = false;
                    this.template.querySelector('.cpyhoursTue').checked = false;
                    this.template.querySelector('.cpyhoursWed').checked = false;
                    this.template.querySelector('.cpyhoursThu').checked = false;
                    this.template.querySelector('.cpyhoursFri').checked = false;
                    this.template.querySelector('.cpyhoursSat').checked = false;
                    this.template.querySelector('.cpyhoursSun').checked = false;

                    this.template.querySelector('.finalcheckbox').checked = false;
                    
                  //  console.log('location Value --->'+locationValue);
                    if(locationValue !== '' || shiftValue !== 'Day' || commentsValue !== '')
                    {
                      //  console.log('set empty before --> '+this.template.querySelector('.loc').value);
                        this.template.querySelector('.loc').value = '';
                        this.template.querySelector('.shift').value = 'Day';
                        this.template.querySelector('.Comments').value = '';
                       // console.log('set empty after --> '+this.template.querySelector('.loc').value);
                    }

                    this.ProjectManagers=[];
                    this.ProjectManagers.push({
                        Name: ' ',LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                        WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                        ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                        FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                        SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                        SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
                    });
                    
                    this.Supervisors =[];
                    this.Supervisors.push({Name: ' ',PW: false,LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                    ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',SaturdayDBLHours: '',SaturdayOTHours: '',SaturdayRegHours: '',SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''}); 
                   
                    this.CrewMembers=[];
                    this.CrewMembers.push({
                        Name: ' ',PW: false,LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                        WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                        ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                        FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                        SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                        SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
                    });

                    

                    this.Sup_MonTot = 0.0;
                    this.Sup_TueTot = 0.0;
                    this.Sup_WedTot = 0.0;
                    this.Sup_ThuTot = 0.0;
                    this.Sup_FriTot = 0.0; 
                    this.Sup_SatTot = 0.0; 
                    this.Sup_SunTot = 0.0;  

                    this.CM_MonTot = 0.0;  
                    this.CM_TueTot = 0.0;  
                    this.CM_WedTot = 0.0;  
                    this.CM_ThuTot = 0.0; 
                    this.CM_FriTot = 0.0;  
                    this.CM_SatTot = 0.0;  
                    this.CM_SunTot = 0.0;

                    this.PWReg = 0.0;  
                    this.PWOT = 0.0;
                    this.PWDBL = 0.0;  
                    this.NPWReg = 0.0;  
                    this.NPWOT = 0.0;  
                    this.NPWDBL = 0.0;  
                    this.PWRegCW = 0.0;
                    this.PWOTCW = 0.0;  
                    this.PWDBLCW = 0.0;  
                    this.NPWRegCW = 0.0;  
                    this.NPWOTCW = 0.0;  
                    this.NPWDBLCW = 0.0;
                    
                  //  console.log('Line 282 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
                    this.RestrictUIInput();  
                    
                    this.CalulateTotals();
                }
                else if(dailyTimesheetRecordJson.length > 1)
                {
                    


                    this.dailyTimesheetrecord = JSON.parse(this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c);
                    this.ProjectManagers= this.dailyTimesheetrecord.ProjectManagers;
                    this.Supervisors = this.dailyTimesheetrecord.Supervisors;
                    this.CrewMembers = this.dailyTimesheetrecord.CrewMembers;
                //    console.log('this.dailyTimesheetrecord.TotSupMon ------>  '+this.dailyTimesheetrecord.TotSupMon);
                 //   console.log('this.TotSupTue ------> '+this.TotSupTue);
                    this.Sup_MonTot = this.dailyTimesheetrecord.TotSupMon;
                    this.Sup_TueTot = this.dailyTimesheetrecord.TotSupTue;
                    this.Sup_WedTot = this.dailyTimesheetrecord.TotSupWed;
                    this.Sup_ThuTot = this.dailyTimesheetrecord.TotSupThu;
                    this.Sup_FriTot = this.dailyTimesheetrecord.TotSupFri; 
                    this.Sup_SatTot = this.dailyTimesheetrecord.TotSupSat; 
                    this.Sup_SunTot = this.dailyTimesheetrecord.TotSupSun;  

                    this.CM_MonTot = this.dailyTimesheetrecord.TotCwMon;  
                    this.CM_TueTot = this.dailyTimesheetrecord.TotCwTue;  
                    this.CM_WedTot = this.dailyTimesheetrecord.TotCWwed;  
                    this.CM_ThuTot = this.dailyTimesheetrecord.TotCwThu; 
                    this.CM_FriTot = this.dailyTimesheetrecord.TotCwFri;  
                    this.CM_SatTot = this.dailyTimesheetrecord.TotCwSat;  
                    this.CM_SunTot = this.dailyTimesheetrecord.TotCwSun;  

                    this.PWReg = this.dailyTimesheetrecord.TotSupPWReg;  
                    this.PWOT = this.dailyTimesheetrecord.TotSupPWOT;
                    this.PWDBL = this.dailyTimesheetrecord.TotSupPWDBL;  
                    this.NPWReg = this.dailyTimesheetrecord.TotSupNPWReg;  
                    this.NPWOT = this.dailyTimesheetrecord.TotSupNPWOT;  
                    this.NPWDBL = this.dailyTimesheetrecord.TotSupNPWDBL;  
                    this.PWRegCW = this.dailyTimesheetrecord.TotCWPWReg;
                    this.PWOTCW = this.dailyTimesheetrecord.TotCWPWOT;  
                    this.PWDBLCW = this.dailyTimesheetrecord.TotCWPWDBL;  
                    this.NPWRegCW = this.dailyTimesheetrecord.TotCWNPWReg;  
                    this.NPWOTCW = this.dailyTimesheetrecord.TotCWNPWOT;  
                    this.NPWDBLCW = this.dailyTimesheetrecord.TotCWNPWDBL; 
                    this.CalulateTotals();
                    this.RestrictUIInput();
                    
                 //   console.log('Afer append');
                    
                }
                else
                {
                    this.AppendEmptyRows();
                   // this.StartdateOnLoad();
                    this.DatefilledOnload(); 
                    this.CalulateTotals();
                }
             }        
           /* timesheetdata = result;
            console.log('success');
            console.log(result);
            this.test = result;
           this.wiredcurrentTimesheetDetails(timesheeterror,this.timesheetdata); */
        
        })
        .catch(error => {
            //timesheeterror = error;
            console.log('line:244 error');
          //  console.log(error);
            
        });
        if(timesheetdata)
        { 
           // console.log('timesheet resilt');
         //   console.log(timesheetdata);
         //   console.log(timesheetdata.Id);
            this.dailyTimesheetIdtosearch = timesheetdata.Id; 
            //this.wiredcurrentTimesheetDetails(timesheeterror,timesheetdata);}
        }

}

NextWeek(){
    var ss = this.template.querySelector('.StartDate').value;
    
    var UIEndDate = new Date(this.template.querySelector('.WeekEndDate').value);
    var CurrentWeekEndDate;
    var curr = new Date();          
    var d = parseFloat(curr.getDay());
    var first = curr.getDate() - d;   
    first = first + 1;
    CurrentWeekEndDate = new Date(curr.setDate(first));
    CurrentWeekEndDate = new Date(CurrentWeekEndDate.setDate(CurrentWeekEndDate.getDate() +6));
    this.date = UIEndDate.getDate(); this.month = UIEndDate.getMonth(); this.year = UIEndDate.getFullYear();
    UIEndDate = this.year + "-" +(this.month + 1) + "-" + this.date;
    this.date = CurrentWeekEndDate.getDate(); this.month = CurrentWeekEndDate.getMonth(); this.year = CurrentWeekEndDate.getFullYear();
    CurrentWeekEndDate = this.year + "-" +(this.month + 1) + "-" + this.date;

   // console.log('UIDate:'+UIEndDate+' WeekEndDate:'+CurrentWeekEndDate);
    if(UIEndDate === CurrentWeekEndDate){
        this.template.querySelector('.DateRit').disabled=true;
        return;
    }
    
  //  console.log(this.template.querySelector('.StartDate').value);
    ss = new Date(ss+' 00:00');
    this.ss = ss.setDate(ss.getDate() +7);
    this.Date_startDate = new Date(ss);
    this.date = this.Date_startDate.getDate();
    this.month = this.Date_startDate.getMonth(); //Be careful! January is 0 not 1
    this.year = this.Date_startDate.getFullYear();
    this.Date_startDate = this.year + "-" +(this.month + 1) + "-" + this.date;
    this.DatefilledOnload();

    
   // let timesheeterror = {};
    OnchangeTimesheetDetails({
        jobIdtosearch : this.jobIdtosearch,
        StartDate : this.Date_startDate
        })
        .then(result => {

            this.dailyTimesheetDetailList = result; 
         //   console.log('Current timesheet');
         //   console.log(this.dailyTimesheetDetailList);
            for(this.i=0;this.i<this.dailyTimesheetDetailList.length;this.i++){  
                this.dailyTimesheetIdtosearch = this.dailyTimesheetDetailList[this.i].Id;
                this.dailyTimesheetJobStartDate = this.dailyTimesheetDetailList[this.i].StartDate__c;
                this.dailyTimesheetJobEndDate = this.dailyTimesheetDetailList[this.i].EndDate__c;
                this.dailyTimesheetLocation = this.dailyTimesheetDetailList[this.i].Location__c;
                this.dailyTimesheetShift = this.dailyTimesheetDetailList[this.i].Shift__c;
                this.comments = this.dailyTimesheetDetailList[this.i].comments__c;
             //   console.log('Line 411 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
                this.dailyTimesheetFinalCheckbox = this.dailyTimesheetDetailList[this.i].Final__c;
            //    console.log('Line 413 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
               // this.StartdateOnLoad();
               console.log('Line : 415 dailyTimesheetLocation --> '+this.dailyTimesheetLocation);
               console.log('Line : 416 dailyTimesheetShift --> '+this.dailyTimesheetShift);
                this.DatefilledOnload(); 
                let dailyTimesheetRecordJson = this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c;
            //    console.log('test 2');

                if(dailyTimesheetRecordJson === 'noData')
                {
                    console.log('Line:194 OverrideEmptyRows');
                    
                    let locationValue = this.template.querySelector('.loc').value;
                    let shiftValue = this.template.querySelector('.shift').value;
                    let commentsValue = this.template.querySelector('.Comments').value;
                 //   console.log('cpy hours ---> '+this.template.querySelector('.cpyhours').checked);
                    this.template.querySelector('.cpyhoursMon').checked = false;
                    this.template.querySelector('.cpyhoursTue').checked = false;
                    this.template.querySelector('.cpyhoursWed').checked = false;
                    this.template.querySelector('.cpyhoursThu').checked = false;
                    this.template.querySelector('.cpyhoursFri').checked = false;
                    this.template.querySelector('.cpyhoursSat').checked = false;
                    this.template.querySelector('.cpyhoursSun').checked = false;
                    
                    
                    this.template.querySelector('.finalcheckbox').checked = false;
                    
                  //  console.log('location Value --->'+locationValue);
                    if(locationValue !== '' || shiftValue !== 'Day' || commentsValue !== '')
                    {
                      //  console.log('set empty before --> '+this.template.querySelector('.loc').value);
                        this.template.querySelector('.loc').value = '';
                        this.template.querySelector('.shift').value = 'Day';
                        this.template.querySelector('.Comments').value = '';
                       // console.log('set empty after --> '+this.template.querySelector('.loc').value);
                    }

                    this.ProjectManagers=[];
                    this.ProjectManagers.push({
                        Name: ' ',LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                        WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                        ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                        FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                        SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                        SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
                    });
                    
                    this.Supervisors =[];
                    this.Supervisors.push({Name: ' ',PW: false,LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                    ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',SaturdayDBLHours: '',SaturdayOTHours: '',SaturdayRegHours: '',SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''}); 
                   
                    this.CrewMembers=[];
                    this.CrewMembers.push({
                        Name: ' ',PW: false,LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                        WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                        ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                        FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                        SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                        SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
                    });

                    

                    this.Sup_MonTot = 0.0;
                    this.Sup_TueTot = 0.0;
                    this.Sup_WedTot = 0.0;
                    this.Sup_ThuTot = 0.0;
                    this.Sup_FriTot = 0.0; 
                    this.Sup_SatTot = 0.0; 
                    this.Sup_SunTot = 0.0;  

                    this.CM_MonTot = 0.0;  
                    this.CM_TueTot = 0.0;  
                    this.CM_WedTot = 0.0;  
                    this.CM_ThuTot = 0.0; 
                    this.CM_FriTot = 0.0;  
                    this.CM_SatTot = 0.0;  
                    this.CM_SunTot = 0.0;

                    this.PWReg = 0.0;  
                    this.PWOT = 0.0;
                    this.PWDBL = 0.0;  
                    this.NPWReg = 0.0;  
                    this.NPWOT = 0.0;  
                    this.NPWDBL = 0.0;  
                    this.PWRegCW = 0.0;
                    this.PWOTCW = 0.0;  
                    this.PWDBLCW = 0.0;  
                    this.NPWRegCW = 0.0;  
                    this.NPWOTCW = 0.0;  
                    this.NPWDBLCW = 0.0;

                    this.dailyTimesheetFinalCheckbox = 'false';
                //    console.log('Line 477 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
                    this.RestrictUIInput(); 
                    this.dailyTimesheetFinalCheckbox = 'false';
                    this.CalulateTotals();
                }

                else if(dailyTimesheetRecordJson.length > 1)
                {
                    
                    this.dailyTimesheetrecord = JSON.parse(this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c);
                    this.ProjectManagers= this.dailyTimesheetrecord.ProjectManagers;
                    this.Supervisors = this.dailyTimesheetrecord.Supervisors;
                    this.CrewMembers = this.dailyTimesheetrecord.CrewMembers;
                    this.Sup_MonTot = this.dailyTimesheetrecord.TotSupMon;
                    this.Sup_TueTot = this.dailyTimesheetrecord.TotSupTue;
                    this.Sup_WedTot = this.dailyTimesheetrecord.TotSupWed;
                    this.Sup_ThuTot = this.dailyTimesheetrecord.TotSupThu;
                    this.Sup_FriTot = this.dailyTimesheetrecord.TotSupFri; 
                    this.Sup_SatTot = this.dailyTimesheetrecord.TotSupSat; 
                    this.Sup_SunTot = this.dailyTimesheetrecord.TotSupSun;  

                    this.CM_MonTot = this.dailyTimesheetrecord.TotCwMon;  
                    this.CM_TueTot = this.dailyTimesheetrecord.TotCwTue;  
                    this.CM_WedTot = this.dailyTimesheetrecord.TotCWwed;  
                    this.CM_ThuTot = this.dailyTimesheetrecord.TotCwThu; 
                    this.CM_FriTot = this.dailyTimesheetrecord.TotCwFri;  
                    this.CM_SatTot = this.dailyTimesheetrecord.TotCwSat;  
                    this.CM_SunTot = this.dailyTimesheetrecord.TotCwSun;  

                    this.PWReg = this.dailyTimesheetrecord.TotSupPWReg;  
                    this.PWOT = this.dailyTimesheetrecord.TotSupPWOT;
                    this.PWDBL = this.dailyTimesheetrecord.TotSupPWDBL;  
                    this.NPWReg = this.dailyTimesheetrecord.TotSupNPWReg;  
                    this.NPWOT = this.dailyTimesheetrecord.TotSupNPWOT;  
                    this.NPWDBL = this.dailyTimesheetrecord.TotSupNPWDBL;  
                    this.PWRegCW = this.dailyTimesheetrecord.TotCWPWReg;
                    this.PWOTCW = this.dailyTimesheetrecord.TotCWPWOT;  
                    this.PWDBLCW = this.dailyTimesheetrecord.TotCWPWDBL;  
                    this.NPWRegCW = this.dailyTimesheetrecord.TotCWNPWReg;  
                    this.NPWOTCW = this.dailyTimesheetrecord.TotCWNPWOT;  
                    this.NPWDBLCW = this.dailyTimesheetrecord.TotCWNPWDBL;  
                    this.CalulateTotals();
                    this.RestrictUIInput();
                    
                }
                else
                {
                    console.log('line:353 append empty rows');
                    this.AppendEmptyRows();
                  //  this.StartdateOnLoad();
                    this.DatefilledOnload(); 
                }
             }        
           /* timesheetdata = result;
            console.log('success');
            console.log(result);
            this.test = result;
           this.wiredcurrentTimesheetDetails(timesheeterror,this.timesheetdata); */
        
        })
        .catch(error => {
            //timesheeterror = error;
            console.log('line:367 error');
            console.log(error);
            
        });

}

//Disable Controls on Final is Checked
DisableAllControls(){
    if(this.dailyTimesheetFinalCheckbox){
        // let InputControls = Array.from(this.template.querySelectorAll('.FullContainer lightning-input, .FullContainer lightning-button, .FullContainer lightning-combobox, .FullContainer lightning-textarea'));
        // for(let i=0; i<InputControls.length; i++){
        //     InputControls[i].disabled=true;
        // }
        this.template.querySelector('.DateLeft').disabled =  false;
        this.template.querySelector('.DateRit').disabled =  false;
    } else{
        // let InputControls = Array.from(this.template.querySelectorAll('.FullContainer lightning-input, .FullContainer lightning-button, .FullContainer lightning-combobox, .FullContainer lightning-textarea'));
        // for(let i=0; i<InputControls.length; i++){
        //     InputControls[i].disabled=false;
        // }
    }
}

//Disable Date control on Edit view
DisableDateControls(){
    if(this.dailyTimesheetIdtosearch){
        this.template.querySelector('.DateLeft').style.display = 'none';
        this.template.querySelector('.DateRit').style.display = 'none';
    }
}

//Validate for Number only
ValidateForNoOnly(evt){
    var keycode = evt.which;
    if (!(keycode >= 48 && keycode <= 57) && !(keycode===190) && !(keycode===9) && !(keycode===8) && !(keycode===39) && !(keycode===37) && !(keycode===47) && !(keycode===46) && !(keycode===110) && !(keycode >= 96 && keycode <= 105) ) {
        evt.preventDefault();
    }
}

//Close Save Popup
closeModal(){
    if(this.SaveComments === 'Timesheet Saved Successfully..'){
        this.openmodel = false;
        window.location= window.location.origin +'/lightning/n/DailyTimesheetListView?ati__jobid='+this.jobIdtosearch;
    }
    else{
        this.openmodel = false;   
    }
}

//Override Empty Row Values on change if noData

OverrideEmptyRows()
{
                    this.ProjectManagers=[];
                    this.ProjectManagers.push({
                        Name: ' ',LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                        WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                        ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                        FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                        SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                        SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
                    });
                    
                    this.Supervisors =[];
                    this.Supervisors.push({Name: ' ',PW: false,LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                    ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',SaturdayDBLHours: '',SaturdayOTHours: '',SaturdayRegHours: '',SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''}); 
                   
                    this.CrewMembers=[];
                    this.CrewMembers.push({
                        Name: ' ',PW: false,LaborCode: 'None',MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                        WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                        ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                        FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                        SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                        SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
                    });

                    
}

//Validate PM for 24hrs
ValidatehrsPM(e) {
    var elm = e.target.value;
   // var reg = /^[-+]?\d*\.?\d*$/;
    var reg = /^\d*\.?\d*$/;

    let AllClassName = ['PM_Monday', 'PM_Tuesday', 'PM_Wednesday', 'PM_Thursday', 'PM_Friday', 'PM_Saturday', 'PM_Sunday'];
    let SetTot = 0.0;

    if(!reg.test(elm)){
        alert('Please enter a valid format');
        e.target.value ='';
        e.target.focus();
    }

    if(e.target.value>24){
        alert('The total hours cannot be more than 24 hours for a day.');
        e.target.value='';
        e.target.focus();
    }
    let ThisclassName = (e.target.className).split(' ');
    const CommonClassName = AllClassName.filter(element => ThisclassName.includes(element));
    // let GetTot = Array.from(
    //     this.template.querySelectorAll('lightning-input.'+CommonClassName[0])
    // );
    // for(let i=0; i< GetTot.length; i++){
    //     if(GetTot[i].value){
    //         SetTot += parseFloat(GetTot[i].value);
    //     }
    // }

    let TableRowIndex;
    if(e.target.classList.contains('PM_OT') || e.target.classList.contains('PM_DBL'))
        TableRowIndex = e.target.parentNode.parentNode.parentNode.parentNode.rowIndex-1;
    else
        TableRowIndex = e.target.parentNode.parentNode.parentNode.rowIndex-1;
    let PMTblRow = Array.from(this.template.querySelectorAll('table.PMTbl tbody tr'));
    let GetAllTot = Array.from(
        PMTblRow[TableRowIndex].querySelectorAll('lightning-input.'+CommonClassName[0])
    ); 
    for(let i=0; i< GetAllTot.length; i++){
        if(GetAllTot[i].value)
            SetTot += parseFloat(GetAllTot[i].value);
    }

    if(SetTot>24){
        alert('The total hours cannot be more than 24 hours for a day.');
        e.target.value='';
        e.target.focus();
    }
}
    //Get Sum of hrs Supervisor & Crew member
    @track Sup_MonTot = 0.0; @track Sup_TueTot = 0.0; @track Sup_WedTot = 0.0; @track Sup_ThuTot = 0.0; @track Sup_FriTot = 0.0; @track Sup_SatTot = 0.0; @track Sup_SunTot = 0.0; 
    @track CM_MonTot = 0.0; @track CM_TueTot = 0.0; @track CM_WedTot = 0.0; @track CM_ThuTot = 0.0; @track CM_FriTot = 0.0; @track CM_SatTot = 0.0; @track CM_SunTot = 0.0;

    @track PWReg = 0.0; @track PWOT = 0.0; @track PWDBL = 0.0;
    @track NPWReg = 0.0; @track NPWOT = 0.0; @track NPWDBL = 0.0;
    @track PWRegCW = 0.0; @track PWOTCW = 0.0; @track PWDBLCW = 0.0;
    @track NPWRegCW = 0.0; @track NPWOTCW = 0.0; @track NPWDBLCW = 0.0;

    GetOvrallTot(DataGot, Desgn){
        
        var GetAllData = DataGot;
        let SupMonTot =0; let SupTueTot =0; let SupWedTot =0; let SupThuTot =0; let SupFriTot =0; let SupSatTot =0; let SupSunTot =0;
        let  PWRegTot = 0.0; let  PWOTTot = 0.0; let  PWDBLTot = 0.0; let  NPWRegTot = 0.0; let  NPWOTTot = 0.0; let  NPWDBLTot = 0.0;
       // console.log('OverTotData:'+GetAllData);
        if(GetAllData.length>0){
            for(let i=0; i<GetAllData.length; i++){
                // Start Total
                SupMonTot += this.changetoZeroIfNull(GetAllData[i].MondayDBLHours) + this.changetoZeroIfNull(GetAllData[i].MondayOTHours)  + this.changetoZeroIfNull(GetAllData[i].MondayRegHours);
           
                SupTueTot += this.changetoZeroIfNull(GetAllData[i].TuesdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].TuesdayOTHours)  + this.changetoZeroIfNull(GetAllData[i].TuesdayRegHours);
           
                SupWedTot += this.changetoZeroIfNull(GetAllData[i].WednesdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].WednesdayOTHours)  + this.changetoZeroIfNull(GetAllData[i].WednesdayRegHours);
           
                SupThuTot += this.changetoZeroIfNull(GetAllData[i].ThursdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].ThursdayOTHours)  + this.changetoZeroIfNull(GetAllData[i].ThursdayRegHours);
           
                SupFriTot += this.changetoZeroIfNull(GetAllData[i].FridayDBLHours) + this.changetoZeroIfNull(GetAllData[i].FridayOTHours)  + this.changetoZeroIfNull(GetAllData[i].FridayRegHours);
           
                SupSatTot += this.changetoZeroIfNull(GetAllData[i].SaturdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].SaturdayOTHours)  + this.changetoZeroIfNull(GetAllData[i].SaturdayRegHours);
           
                SupSunTot += this.changetoZeroIfNull(GetAllData[i].SundayDBLHours) + this.changetoZeroIfNull(GetAllData[i].SundayOTHours)  + this.changetoZeroIfNull(GetAllData[i].SundayRegHours);

                //Start PW overall total
                if(GetAllData[i].PW===true){
                    PWRegTot += this.changetoZeroIfNull(GetAllData[i].MondayRegHours) + this.changetoZeroIfNull(GetAllData[i].TuesdayRegHours) + this.changetoZeroIfNull(GetAllData[i].WednesdayRegHours) + this.changetoZeroIfNull(GetAllData[i].ThursdayRegHours) + this.changetoZeroIfNull(GetAllData[i].FridayRegHours) + this.changetoZeroIfNull(GetAllData[i].SaturdayRegHours) + this.changetoZeroIfNull(GetAllData[i].SundayRegHours);

                    PWOTTot += this.changetoZeroIfNull(GetAllData[i].MondayOTHours) + this.changetoZeroIfNull(GetAllData[i].TuesdayOTHours) + this.changetoZeroIfNull(GetAllData[i].WednesdayOTHours) + this.changetoZeroIfNull(GetAllData[i].ThursdayOTHours) + this.changetoZeroIfNull(GetAllData[i].FridayOTHours) + this.changetoZeroIfNull(GetAllData[i].SaturdayOTHours) + this.changetoZeroIfNull(GetAllData[i].SundayOTHours);

                    PWDBLTot += this.changetoZeroIfNull(GetAllData[i].MondayDBLHours) + this.changetoZeroIfNull(GetAllData[i].TuesdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].WednesdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].ThursdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].FridayDBLHours) + this.changetoZeroIfNull(GetAllData[i].SaturdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].SundayDBLHours);
                } else{
                    NPWRegTot += this.changetoZeroIfNull(GetAllData[i].MondayRegHours) + this.changetoZeroIfNull(GetAllData[i].TuesdayRegHours) + this.changetoZeroIfNull(GetAllData[i].WednesdayRegHours) + this.changetoZeroIfNull(GetAllData[i].ThursdayRegHours) + this.changetoZeroIfNull(GetAllData[i].FridayRegHours) + this.changetoZeroIfNull(GetAllData[i].SaturdayRegHours) + this.changetoZeroIfNull(GetAllData[i].SundayRegHours);

                    NPWOTTot += this.changetoZeroIfNull(GetAllData[i].MondayOTHours) + this.changetoZeroIfNull(GetAllData[i].TuesdayOTHours) + this.changetoZeroIfNull(GetAllData[i].WednesdayOTHours) + this.changetoZeroIfNull(GetAllData[i].ThursdayOTHours) + this.changetoZeroIfNull(GetAllData[i].FridayOTHours) + this.changetoZeroIfNull(GetAllData[i].SaturdayOTHours) + this.changetoZeroIfNull(GetAllData[i].SundayOTHours);

                    NPWDBLTot += this.changetoZeroIfNull(GetAllData[i].MondayDBLHours) + this.changetoZeroIfNull(GetAllData[i].TuesdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].WednesdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].ThursdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].FridayDBLHours) + this.changetoZeroIfNull(GetAllData[i].SaturdayDBLHours) + this.changetoZeroIfNull(GetAllData[i].SundayDBLHours);
                }
            }
        }
        if(Desgn==='Sup'){
            this.Sup_MonTot = SupMonTot.toFixed(2); this.Sup_TueTot = SupTueTot.toFixed(2); this.Sup_WedTot = SupWedTot.toFixed(2); this.Sup_ThuTot = SupThuTot.toFixed(2); this.Sup_FriTot = SupFriTot.toFixed(2); this.Sup_SatTot = SupSatTot.toFixed(2); this.Sup_SunTot = SupSunTot.toFixed(2);this.PWReg = PWRegTot.toFixed(2); this.PWOT = PWOTTot.toFixed(2); this.PWDBL = PWDBLTot.toFixed(2); this.NPWReg = NPWRegTot.toFixed(2); this.NPWOT = NPWOTTot.toFixed(2); this.NPWDBL = NPWDBLTot.toFixed(2);
        } else if(Desgn==='CM'){
            this.CM_MonTot = SupMonTot.toFixed(2); this.CM_TueTot = SupTueTot.toFixed(2); this.CM_WedTot = SupWedTot.toFixed(2); this.CM_ThuTot = SupThuTot.toFixed(2); this.CM_FriTot = SupFriTot.toFixed(2); this.CM_SatTot = SupSatTot.toFixed(2); this.CM_SunTot = SupSunTot.toFixed(2);

            this.PWRegCW = PWRegTot.toFixed(2); this.PWOTCW = PWOTTot.toFixed(2); this.PWDBLCW = PWDBLTot.toFixed(2); this.NPWRegCW = NPWRegTot.toFixed(2); this.NPWOTCW = NPWOTTot.toFixed(2); this.NPWDBLCW = NPWDBLTot.toFixed(2);
        }
    }

    GetDayTot(e){
        
        //Validate Input to Restrict only 24hrs
        
        //var reg = new RegExp(/^((([0-9]|0[0-9]|1[0-9]|2[0-3])(.[0-5][0-9]?)?)|((24)(.[0]{1,2})?))$/);
        //var ValidateVal = reg.exec(e.target.value);
        var elm = e.target.value;
        //var reg = /^[-+]?\d*\.?\d*$/;
        var reg = /^\d*\.?\d*$/;

        if(!reg.test(elm)){
            alert('Please enter a valid format');
            e.target.value ='';
            e.target.focus();
        }

        if(e.target.value>24){
            alert('The total hours cannot be more than 24 hours for a day.');
            e.target.value='';
            e.target.focus();
        }
        
        // if (ValidateVal === null) {
        //     alert('Not a Valid Format..');
        //     e.target.value='';
        //     e.target.focus();
        // }

        let SetTot = 0.0;
        let AllClassName = ['Sup_Monday', 'Sup_Tuesday', 'Sup_Wednesday', 'Sup_Thursday', 'Sup_Friday', 'Sup_Saturday', 'Sup_Sunday', 'CM_Monday', 'CM_Tuesday', 'CM_Wednesday', 'CM_Thursday', 'CM_Friday', 'CM_Saturday', 'CM_Sunday'];
        let ThisclassName = (e.target.className).split(' ');
        let CommonClassName = AllClassName.filter(element => ThisclassName.includes(element));
        
        // Start 24hrs Validation
        let CheckClassName = CommonClassName[0].split('_');
        if(CheckClassName[0]==='Sup'){
            let TableRowIndex;
            if(e.target.classList.contains('Sup_OT') || e.target.classList.contains('Sup_DBL'))
                TableRowIndex = e.target.parentNode.parentNode.parentNode.parentNode.rowIndex-1;
            else
                TableRowIndex = e.target.parentNode.parentNode.parentNode.rowIndex-1;
            let SupTblRow = Array.from(this.template.querySelectorAll('table.SupTbl tbody tr'));
            let GetAllTot = Array.from(
                SupTblRow[TableRowIndex].querySelectorAll('lightning-input.'+CommonClassName[0])
            ); 
            for(let i=0; i< GetAllTot.length; i++){
                if(GetAllTot[i].value)
                    SetTot += parseFloat(GetAllTot[i].value);
            }
            if(SetTot>24){
                alert('The total hours cannot be more than 24 hours for a day.');
                e.target.value='';
                e.target.focus();
            }
        } else{
            let TableRowIndex;
            if(e.target.classList.contains('CM_OT') || e.target.classList.contains('CM_DBL'))
                TableRowIndex = e.target.parentNode.parentNode.parentNode.parentNode.rowIndex-1;
            else
                TableRowIndex = e.target.parentNode.parentNode.parentNode.rowIndex-1;
            let CMTblRow = Array.from(this.template.querySelectorAll('table.CWTbl tbody tr'));
            let GetAllTot = Array.from(
                CMTblRow[TableRowIndex].querySelectorAll('lightning-input.'+CommonClassName[0])
            ); 
            for(let i=0; i< GetAllTot.length; i++){
                if(GetAllTot[i].value)
                    SetTot += parseFloat(GetAllTot[i].value);
            }
            if(SetTot>24){
                alert('The total hours cannot be more than 24 hours for a day.');
                e.target.value='';
                e.target.focus();
            }
        }
        // End 24hrs Validation
        let SetTot1 =0.0;
        let GetTot1 = Array.from(
            this.template.querySelectorAll('lightning-input.'+CommonClassName[0])
        );
        for(let i=0; i< GetTot1.length; i++){
            if(GetTot1[i].value)
                SetTot1 += parseFloat(GetTot1[i].value);
        }
        
        this.GetOverTotal();
        switch (CommonClassName[0]){
            case 'Sup_Monday':
               this.Sup_MonTot = SetTot1.toFixed(2);
            break;
            case 'Sup_Tuesday':
               this.Sup_TueTot = SetTot1.toFixed(2);
            break;
            case 'Sup_Wednesday':
               this.Sup_WedTot = SetTot1.toFixed(2);
            break;
            case 'Sup_Thursday':
               this.Sup_ThuTot = SetTot1.toFixed(2);
            break;
            case 'Sup_Friday':
               this.Sup_FriTot = SetTot1.toFixed(2);
            break;
            case 'Sup_Saturday':
               this.Sup_SatTot = SetTot1.toFixed(2);
            break;
            case 'Sup_Sunday':
               this.Sup_SunTot = SetTot1.toFixed(2);
            break;
            case 'CM_Monday':
               this.CM_MonTot = SetTot1.toFixed(2);
            break;
            case 'CM_Tuesday':
               this.CM_TueTot = SetTot1.toFixed(2);
            break;
            case 'CM_Wednesday':
               this.CM_WedTot = SetTot1.toFixed(2);
            break;
            case 'CM_Thursday':
               this.CM_ThuTot = SetTot1.toFixed(2);
            break;
            case 'CM_Friday':
               this.CM_FriTot = SetTot1.toFixed(2);
            break;
            case 'CM_Saturday':
               this.CM_SatTot = SetTot1.toFixed(2);
            break;
            case 'CM_Sunday':
               this.CM_SunTot = SetTot1.toFixed(2);
            break;
            default:
        }
    }


  //Get Overall Total for PW and Non-PW
    GetOverTotal(){
        // For Supervisor 
        
        let SupTblRow =  Array.from(this.template.querySelectorAll('table.SupTbl tbody tr'));
        let  PWRegTot = 0.0; let  PWOTTot = 0.0; let  PWDBLTot = 0.0;
        let  NPWRegTot = 0.0; let  NPWOTTot = 0.0; let  NPWDBLTot = 0.0;
        if(SupTblRow.length>0){
            for(let k=0; k<SupTblRow.length; k++){
            let PW = SupTblRow[k].querySelector('.SupPw');
                let chkdValue = PW.checked;
                if(chkdValue){
                    let PWTblReg = Array.from(SupTblRow[k].querySelectorAll('.Sup_Reg'));
                    let PWTblOt = Array.from(SupTblRow[k].querySelectorAll('.Sup_OT'));
                    let PWTblDbl = Array.from(SupTblRow[k].querySelectorAll('.Sup_DBL'));
                    for (let m=0; m<PWTblReg.length; m++){
                        if(PWTblReg[m].value) PWRegTot += parseFloat(PWTblReg[m].value);
                    } for (let m=0; m<PWTblOt.length; m++){
                        if(PWTblOt[m].value) PWOTTot += parseFloat(PWTblOt[m].value);
                    } for (let m=0; m<PWTblDbl.length; m++){
                        if(PWTblDbl[m].value) PWDBLTot += parseFloat(PWTblDbl[m].value);
                    }
                } 
                if(!chkdValue)
                {
                    let TblReg = Array.from(SupTblRow[k].querySelectorAll('.Sup_Reg'));
                    let TblOt = Array.from(SupTblRow[k].querySelectorAll('.Sup_OT'));
                    let TblDbl = Array.from(SupTblRow[k].querySelectorAll('.Sup_DBL'));
                    for (let m=0; m<TblReg.length; m++){
                        if(TblReg[m].value) NPWRegTot += parseFloat(TblReg[m].value);
                    } for (let m=0; m<TblOt.length; m++){
                        if(TblOt[m].value) NPWOTTot += parseFloat(TblOt[m].value);
                    } for (let m=0; m<TblDbl.length; m++){
                        if(TblDbl[m].value) NPWDBLTot += parseFloat(TblDbl[m].value);
                    }
                }
            }
        }
        this.PWReg = PWRegTot.toFixed(2); this.PWOT = PWOTTot.toFixed(2); this.PWDBL = PWDBLTot.toFixed(2);
        this.NPWReg = NPWRegTot.toFixed(2); this.NPWOT = NPWOTTot.toFixed(2); this.NPWDBL = NPWDBLTot.toFixed(2);

        // For Crew Member 
        let CWTblRow =  Array.from(this.template.querySelectorAll('table.CWTbl tbody tr'));
        let  PWRegTotCW = 0.0; let  PWOTTotCW = 0.0; let  PWDBLTotCW = 0.0;
        let  NPWRegTotCW = 0.0; let  NPWOTTotCW = 0.0; let  NPWDBLTotCW = 0.0;
        if(CWTblRow.length>0){
            for(let k=0; k<CWTblRow.length; k++){
            let PWCW = CWTblRow[k].querySelector('.CwPw');
                let chkdValueCW = PWCW.checked;
                if(chkdValueCW){
                    let PWTblRegCW = Array.from(CWTblRow[k].querySelectorAll('.CM_Reg'));
                    let PWTblOtCW = Array.from(CWTblRow[k].querySelectorAll('.CM_OT'));
                    let PWTblDblCW = Array.from(CWTblRow[k].querySelectorAll('.CM_DBL'));
                    for (let m=0; m<PWTblRegCW.length; m++){
                        if(PWTblRegCW[m].value) PWRegTotCW += parseFloat(PWTblRegCW[m].value);
                    } for (let m=0; m<PWTblOtCW.length; m++){
                        if(PWTblOtCW[m].value) PWOTTotCW += parseFloat(PWTblOtCW[m].value);
                    } for (let m=0; m<PWTblDblCW.length; m++){
                        if(PWTblDblCW[m].value) PWDBLTotCW += parseFloat(PWTblDblCW[m].value);
                    }
                } 
                if(!chkdValueCW)
                {
                    let TblRegCW = Array.from(CWTblRow[k].querySelectorAll('.CM_Reg'));
                    let TblOtCW = Array.from(CWTblRow[k].querySelectorAll('.CM_OT'));
                    let TblDblCW = Array.from(CWTblRow[k].querySelectorAll('.CM_DBL'));
                    for (let m=0; m<TblRegCW.length; m++){
                        if(TblRegCW[m].value) NPWRegTotCW += parseFloat(TblRegCW[m].value);
                    } for (let m=0; m<TblOtCW.length; m++){
                        if(TblOtCW[m].value) NPWOTTotCW += parseFloat(TblOtCW[m].value);
                    } for (let m=0; m<TblDblCW.length; m++){
                        if(TblDblCW[m].value) NPWDBLTotCW += parseFloat(TblDblCW[m].value);
                    }
                }
            }
        }
        this.PWRegCW = PWRegTotCW.toFixed(2); this.PWOTCW = PWOTTotCW.toFixed(2); this.PWDBLCW = PWDBLTotCW.toFixed(2);
        this.NPWRegCW = NPWRegTotCW.toFixed(2); this.NPWOTCW = NPWOTTotCW.toFixed(2); this.NPWDBLCW = NPWDBLTotCW.toFixed(2);
    }

    //Render Labour code Select value
    get LaborCode(){
        return [
            { label: 'None', value: 'None' },
            { label: 'BCD', value: 'BCD' },
            { label: 'SUP', value: 'SUP' },
            { label: 'TEC', value: 'TEC' },
            { label: 'PM', value: 'PM' },
            { label: 'PD', value: 'PD' },
            { label: 'GL', value: 'GL' },
            { label: 'GLE', value: 'GLE' },
            { label: 'ADM', value: 'ADM' },
            { label: 'SPT', value: 'SPT' },
            { label: 'DRY', value: 'DRY' },
            { label: 'PNT', value: 'PNT' },
            { label: 'INS', value: 'INS' },
            { label: 'WLP', value: 'WLP' },
            { label: 'FNC', value: 'FNC' },
        ];
    }

    //Render Sift Select value
    get ShiftOption(){
        return [
            { label: 'Day', value: 'Day' },
            { label: 'Night', value: 'Night' },
        ];
    }
 
    @wire(currentTimesheetDetails, { dailyTimesheetIdtosearch: '$dailyTimesheetIdtosearch'}) 
    wiredcurrentTimesheetDetails({ error, data }) {
    //var timesheetobject = {};  
   // console.log(this.dailyTimesheetIdtosearch);    
   // console.log('dailyTimesheetIdtosearch - 1');  
  //  console.log(data);   
        this.GenerateDailyTimesheetJson();
        if (data) {
            this.dailyTimesheetDetailList = data; 
          //  console.log('Current timesheet');
          //  console.log(this.dailyTimesheetDetailList);
            for(this.i=0;this.i<this.dailyTimesheetDetailList.length;this.i++){  
          //      console.log('Current timesheettttt');
                this.dailyTimesheetJobStartDate = this.dailyTimesheetDetailList[this.i].StartDate__c;
          //      console.log('Line : 802 Start date from Timesheet ---> '+this.dailyTimesheetJobStartDate);
                this.dailyTimesheetJobEndDate = this.dailyTimesheetDetailList[this.i].EndDate__c;
                this.dailyTimesheetLocation = this.dailyTimesheetDetailList[this.i].Location__c;
                this.dailyTimesheetShift = this.dailyTimesheetDetailList[this.i].Shift__c;
                console.log('Line : 992 dailyTimesheetLocation ----> '+this.dailyTimesheetLocation);
                console.log('Line : 993 dailyTimesheetShift ----> '+this.dailyTimesheetShift);
                this.comments = this.dailyTimesheetDetailList[this.i].comments__c;
                
          //      console.log('Line 986 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
                this.dailyTimesheetFinalCheckbox = this.dailyTimesheetDetailList[this.i].Final__c;
          //      console.log('Line 990 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
           //     console.log('test 1');
                this.StartdateOnLoad();
                this.DatefilledOnload(); 
                let dailyTimesheetRecordJson = this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c;
              //  console.log('line:793 json Value --> '+this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c);
              //  console.log('line:794 json Value --> '+this.dailyTimesheetRecordJson);
                if(dailyTimesheetRecordJson === 'noData')
                {
                    console.log('Line:807 Append Rows');
                   // this.OverrideEmptyRows();
                    this.AppendEmptyRows();
                    this.Sup_MonTot = 0.0;
                    this.Sup_TueTot = 0.0;
                    this.Sup_WedTot = 0.0;
                    this.Sup_ThuTot = 0.0;
                    this.Sup_FriTot = 0.0; 
                    this.Sup_SatTot = 0.0; 
                    this.Sup_SunTot = 0.0;  

                    this.CM_MonTot = 0.0;  
                    this.CM_TueTot = 0.0;  
                    this.CM_WedTot = 0.0;  
                    this.CM_ThuTot = 0.0; 
                    this.CM_FriTot = 0.0;  
                    this.CM_SatTot = 0.0;  
                    this.CM_SunTot = 0.0;

                    this.PWReg = 0.0;  
                    this.PWOT = 0.0;
                    this.PWDBL = 0.0;  
                    this.NPWReg = 0.0;  
                    this.NPWOT = 0.0;  
                    this.NPWDBL = 0.0;  
                    this.PWRegCW = 0.0;
                    this.PWOTCW = 0.0;  
                    this.PWDBLCW = 0.0;  
                    this.NPWRegCW = 0.0;  
                    this.NPWOTCW = 0.0;  
                    this.NPWDBLCW = 0.0;
                    this.dailyTimesheetFinalCheckbox = 'false';
                    this.CalulateTotals();
                }
                else if(dailyTimesheetRecordJson.length > 1)
                {
                    this.dailyTimesheetrecord = JSON.parse(this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c);
                    this.ProjectManagers= this.dailyTimesheetrecord.ProjectManagers;
                    this.Supervisors = this.dailyTimesheetrecord.Supervisors;
                    this.CrewMembers = this.dailyTimesheetrecord.CrewMembers;

                    this.Sup_MonTot = this.dailyTimesheetrecord.TotSupMon;
                    this.Sup_TueTot = this.dailyTimesheetrecord.TotSupTue;
                    this.Sup_WedTot = this.dailyTimesheetrecord.TotSupWed;
                    this.Sup_ThuTot = this.dailyTimesheetrecord.TotSupThu;
                    this.Sup_FriTot = this.dailyTimesheetrecord.TotSupFri; 
                    this.Sup_SatTot = this.dailyTimesheetrecord.TotSupSat; 
                    this.Sup_SunTot = this.dailyTimesheetrecord.TotSupSun;  

                    this.CM_MonTot = this.dailyTimesheetrecord.TotCwMon;  
                    this.CM_TueTot = this.dailyTimesheetrecord.TotCwTue;  
                    this.CM_WedTot = this.dailyTimesheetrecord.TotCWwed;  
                    this.CM_ThuTot = this.dailyTimesheetrecord.TotCwThu; 
                    this.CM_FriTot = this.dailyTimesheetrecord.TotCwFri;  
                    this.CM_SatTot = this.dailyTimesheetrecord.TotCwSat;  
                    this.CM_SunTot = this.dailyTimesheetrecord.TotCwSun;  

                    this.PWReg = this.dailyTimesheetrecord.TotSupPWReg;  
                    this.PWOT = this.dailyTimesheetrecord.TotSupPWOT;
                    this.PWDBL = this.dailyTimesheetrecord.TotSupPWDBL;  
                    this.NPWReg = this.dailyTimesheetrecord.TotSupNPWReg;  
                    this.NPWOT = this.dailyTimesheetrecord.TotSupNPWOT;  
                    this.NPWDBL = this.dailyTimesheetrecord.TotSupNPWDBL;  
                    this.PWRegCW = this.dailyTimesheetrecord.TotCWPWReg;
                    this.PWOTCW = this.dailyTimesheetrecord.TotCWPWOT;  
                    this.PWDBLCW = this.dailyTimesheetrecord.TotCWPWDBL;  
                    this.NPWRegCW = this.dailyTimesheetrecord.TotCWNPWReg;  
                    this.NPWOTCW = this.dailyTimesheetrecord.TotCWNPWOT;  
                    this.NPWDBLCW = this.dailyTimesheetrecord.TotCWNPWDBL; 
                    this.CalulateTotals(); 
                    this.RestrictUIInput();
                    this.DisableAllControls();
                    
                    
                }
                else
                {
                    console.log('line:836 append empty rows');
                    this.AppendEmptyRows();
                //    this.StartdateOnLoad();
                //     this.DatefilledOnload(); 
                this.CalulateTotals();
                }
             }     
           //  console.log('Line 1082 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);   
        } else if (error) {
            console.log('line:844 Error --->'+error);
            this.error = error;          
        }    
        else
        {
            console.log('line:848 append empty rows');
            this.AppendEmptyRows();
            this.StartdateOnLoad();
            this.DatefilledOnload(); 
        }
    }

    @wire(currentJobDetails,{jobIdtosearch: '$jobIdtosearch'}) 
    wiredcurrentJobDetails({ error, data }) {
        if (data) {
            this.jobDetailsfromDailyTimesheetId = data; 
           // console.log('job detals');
          //  console.log(data);
            for(this.i=0;this.i<this.jobDetailsfromDailyTimesheetId.length;this.i++){  
                this.displayJobname = this.jobDetailsfromDailyTimesheetId[this.i].Job_Name__c;
                // this.comments = this.jobDetailsfromDailyTimesheetId[this.i].comments__c;
                this.displayJobnumber = this.jobDetailsfromDailyTimesheetId[this.i].Job_Number__c;
                //this.displayProjectDirector = this.jobDetailsfromDailyTimesheetId[this.i].Project_Manager__r.Name;
                this.displayProjectSiteAddress = this.jobDetailsfromDailyTimesheetId[this.i].Project_Site_Address_Concat__c;
                this.displayJobStartDate = this.jobDetailsfromDailyTimesheetId[this.i].Job_Start_Date__c;
                this.displayJobClosetDate = this.jobDetailsfromDailyTimesheetId[this.i].CloseDate__c;
                this.dailyTimesheetFinalCheckbox = false;
             }
            // console.log('line:871 append empty rows');
             this.AppendEmptyRows();
           //  console.log(this.Final__c);
             
        } else if (error) {
            console.log('line:876 error'+error);
            this.error = error;
            
        }
        
    }
    @wire(currentUserProfileName,{user : 'user'})
    wiredcurrentUserProfileName({error,data })
    {
        
        if(data)
        {
           
          //  console.log(data);
            this.userProfile = data;
            if(this.userProfile === 'System Administrator')
            {
            this.systemAdministrator=true;
        }
            console.log('systemAdministrator --> '+this.systemAdministrator);
            console.log('profile = '+this.userProfile);
        }
        else if(error)
        {
            console.log('error');
        }
    }
    @wire(OnchangeTimesheetDetails,{jobIdtosearch : '$jobIdtosearch',StartDate : '$Date_startDate'})
    wiredOnchangeTimesheetDetails({error,data })
    {
        if(data){

            this.dailyTimesheetDetailList = data; 
         //   console.log('Current timesheet');
         //   console.log(this.dailyTimesheetDetailList);
            
            for(this.i=0;this.i<this.dailyTimesheetDetailList.length;this.i++){  
                this.dailyTimesheetIdtosearch = this.dailyTimesheetDetailList[this.i].Id;
                this.dailyTimesheetJobStartDate = this.dailyTimesheetDetailList[this.i].StartDate__c;
                this.dailyTimesheetJobEndDate = this.dailyTimesheetDetailList[this.i].EndDate__c;
                this.dailyTimesheetLocation = this.dailyTimesheetDetailList[this.i].Location__c;
                this.dailyTimesheetShift = this.dailyTimesheetDetailList[this.i].Shift__c;
                this.dailyTimesheetFinalCheckbox = this.dailyTimesheetDetailList[this.i].Final__c;

            //    console.log('Line 1160 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
                console.log('Line : 1170 dailyTimesheetLocation --> '+this.dailyTimesheetLocation);
               console.log('Line : 1171 dailyTimesheetShift --> '+this.dailyTimesheetShift);
               
                this.comments = this.dailyTimesheetDetailList[this.i].comments__c;
                
                //alert('Final Checkbox:'+this.dailyTimesheetFinalCheckbox);
             //   console.log('Line 1165 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
              //  this.StartdateOnLoad();
                this.DatefilledOnload(); 
                let dailyTimesheetRecordJson = this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c;
             //   console.log('test 2');
             //   console.log('line:902 json Value --> '+this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c);
            //    console.log('line:903 json Value --> '+this.dailyTimesheetRecordJson);
                if(dailyTimesheetRecordJson === 'noData')
                {
                    console.log('Line:1070 OverrideEmptyRows');
                  //  this.OverrideEmptyRows();
                  this.AppendEmptyRows();

                  

                    this.Sup_MonTot = 0.0;
                    this.Sup_TueTot = 0.0;
                    this.Sup_WedTot = 0.0;
                    this.Sup_ThuTot = 0.0;
                    this.Sup_FriTot = 0.0; 
                    this.Sup_SatTot = 0.0; 
                    this.Sup_SunTot = 0.0;  

                    this.CM_MonTot = 0.0;  
                    this.CM_TueTot = 0.0;  
                    this.CM_WedTot = 0.0;  
                    this.CM_ThuTot = 0.0; 
                    this.CM_FriTot = 0.0;  
                    this.CM_SatTot = 0.0;  
                    this.CM_SunTot = 0.0;

                    this.PWReg = 0.0;  
                    this.PWOT = 0.0;
                    this.PWDBL = 0.0;  
                    this.NPWReg = 0.0;  
                    this.NPWOT = 0.0;  
                    this.NPWDBL = 0.0;  
                    this.PWRegCW = 0.0;
                    this.PWOTCW = 0.0;  
                    this.PWDBLCW = 0.0;  
                    this.NPWRegCW = 0.0;  
                    this.NPWOTCW = 0.0;  
                    this.NPWDBLCW = 0.0;
                    
                //    console.log('Line 1206 dailyTimesheetFinalCheckbox ---> '+this.dailyTimesheetFinalCheckbox);
                    this.RestrictUIInput(); 
                    
                  //  this.CalulateTotals();
                }
                else if(dailyTimesheetRecordJson.length > 1)
                {
                    this.dailyTimesheetrecord = JSON.parse(this.dailyTimesheetDetailList[this.i].DailyTimsheetRecord__c);
                    this.ProjectManagers= this.dailyTimesheetrecord.ProjectManagers;
                    
                    this.Supervisors = this.dailyTimesheetrecord.Supervisors;
                    this.CrewMembers = this.dailyTimesheetrecord.CrewMembers;
                    this.Sup_MonTot = this.dailyTimesheetrecord.TotSupMon;
                    this.Sup_TueTot = this.dailyTimesheetrecord.TotSupTue;
                    this.Sup_WedTot = this.dailyTimesheetrecord.TotSupWed;
                    this.Sup_ThuTot = this.dailyTimesheetrecord.TotSupThu;
                    this.Sup_FriTot = this.dailyTimesheetrecord.TotSupFri; 
                    this.Sup_SatTot = this.dailyTimesheetrecord.TotSupSat; 
                    this.Sup_SunTot = this.dailyTimesheetrecord.TotSupSun;  

                    this.CM_MonTot = this.dailyTimesheetrecord.TotCwMon;  
                    this.CM_TueTot = this.dailyTimesheetrecord.TotCwTue;  
                    this.CM_WedTot = this.dailyTimesheetrecord.TotCWwed;  
                    this.CM_ThuTot = this.dailyTimesheetrecord.TotCwThu; 
                    this.CM_FriTot = this.dailyTimesheetrecord.TotCwFri;  
                    this.CM_SatTot = this.dailyTimesheetrecord.TotCwSat;  
                    this.CM_SunTot = this.dailyTimesheetrecord.TotCwSun;  

                    this.PWReg = this.dailyTimesheetrecord.TotSupPWReg;  
                    this.PWOT = this.dailyTimesheetrecord.TotSupPWOT;
                    this.PWDBL = this.dailyTimesheetrecord.TotSupPWDBL;  
                    this.NPWReg = this.dailyTimesheetrecord.TotSupNPWReg;  
                    this.NPWOT = this.dailyTimesheetrecord.TotSupNPWOT;  
                    this.NPWDBL = this.dailyTimesheetrecord.TotSupNPWDBL;  
                    this.PWRegCW = this.dailyTimesheetrecord.TotCWPWReg;
                    this.PWOTCW = this.dailyTimesheetrecord.TotCWPWOT;  
                    this.PWDBLCW = this.dailyTimesheetrecord.TotCWPWDBL;  
                    this.NPWRegCW = this.dailyTimesheetrecord.TotCWNPWReg;  
                    this.NPWOTCW = this.dailyTimesheetrecord.TotCWNPWOT;  
                    this.NPWDBLCW = this.dailyTimesheetrecord.TotCWNPWDBL; 
                    this.RestrictUIInput(); 
                }
                else
                {
                    console.log('line:948 append empty rows');
                    this.AppendEmptyRows();
                   // this.StartdateOnLoad();
                    this.DatefilledOnload(); 
                }
             }
        }
        else if (error) {
            this.error = error;
            console.log('line:957 Error Json ---> '+error);
            
        }
    }

    
    AppendEmptyRows()
    {
      //  console.log('dailyTimesheetIdtosearch 2'); 
        //timesheetobject = JSON.parse(this.dailyTimesheetJson);
        this.dailyTimesheetrecord = JSON.stringify(this.getEmptyRow());
        this.ProjectManagers= this.getEmptyRow();
        this.Supervisors = this.getEmptyRow();
        this.CrewMembers = this.getEmptyRow();
      //  console.log('dailyTimesheetIdtosearch 3'); 
    }
    
    SavePDFwithPreview(timesheetIDToattach)
    {
      //  console.log(timesheetIDToattach);
        attachonly({timesheetID: timesheetIDToattach})
        .then(result => {
            console.log('save'+result);
        })
        .catch(error => {
            console.log('error');
            console.log(error);
        });

    }

    SaveUpdatedDailyTimesheet(e) {
        var shift = this.template.querySelector('.shift').value;
        var commentbox = this.template.querySelector('.Comments').value;
        var location = this.template.querySelector('.loc').value;
        var finalchkbox = this.template.querySelector('.finalcheckbox').checked;
        let UpdatedJSON = this.GenerateDailyTimesheetJson();
        let UpdatedTimesheetID = "";
        let UpdatedJobID = "";
        let Updatedjobnumber="";
        let Updatedstartdate = "";
        let Updatedendtdate = "";
        let updatedfinalcheckbox="";
        let updatedlocation="";
        let updatedshift="";
        
        if(this.dailyTimesheetIdtosearch !== null){
            UpdatedTimesheetID = this.dailyTimesheetIdtosearch;

        }
            

       if(this.jobIdtosearch !== null){
            UpdatedJobID = this.jobIdtosearch;
            Updatedjobnumber=this.displayJobnumber;
            Updatedstartdate=this.Date_startDate;
            updatedlocation=location;
            updatedfinalcheckbox=finalchkbox;
            updatedshift=shift;
            Updatedendtdate=this.Date_endDate;
       }

        saveDailyTimesheet({
            timesheetID : UpdatedTimesheetID,
            dailyTimesheetJson : UpdatedJSON,
            JobID: UpdatedJobID,
            StartDate: Updatedstartdate,
            EndDate: Updatedendtdate,
            finalcheckbox : updatedfinalcheckbox,
            location : updatedlocation,
            shift : updatedshift,
            JobNumber: Updatedjobnumber,
            comments: commentbox
            })
            .then(result => {
              //  console.log('success');
              //  console.log(result);
                this.test = result;
                this.SavePDFwithPreview(result);
                this.SaveComments = 'Timesheet Saved Successfully..';
            })
            .catch(error => {
              //  console.log('error');
                console.log(error);
              //  console.log(e);
                this.SaveComments = 'Error occured while Saving Timesheet...';
            });
            this.openmodel = true;
    }

    Cancel(){
        window.location= window.location.origin +'/lightning/n/DailyTimesheetListView?ati__jobid='+this.jobIdtosearch;
     //   console.log(window.location.origin +'/lightning/n/DailyTimesheetListView?ati__jobid='+this.jobIdtosearch);
    }

    saveAsPdf(){
        if(this.dailyTimesheetIdtosearch!=null){
            window.location= window.location.origin +'/apex/DailyTimesheetPDFpage?id='+this.dailyTimesheetIdtosearch ;
          //  console.log(window.location.origin +'/apex/DailyTimesheetPDFpage?id='+this.dailyTimesheetIdtosearch);
        }else{
            alert('PDF can be generated only after saving records.');
        }
    }

    GenerateDailyTimesheetJson()
    {
        var dailyTimesheetObject = {
            ProjectManagers : this.getProjectManagerObjects(),
            Supervisors : this.getSupervisorObjects(),
            CrewMembers : this.getCrewMembersObjects(),
            TotSupMon:  this.Sup_MonTot,
            TotSupTue:  this.Sup_TueTot,
            TotSupWed:  this.Sup_WedTot,
            TotSupThu:  this.Sup_ThuTot,
            TotSupFri:  this.Sup_FriTot,
            TotSupSat:  this.Sup_SatTot,
            TotSupSun:  this.Sup_SunTot,

            
            TotCwMon:  this.CM_MonTot,
            TotCwTue:  this.CM_TueTot,
            TotCWwed:  this.CM_WedTot,
            TotCwThu:  this.CM_ThuTot,
            TotCwFri:  this.CM_FriTot,
            TotCwSat:  this.CM_SatTot,
            TotCwSun:  this.CM_SunTot,

            TotSupPWReg:  this.PWReg,
            TotSupPWOT:  this.PWOT,
            TotSupPWDBL:  this.PWDBL,
            TotSupNPWReg:  this.NPWReg,
            TotSupNPWOT:  this.NPWOT,
            TotSupNPWDBL:  this.NPWDBL,
            TotCWPWReg:  this.PWRegCW,
            TotCWPWOT:  this.PWOTCW,
            TotCWPWDBL:  this.PWDBLCW,
            TotCWNPWReg:  this.NPWRegCW,
            TotCWNPWOT:  this.NPWOTCW,
            TotCWNPWDBL:  this.NPWDBLCW
        };
        console.log(dailyTimesheetObject);
        console.log(this.CM_MonTot);
        return JSON.stringify(dailyTimesheetObject);
    }

    getProjectManagerObjects() {
        var projectManagers = [];

        //Get Value from HTML 
        let TblRow =  Array.from(this.template.querySelectorAll('table.PMTbl tbody tr'));
        let RowCount = TblRow.length;
        for(let k=0; k<RowCount; k++){
            let Name = TblRow[k].querySelector('.PMName').value;
            // if(Name)
            // {
            let TblReg = TblRow[k].querySelectorAll('.PM_Reg');
            let TblOt = TblRow[k].querySelectorAll('.PM_OT');
            let TblDbl = TblRow[k].querySelectorAll('.PM_DBL');
            
            

            let LaborCode = TblRow[k].querySelector('.PMLaborCode').value;
            let MondayDBLHours = TblDbl[0].value; let MondayOTHours = TblOt[0].value; let MondayRegHours = TblReg[0].value;
            let TuesdayDBLHours = TblDbl[1].value; let TuesdayOTHours = TblOt[1].value; let TuesdayRegHours = TblReg[1].value;
            let WednesdayDBLHours = TblDbl[2].value; let WednesdayOTHours = TblOt[2].value; let WednesdayRegHours = TblReg[2].value;
            let ThursdayDBLHours = TblDbl[3].value; let ThursdayOTHours = TblOt[3].value; let ThursdayRegHours = TblReg[3].value;
            let FridayDBLHours = TblDbl[4].value; let FridayOTHours = TblOt[4].value; let FridayRegHours = TblReg[4].value;
            let SaturdayDBLHours = TblDbl[5].value; let SaturdayOTHours = TblOt[5].value; let SaturdayRegHours = TblReg[5].value;
            let SundayDBLHours = TblDbl[6].value; let SundayOTHours = TblOt[6].value; let SundayRegHours = TblReg[6].value;
            
            

            projectManagers.push({
                Name: Name,PW: false,LaborCode: LaborCode,MondayDBLHours: MondayDBLHours, MondayOTHours: MondayOTHours, MondayRegHours: MondayRegHours,
                TuesdayDBLHours: TuesdayDBLHours,TuesdayOTHours: TuesdayOTHours, TuesdayRegHours: TuesdayRegHours,
                WednesdayDBLHours: WednesdayDBLHours,WednesdayOTHours: WednesdayOTHours, WednesdayRegHours: WednesdayRegHours,
                ThursdayDBLHours:ThursdayDBLHours,ThursdayOTHours:ThursdayOTHours , ThursdayRegHours:ThursdayRegHours,
                FridayDBLHours:FridayDBLHours ,FridayOTHours:FridayOTHours , FridayRegHours:FridayRegHours,
                SaturdayDBLHours:SaturdayDBLHours ,SaturdayOTHours: SaturdayOTHours , SaturdayRegHours:SaturdayRegHours ,
                SundayDBLHours:SundayDBLHours ,SundayOTHours:SundayOTHours , SundayRegHours:SundayRegHours, 
                
            });
        // }

        }
       // console.log(projectManagers);
        return projectManagers;
    }

    getSupervisorObjects() {
        var Supervisors = [];
        let SupTblRow =  Array.from(this.template.querySelectorAll('table.SupTbl tbody tr'));
        let SupRowCount = SupTblRow.length;
        for(let supindex=0; supindex<SupRowCount; supindex++){
            let SupName = SupTblRow[supindex].querySelector('.SupName').value;
      //  if(SupName){
            let SupTblReg = SupTblRow[supindex].querySelectorAll('.Sup_Reg');
            let SupTblOt = SupTblRow[supindex].querySelectorAll('.Sup_OT');
            let SupTblDbl = SupTblRow[supindex].querySelectorAll('.Sup_DBL');
            let SupLabourCode = SupTblRow[supindex].querySelector('.SupLabourCode').value;
            let SupPw = SupTblRow[supindex].querySelector('.SupPw').checked;
            let SupMondayDBLHours = SupTblDbl[0].value; let SupMondayOTHours = SupTblOt[0].value; let SupMondayRegHours = SupTblReg[0].value;
            let SupTuesdayDBLHours = SupTblDbl[1].value; let SupTuesdayOTHours = SupTblOt[1].value; let SupTuesdayRegHours = SupTblReg[1].value;
            let SupWednesdayDBLHours = SupTblDbl[2].value; let SupWednesdayOTHours = SupTblOt[2].value; let SupWednesdayRegHours = SupTblReg[2].value;
            let SupThursdayDBLHours = SupTblDbl[3].value; let SupThursdayOTHours = SupTblOt[3].value; let SupThursdayRegHours = SupTblReg[3].value;
            let SupFridayDBLHours = SupTblDbl[4].value; let SupFridayOTHours = SupTblOt[4].value; let SupFridayRegHours = SupTblReg[4].value;
            let SupSaturdayDBLHours = SupTblDbl[5].value; let SupSaturdayOTHours = SupTblOt[5].value; let SupSaturdayRegHours = SupTblReg[5].value;
            let SupSundayDBLHours = SupTblDbl[6].value; let SupSundayOTHours = SupTblOt[6].value; let SupSundayRegHours = SupTblReg[6].value;

            Supervisors.push({
                Name: SupName,PW: SupPw,LaborCode: SupLabourCode,MondayDBLHours: SupMondayDBLHours, MondayOTHours: SupMondayOTHours, MondayRegHours: SupMondayRegHours,
                TuesdayDBLHours: SupTuesdayDBLHours,TuesdayOTHours: SupTuesdayOTHours, TuesdayRegHours: SupTuesdayRegHours,
                WednesdayDBLHours: SupWednesdayDBLHours,WednesdayOTHours: SupWednesdayOTHours, WednesdayRegHours: SupWednesdayRegHours,
                ThursdayDBLHours:SupThursdayDBLHours,ThursdayOTHours:SupThursdayOTHours , ThursdayRegHours:SupThursdayRegHours,
                FridayDBLHours:SupFridayDBLHours ,FridayOTHours:SupFridayOTHours , FridayRegHours:SupFridayRegHours,
                SaturdayDBLHours:SupSaturdayDBLHours ,SaturdayOTHours: SupSaturdayOTHours , SaturdayRegHours:SupSaturdayRegHours ,
                SundayDBLHours:SupSundayDBLHours ,SundayOTHours:SupSundayOTHours , SundayRegHours:SupSundayRegHours
            });
         //   console.log('Supervisors'+Supervisors);
      //  }
        }
        return Supervisors;
    }


    getCrewMembersObjects() {
        var CrewMembers = [];

        let CWTblRow =  Array.from(this.template.querySelectorAll('table.CWTbl tbody tr'));
        let CWRowCount = CWTblRow.length;
        for(let CwIndex=0; CwIndex<CWRowCount; CwIndex++){
            let CwName = CWTblRow[CwIndex].querySelector('.CwName').value;
           // if(CwName){
            let CwTblReg = CWTblRow[CwIndex].querySelectorAll('.CM_Reg');
            let CwTblOt = CWTblRow[CwIndex].querySelectorAll('.CM_OT');
            let CwTblDbl = CWTblRow[CwIndex].querySelectorAll('.CM_DBL');


            let CwLabourCode = CWTblRow[CwIndex].querySelector('.CwLabourCode').value;
            let CwPw = CWTblRow[CwIndex].querySelector('.CwPw').checked;
            let CwMondayDBLHours = CwTblDbl[0].value; let CwMondayOTHours = CwTblOt[0].value; let CwMondayRegHours = CwTblReg[0].value;
            let CwTuesdayDBLHours = CwTblDbl[1].value; let CwTuesdayOTHours = CwTblOt[1].value; let CwTuesdayRegHours = CwTblReg[1].value;
            let CwWednesdayDBLHours = CwTblDbl[2].value; let CwWednesdayOTHours = CwTblOt[2].value; let CwWednesdayRegHours = CwTblReg[2].value;
            let CwThursdayDBLHours = CwTblDbl[3].value; let CwThursdayOTHours = CwTblOt[3].value; let CwThursdayRegHours = CwTblReg[3].value;
            let CwFridayDBLHours = CwTblDbl[4].value; let CwFridayOTHours = CwTblOt[4].value; let CwFridayRegHours = CwTblReg[4].value;
            let CwSaturdayDBLHours = CwTblDbl[5].value; let CwSaturdayOTHours = CwTblOt[5].value; let CwSaturdayRegHours = CwTblReg[5].value;
            let CwSundayDBLHours = CwTblDbl[6].value; let CwSundayOTHours = CwTblOt[6].value; let CwSundayRegHours = CwTblReg[6].value;

            CrewMembers.push({
                Name: CwName,PW: CwPw,LaborCode: CwLabourCode,MondayDBLHours: CwMondayDBLHours, MondayOTHours: CwMondayOTHours, MondayRegHours: CwMondayRegHours,
                TuesdayDBLHours: CwTuesdayDBLHours,TuesdayOTHours: CwTuesdayOTHours, TuesdayRegHours: CwTuesdayRegHours,
                WednesdayDBLHours: CwWednesdayDBLHours,WednesdayOTHours: CwWednesdayOTHours, WednesdayRegHours: CwWednesdayRegHours,
                ThursdayDBLHours:CwThursdayDBLHours,ThursdayOTHours:CwThursdayOTHours , ThursdayRegHours:CwThursdayRegHours,
                FridayDBLHours:CwFridayDBLHours ,FridayOTHours:CwFridayOTHours , FridayRegHours:CwFridayRegHours,
                SaturdayDBLHours:CwSaturdayDBLHours ,SaturdayOTHours: CwSaturdayOTHours , SaturdayRegHours:CwSaturdayRegHours ,
                SundayDBLHours:CwSundayDBLHours ,SundayOTHours:CwSundayOTHours , SundayRegHours:CwSundayRegHours
            });
          //  console.log('CrewMembers'+CrewMembers);
      //  }
        }
        return CrewMembers;
    }



    getEmptyRow() {
        var EmptyRow = [];
        EmptyRow.push({
            Name: "",PW: false,LaborCode: "None",MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',
            TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
            WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
            ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
            FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
            SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
            SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
        });
        return EmptyRow;
    }

    CopyProjectManagersRow()
    {
        this.ProjectManagers = this.getAllProjectManagerObjects();
        if(this.ProjectManagers.length<4){
            if(this.ProjectManagers)
            {
                if(this.ProjectManagers.length >= 1){
                    this.ProjectManagers.push(this.ProjectManagers[this.ProjectManagers.length-1]);
                }
            }
            this.Supervisors = this.getAllSupervisorObjects();
            this.CrewMembers = this.getAllCrewMembersObjects();
        } else{
            alert('Only Max of 4 allowed.');
        }
    }

    CopySuperVisorRow()
    {
        this.Supervisors = this.getAllSupervisorObjects();
        //alert('CopySup ro:'+this.Supervisors.length);
        if(this.Supervisors.length<10){
            if(this.Supervisors)
            {
                if(this.Supervisors.length >=1){
                    this.Supervisors.push(this.Supervisors[this.Supervisors.length-1]);
                }
            }   
            let TempSupData = this.Supervisors;
            this.ProjectManagers = this.getAllProjectManagerObjects();
            this.CrewMembers = this.getAllCrewMembersObjects();
            this.GetOvrallTot(TempSupData, 'Sup');
        } else{
            alert('Only Max of 10 allowed.');
        }
    }

    CopyCrewMembersRow()
    {
        this.CrewMembers = this.getAllCrewMembersObjects();
        if(this.CrewMembers.length<25){
            if(this.CrewMembers)
            { console.log('test CW 2');
                if(this.CrewMembers.length >= 1){
                    this.CrewMembers.push(this.CrewMembers[this.CrewMembers.length-1]);
                }
            }  
            let TempCMData = this.CrewMembers;
            this.Supervisors = this.getAllSupervisorObjects();
            this.ProjectManagers = this.getAllProjectManagerObjects();
            this.GetOvrallTot(TempCMData, 'CM');
        } else{
            alert('Only Max of 25 allowed.');
        }
    }

    AddProjectManagersRow()
    { 
            //this.ProjectManagers = this.getAllProjectManagerObjects();
            if(this.ProjectManagers.length<4){
                this.ProjectManagers.push({
                    Name: "",PW: false,LaborCode: "None",MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',
                    TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                    WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                    ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                    FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                    SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                    SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
                });

                this.Supervisors = this.getAllSupervisorObjects();
                this.CrewMembers = this.getAllCrewMembersObjects();
            } else{
                alert('Only Max of 4 allowed.');
            }
            
    }

    AddSuperVisorRow()
    {
        //this.Supervisors = this.getAllSupervisorObjects();
        if(this.Supervisors.length<10){
            this.Supervisors.push({
                Name: "",PW: false,LaborCode: "None",MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',
                TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
            });  
            this.ProjectManagers = this.getAllProjectManagerObjects();
            this.CrewMembers = this.getAllCrewMembersObjects();
        } else{
            alert('Only Max of 10 allowed.');
        }
    }

    AddCrewMembersRow()
    {
        //this.CrewMembers = this.getAllCrewMembersObjects();
        if(this.CrewMembers.length<25){
            this.CrewMembers.push({
                Name: "",PW: false,LaborCode: "None",MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',
                TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
            });  
            this.Supervisors = this.getAllSupervisorObjects();
            this.ProjectManagers = this.getAllProjectManagerObjects();
        } else{
            alert('Only Max of 25 allowed.');
        }
    }


   getAllCrewMembersObjects() {
        var CrewMembers = [];

        let CWTblRow =  Array.from(this.template.querySelectorAll('table.CWTbl tbody tr'));
        let CWRowCount = CWTblRow.length;
        for(let CwIndex=0; CwIndex<CWRowCount; CwIndex++){
            let CwName = CWTblRow[CwIndex].querySelector('.CwName').value;
            let CwTblReg = CWTblRow[CwIndex].querySelectorAll('.CM_Reg');
            let CwTblOt = CWTblRow[CwIndex].querySelectorAll('.CM_OT');
            let CwTblDbl = CWTblRow[CwIndex].querySelectorAll('.CM_DBL');


            let CwLabourCode = CWTblRow[CwIndex].querySelector('.CwLabourCode').value;
            let CwPw = CWTblRow[CwIndex].querySelector('.CwPw').checked;
            let CwMondayDBLHours = CwTblDbl[0].value; let CwMondayOTHours = CwTblOt[0].value; let CwMondayRegHours = CwTblReg[0].value;
            let CwTuesdayDBLHours = CwTblDbl[1].value; let CwTuesdayOTHours = CwTblOt[1].value; let CwTuesdayRegHours = CwTblReg[1].value;
            let CwWednesdayDBLHours = CwTblDbl[2].value; let CwWednesdayOTHours = CwTblOt[2].value; let CwWednesdayRegHours = CwTblReg[2].value;
            let CwThursdayDBLHours = CwTblDbl[3].value; let CwThursdayOTHours = CwTblOt[3].value; let CwThursdayRegHours = CwTblReg[3].value;
            let CwFridayDBLHours = CwTblDbl[4].value; let CwFridayOTHours = CwTblOt[4].value; let CwFridayRegHours = CwTblReg[4].value;
            let CwSaturdayDBLHours = CwTblDbl[5].value; let CwSaturdayOTHours = CwTblOt[5].value; let CwSaturdayRegHours = CwTblReg[5].value;
            let CwSundayDBLHours = CwTblDbl[6].value; let CwSundayOTHours = CwTblOt[6].value; let CwSundayRegHours = CwTblReg[6].value;

            CrewMembers.push({
                Name: CwName,PW: CwPw,LaborCode: CwLabourCode,MondayDBLHours: CwMondayDBLHours, MondayOTHours: CwMondayOTHours, MondayRegHours: CwMondayRegHours,
                TuesdayDBLHours: CwTuesdayDBLHours,TuesdayOTHours: CwTuesdayOTHours, TuesdayRegHours: CwTuesdayRegHours,
                WednesdayDBLHours: CwWednesdayDBLHours,WednesdayOTHours: CwWednesdayOTHours, WednesdayRegHours: CwWednesdayRegHours,
                ThursdayDBLHours:CwThursdayDBLHours,ThursdayOTHours:CwThursdayOTHours , ThursdayRegHours:CwThursdayRegHours,
                FridayDBLHours:CwFridayDBLHours ,FridayOTHours:CwFridayOTHours , FridayRegHours:CwFridayRegHours,
                SaturdayDBLHours:CwSaturdayDBLHours ,SaturdayOTHours: CwSaturdayOTHours , SaturdayRegHours:CwSaturdayRegHours ,
                SundayDBLHours:CwSundayDBLHours ,SundayOTHours:CwSundayOTHours , SundayRegHours:CwSundayRegHours
            });
           // console.log('CrewMembers'+CrewMembers);
        }
        return CrewMembers;
    }

    getAllSupervisorObjects() {
        var Supervisors = [];
        let SupTblRow =  Array.from(this.template.querySelectorAll('table.SupTbl tbody tr'));
        let SupRowCount = SupTblRow.length;
        for(let supindex=0; supindex<SupRowCount; supindex++){
            let SupName = SupTblRow[supindex].querySelector('.SupName').value;
            let SupTblReg = SupTblRow[supindex].querySelectorAll('.Sup_Reg');
            let SupTblOt = SupTblRow[supindex].querySelectorAll('.Sup_OT');
            let SupTblDbl = SupTblRow[supindex].querySelectorAll('.Sup_DBL');

            
            let SupLabourCode = SupTblRow[supindex].querySelector('.SupLabourCode').value;
            //let SupPw = SupTblRow[supindex].querySelector('.SupPw').checked;
            let SupMondayDBLHours = SupTblDbl[0].value; let SupMondayOTHours = SupTblOt[0].value; let SupMondayRegHours = SupTblReg[0].value;
            let SupTuesdayDBLHours = SupTblDbl[1].value; let SupTuesdayOTHours = SupTblOt[1].value; let SupTuesdayRegHours = SupTblReg[1].value;
            let SupWednesdayDBLHours = SupTblDbl[2].value; let SupWednesdayOTHours = SupTblOt[2].value; let SupWednesdayRegHours = SupTblReg[2].value;
            let SupThursdayDBLHours = SupTblDbl[3].value; let SupThursdayOTHours = SupTblOt[3].value; let SupThursdayRegHours = SupTblReg[3].value;
            let SupFridayDBLHours = SupTblDbl[4].value; let SupFridayOTHours = SupTblOt[4].value; let SupFridayRegHours = SupTblReg[4].value;
            let SupSaturdayDBLHours = SupTblDbl[5].value; let SupSaturdayOTHours = SupTblOt[5].value; let SupSaturdayRegHours = SupTblReg[5].value;
            let SupSundayDBLHours = SupTblDbl[6].value; let SupSundayOTHours = SupTblOt[6].value; let SupSundayRegHours = SupTblReg[6].value;

            Supervisors.push({
                Name: SupName,PW: false ,LaborCode: SupLabourCode,MondayDBLHours: SupMondayDBLHours, MondayOTHours: SupMondayOTHours, MondayRegHours: SupMondayRegHours,
                TuesdayDBLHours: SupTuesdayDBLHours,TuesdayOTHours: SupTuesdayOTHours, TuesdayRegHours: SupTuesdayRegHours,
                WednesdayDBLHours: SupWednesdayDBLHours,WednesdayOTHours: SupWednesdayOTHours, WednesdayRegHours: SupWednesdayRegHours,
                ThursdayDBLHours:SupThursdayDBLHours,ThursdayOTHours:SupThursdayOTHours , ThursdayRegHours:SupThursdayRegHours,
                FridayDBLHours:SupFridayDBLHours ,FridayOTHours:SupFridayOTHours , FridayRegHours:SupFridayRegHours,
                SaturdayDBLHours:SupSaturdayDBLHours ,SaturdayOTHours: SupSaturdayOTHours , SaturdayRegHours:SupSaturdayRegHours ,
                SundayDBLHours:SupSundayDBLHours ,SundayOTHours:SupSundayOTHours , SundayRegHours:SupSundayRegHours
            });
        }
        return Supervisors;
    }

    getAllProjectManagerObjects() {
        var projectManagers = [];

        //Get Value from HTML 
        let TblRow =  Array.from(this.template.querySelectorAll('table.PMTbl tbody tr'));
        let RowCount = TblRow.length;
        for(let k=0; k<RowCount; k++){
            let Name = TblRow[k].querySelector('.PMName').value;
            let TblReg = TblRow[k].querySelectorAll('.PM_Reg');
            let TblOt = TblRow[k].querySelectorAll('.PM_OT');
            let TblDbl = TblRow[k].querySelectorAll('.PM_DBL');
            
            

            let LaborCode = TblRow[k].querySelector('.PMLaborCode').value;
            //let CWPw = TblRow[k].querySelector('.CWPw').checked;
            let MondayDBLHours = TblDbl[0].value; let MondayOTHours = TblOt[0].value; let MondayRegHours = TblReg[0].value;
            let TuesdayDBLHours = TblDbl[1].value; let TuesdayOTHours = TblOt[1].value; let TuesdayRegHours = TblReg[1].value;
            let WednesdayDBLHours = TblDbl[2].value; let WednesdayOTHours = TblOt[2].value; let WednesdayRegHours = TblReg[2].value;
            let ThursdayDBLHours = TblDbl[3].value; let ThursdayOTHours = TblOt[3].value; let ThursdayRegHours = TblReg[3].value;
            let FridayDBLHours = TblDbl[4].value; let FridayOTHours = TblOt[4].value; let FridayRegHours = TblReg[4].value;
            let SaturdayDBLHours = TblDbl[5].value; let SaturdayOTHours = TblOt[5].value; let SaturdayRegHours = TblReg[5].value;
            let SundayDBLHours = TblDbl[6].value; let SundayOTHours = TblOt[6].value; let SundayRegHours = TblReg[6].value;
            
            projectManagers.push({
                Name: Name,PW: false,LaborCode: LaborCode,MondayDBLHours: MondayDBLHours, MondayOTHours: MondayOTHours, MondayRegHours: MondayRegHours,
                TuesdayDBLHours: TuesdayDBLHours,TuesdayOTHours: TuesdayOTHours, TuesdayRegHours: TuesdayRegHours,
                WednesdayDBLHours: WednesdayDBLHours,WednesdayOTHours: WednesdayOTHours, WednesdayRegHours: WednesdayRegHours,
                ThursdayDBLHours:ThursdayDBLHours,ThursdayOTHours:ThursdayOTHours , ThursdayRegHours:ThursdayRegHours,
                FridayDBLHours:FridayDBLHours ,FridayOTHours:FridayOTHours , FridayRegHours:FridayRegHours,
                SaturdayDBLHours:SaturdayDBLHours ,SaturdayOTHours: SaturdayOTHours , SaturdayRegHours:SaturdayRegHours ,
                SundayDBLHours:SundayDBLHours ,SundayOTHours:SundayOTHours , SundayRegHours:SundayRegHours
            });

        }
        return projectManagers;
    }

    CopySelectedDay() {

        if(this.CrewMembers.length<25){
        let cwCopyMonday = this.template.querySelector('.chkCwMon').checked;
        let cwCopyTuesday = this.template.querySelector('.chkCwTue').checked;
        let cwCopyWednesday = this.template.querySelector('.chkCwWed').checked;
        let cwCopyThursday = this.template.querySelector('.chkCwThu').checked;
        let cwCopyFriday = this.template.querySelector('.chkCwFri').checked;
        let cwCopySaturday = this.template.querySelector('.chkCwSat').checked;
        let cwCopySunday = this.template.querySelector('.chkCwSun').checked;

      //  console.log(cwCopyMonday+'-'+cwCopyTuesday+'-'+cwCopyWednesday+'-'+cwCopyThursday+'-'+cwCopyFriday+'-'+cwCopySaturday+'-'+cwCopySunday);

        this.CrewMembers = this.getAllCrewMembersObjects();
        if(cwCopyMonday === true || cwCopyTuesday === true || cwCopyWednesday === true || cwCopyThursday === true || cwCopyFriday === true || cwCopySaturday === true || cwCopySunday === true)
        {
         //   console.log('Crew Member Length ---> '+this.CrewMembers.length);
         //   console.log('Crew Member Length ---> '+this.CrewMembers.size);
            if(this.CrewMembers.length >= 1){
                this.CrewMembers.push({
                    Name: "",PW: false,LaborCode: "None",MondayDBLHours: '', MondayOTHours: '', MondayRegHours: '',
                    TuesdayDBLHours: '',TuesdayOTHours: '', TuesdayRegHours: '',
                    WednesdayDBLHours: '',WednesdayOTHours: '', WednesdayRegHours: '',
                    ThursdayDBLHours: '',ThursdayOTHours: '', ThursdayRegHours: '',
                    FridayDBLHours: '',FridayOTHours: '', FridayRegHours: '',
                    SaturdayDBLHours: '',SaturdayOTHours: '', SaturdayRegHours: '',
                    SundayDBLHours: '',SundayOTHours: '', SundayRegHours: ''
                });

                if(cwCopyMonday === true)
                {
                    this.CrewMembers[this.CrewMembers.length-1].MondayDBLHours=this.CrewMembers[this.CrewMembers.length-2].MondayDBLHours;
                    this.CrewMembers[this.CrewMembers.length-1].MondayOTHours=this.CrewMembers[this.CrewMembers.length-2].MondayOTHours;
                    this.CrewMembers[this.CrewMembers.length-1].MondayRegHours=this.CrewMembers[this.CrewMembers.length-2].MondayRegHours;
                }
                if(cwCopyTuesday === true)
                {
                    this.CrewMembers[this.CrewMembers.length-1].TuesdayDBLHours=this.CrewMembers[this.CrewMembers.length-2].TuesdayDBLHours;
                    this.CrewMembers[this.CrewMembers.length-1].TuesdayOTHours=this.CrewMembers[this.CrewMembers.length-2].TuesdayOTHours;
                    this.CrewMembers[this.CrewMembers.length-1].TuesdayRegHours=this.CrewMembers[this.CrewMembers.length-2].TuesdayRegHours;
                }
                if(cwCopyWednesday === true)
                {
                    this.CrewMembers[this.CrewMembers.length-1].WednesdayDBLHours=this.CrewMembers[this.CrewMembers.length-2].WednesdayDBLHours;
                    this.CrewMembers[this.CrewMembers.length-1].WednesdayOTHours=this.CrewMembers[this.CrewMembers.length-2].WednesdayOTHours;
                    this.CrewMembers[this.CrewMembers.length-1].WednesdayRegHours=this.CrewMembers[this.CrewMembers.length-2].WednesdayRegHours;
                }
                if(cwCopyThursday === true)
                {
                    this.CrewMembers[this.CrewMembers.length-1].ThursdayDBLHours=this.CrewMembers[this.CrewMembers.length-2].ThursdayDBLHours;
                    this.CrewMembers[this.CrewMembers.length-1].ThursdayOTHours=this.CrewMembers[this.CrewMembers.length-2].ThursdayOTHours;
                    this.CrewMembers[this.CrewMembers.length-1].ThursdayRegHours=this.CrewMembers[this.CrewMembers.length-2].ThursdayRegHours;
                }
                if(cwCopyFriday === true)
                {
                    this.CrewMembers[this.CrewMembers.length-1].FridayDBLHours=this.CrewMembers[this.CrewMembers.length-2].FridayDBLHours;
                    this.CrewMembers[this.CrewMembers.length-1].FridayOTHours=this.CrewMembers[this.CrewMembers.length-2].FridayOTHours;
                    this.CrewMembers[this.CrewMembers.length-1].FridayRegHours=this.CrewMembers[this.CrewMembers.length-2].FridayRegHours;
                }
                if(cwCopySaturday === true)
                {
                    this.CrewMembers[this.CrewMembers.length-1].SaturdayDBLHours=this.CrewMembers[this.CrewMembers.length-2].SaturdayDBLHours;
                    this.CrewMembers[this.CrewMembers.length-1].SaturdayOTHours=this.CrewMembers[this.CrewMembers.length-2].SaturdayOTHours;
                    this.CrewMembers[this.CrewMembers.length-1].SaturdayRegHours=this.CrewMembers[this.CrewMembers.length-2].SaturdayRegHours;
                }
                if(cwCopySunday === true)
                {
                    this.CrewMembers[this.CrewMembers.length-1].SundayDBLHours=this.CrewMembers[this.CrewMembers.length-2].SundayDBLHours;
                    this.CrewMembers[this.CrewMembers.length-1].SundayOTHours=this.CrewMembers[this.CrewMembers.length-2].SundayOTHours;
                    this.CrewMembers[this.CrewMembers.length-1].SundayRegHours=this.CrewMembers[this.CrewMembers.length-2].SundayRegHours;
                }
            }
        }  

      //  console.log('Copy Hours Selected Day'+this.CrewMembers);
      //  console.log(this.CrewMembers);
        let TempCMData = this.CrewMembers;
        this.Supervisors = this.getAllSupervisorObjects();
        this.ProjectManagers = this.getAllProjectManagerObjects();
        this.GetOvrallTot(TempCMData, 'CM');
    }
    else{
        alert('Only Max of 25 allowed.');
    }
    }

    changetoZeroIfNull(val)
    {
        if (val === null || val === "" || val === undefined) {
            val = 0;
          }
          let parsedval = parseFloat(val)
          return parsedval;
    }

    CalulateTotals()
    {
        //this.CalculateSuperVisorTotal();
        //this.CalculateCrewMembersrTotal();
        //this.CalculateTotalCrewMembersPWHours();
        //this.CalculateTotalSupervisorPWHours();
    }

    CalculateSuperVisorTotal()
    {
        let SupervisorsTotal = this.Supervisors;
        let MondayTotal = 0.0;
        let TuesdayTotal = 0.0;
        let WednesdayTotal = 0.0;
        let ThursdayTotal = 0.0;
        let FridayTotal = 0.0;
        let SaturdayTotal = 0.0;
        let SundayTotal = 0.0;
        let Mondayregvalue = '';
      //  console.log(SupervisorsTotal);
        if(SupervisorsTotal){
        for(let supervisorIndex = 0; supervisorIndex<=SupervisorsTotal.length;supervisorIndex++)
        {
      //      console.log(SupervisorsTotal[supervisorIndex].MondayRegHours);
            Mondayregvalue = ''; 
            Mondayregvalue = SupervisorsTotal[supervisorIndex].MondayRegHours;
      //      console.log(Mondayregvalue);
        }
            this.Sup_MonTot = MondayTotal; 
            this.Sup_TueTot = TuesdayTotal; 
            this.Sup_WedTot = WednesdayTotal; 
            this.Sup_ThuTot = ThursdayTotal;  
            this.Sup_FriTot = FridayTotal;  
            this.Sup_SatTot = SaturdayTotal; 
            this.Sup_SunTot = SundayTotal; 
        }
    }

    CalculateCrewMembersrTotal()
    {
        let CrewMembersTotal = this.CrewMembers;
        let CwMondayTotal = 0.0;
        let CwTuesdayTotal = 0.0;
        let CwWednesdayTotal = 0.0;
        let CwThursdayTotal = 0.0;
        let CwFridayTotal = 0.0;
        let CwSaturdayTotal = 0.0;
        let CwSundayTotal = 0.0;
        if(CrewMembersTotal){
            CrewMembersTotal.forEach(function (CrewMember) {
                CwMondayTotal += this.changetoZeroIfNull(CrewMember.MondayDBLHours) + this.changetoZeroIfNull(CrewMember.MondayOTHours) + this.changetoZeroIfNull(CrewMember.MondayRegHours);
                CwTuesdayTotal += this.changetoZeroIfNull(CrewMember.TuesdayDBLHours) + this.changetoZeroIfNull(CrewMember.TuesdayOTHours) + this.changetoZeroIfNull(CrewMember.TuesdayRegHours);
                CwWednesdayTotal += this.changetoZeroIfNull(CrewMember.WednesdayDBLHours) + this.changetoZeroIfNull(CrewMember.WednesdayOTHours) + this.changetoZeroIfNull(CrewMember.WednesdayRegHours);
                CwThursdayTotal += this.changetoZeroIfNull(CrewMember.ThursdayDBLHours) + this.changetoZeroIfNull(CrewMember.ThursdayOTHours) + this.changetoZeroIfNull(CrewMember.ThursdayRegHours);
                CwFridayTotal += this.changetoZeroIfNull(CrewMember.FridayDBLHours) + this.changetoZeroIfNull(CrewMember.FridayOTHours) + this.changetoZeroIfNull(CrewMember.FridayRegHours);
                CwSaturdayTotal += this.changetoZeroIfNull(CrewMember.SaturdayDBLHours) + this.changetoZeroIfNull(CrewMember.SaturdayOTHours) + this.changetoZeroIfNull(CrewMember.SaturdayRegHours);
                CwSundayTotal += this.changetoZeroIfNull(CrewMember.SundayDBLHours) + this.changetoZeroIfNull(CrewMember.SundayOTHours) + this.changetoZeroIfNull(CrewMember.SundayRegHours);
            });
            this.CM_MonTot = CwMondayTotal; 
            this.CM_TueTot = CwTuesdayTotal;  
            this.CM_WedTot = CwWednesdayTotal;  
            this.CM_ThuTot = CwThursdayTotal;  
            this.CM_FriTot = CwFridayTotal; 
            this.CM_SatTot = CwSaturdayTotal; 
            this.CM_SunTot = CwSundayTotal; 
        }
    }

    CalculateTotalCrewMembersPWHours()
    {
        let TotalCrewMembersPW = this.CrewMembers;
        let CrewMemberRegNonPW = 0.0;
        let CrewMemberRegPW = 0.0;
        let CrewMemberOTNonPW = 0.0;
        let CrewMemberOTPW = 0.0;
        let CrewMemberDblNonPW = 0.0;
        let CrewMemberrDblPW = 0.0;
        if(TotalCrewMembersPW){
            TotalCrewMembersPW.forEach(function (CrewMember) {
                if(CrewMember.PW === true)
                {
                    CrewMemberRegPW += (this.changetoZeroIfNull(CrewMember.MondayRegHours) + this.changetoZeroIfNull(CrewMember.TuesdayRegHours)
                                    + this.changetoZeroIfNull(CrewMember.WednesdayRegHours) + this.changetoZeroIfNull(CrewMember.ThursdayRegHours)
                                    + this.changetoZeroIfNull(CrewMember.FridayRegHours) + this.changetoZeroIfNull(CrewMember.SaturdayRegHours)
                                    + this.changetoZeroIfNull(CrewMember.SundayRegHours));
                    CrewMemberOTPW += (this.changetoZeroIfNull(CrewMember.MondayOTHours) + this.changetoZeroIfNull(CrewMember.TuesdayOTHours)
                        + this.changetoZeroIfNull(CrewMember.WednesdayOTHours) + this.changetoZeroIfNull(CrewMember.ThursdayOTHours)
                        + this.changetoZeroIfNull(CrewMember.FridayOTHours) + this.changetoZeroIfNull(CrewMember.SaturdayOTHours)
                        + this.changetoZeroIfNull(CrewMember.SundayOTHours));
                    CrewMemberrDblPW += (this.changetoZeroIfNull(CrewMember.MondayDBLHours) + this.changetoZeroIfNull(CrewMember.TuesdayDBLHours)
                        + this.changetoZeroIfNull(CrewMember.WednesdayDBLHours) + this.changetoZeroIfNull(CrewMember.ThursdayDBLHours)
                        + this.changetoZeroIfNull(CrewMember.FridayDBLHours) + this.changetoZeroIfNull(CrewMember.SaturdayDBLHours)
                        + this.changetoZeroIfNull(CrewMember.SundayDBLHours));
                }
                else
                {
                    CrewMemberRegNonPW += (this.changetoZeroIfNull(CrewMember.MondayRegHours) + this.changetoZeroIfNull(CrewMember.TuesdayRegHours)
                    + this.changetoZeroIfNull(CrewMember.WednesdayRegHours) + this.changetoZeroIfNull(CrewMember.ThursdayRegHours)
                    + this.changetoZeroIfNull(CrewMember.FridayRegHours) + this.changetoZeroIfNull(CrewMember.SaturdayRegHours)
                    + this.changetoZeroIfNull(CrewMember.SundayRegHours));
                    CrewMemberOTNonPW += (this.changetoZeroIfNull(CrewMember.MondayOTHours) + this.changetoZeroIfNull(CrewMember.TuesdayOTHours)
                    + this.changetoZeroIfNull(CrewMember.WednesdayOTHours) + this.changetoZeroIfNull(CrewMember.ThursdayOTHours)
                    + this.changetoZeroIfNull(CrewMember.FridayOTHours) + this.changetoZeroIfNull(CrewMember.SaturdayOTHours)
                    + this.changetoZeroIfNull(CrewMember.SundayOTHours));
                    CrewMemberDblNonPW += (this.changetoZeroIfNull(CrewMember.MondayDBLHours) + this.changetoZeroIfNull(CrewMember.TuesdayDBLHours)
                    + this.changetoZeroIfNull(CrewMember.WednesdayDBLHours) + this.changetoZeroIfNull(CrewMember.ThursdayDBLHours)
                    + this.changetoZeroIfNull(CrewMember.FridayDBLHours) + this.changetoZeroIfNull(CrewMember.SaturdayDBLHours)
                    + this.changetoZeroIfNull(CrewMember.SundayDBLHours));
                }
            });
            this.PWRegCW = CrewMemberRegPW; this.PWOTCW = CrewMemberOTPW; this.PWDBLCW = CrewMemberrDblPW;
        this.NPWRegCW = CrewMemberRegNonPW; this.NPWOTCW = CrewMemberOTNonPW; this.NPWDBLCW = CrewMemberDblNonPW;
        }
    }

    CalculateTotalSupervisorPWHours()
    {
        let TotalSupervisorsPW = this.Supervisors;
        let SupervisorRegNonPW = 0.0;
        let SupervisorRegPW = 0.0;
        let SupervisorOTNonPW = 0.0;
        let SupervisorOTPW = 0.0;
        let SupervisorDblNonPW = 0.0;
        let SupervisorDblPW = 0.0;
        if(TotalSupervisorsPW){
            TotalSupervisorsPW.forEach(function (Supervisor) {
                if(Supervisor.PW === true)
                {
                    SupervisorRegPW += (this.changetoZeroIfNull(Supervisor.MondayRegHours) + this.changetoZeroIfNull(Supervisor.TuesdayRegHours)
                                    + this.changetoZeroIfNull(Supervisor.WednesdayRegHours) + this.changetoZeroIfNull(Supervisor.ThursdayRegHours)
                                    + this.changetoZeroIfNull(Supervisor.FridayRegHours) + this.changetoZeroIfNull(Supervisor.SaturdayRegHours)
                                    + this.changetoZeroIfNull(Supervisor.SundayRegHours));
                    SupervisorOTPW += (this.changetoZeroIfNull(Supervisor.MondayOTHours) + this.changetoZeroIfNull(Supervisor.TuesdayOTHours)
                        + this.changetoZeroIfNull(Supervisor.WednesdayOTHours) + this.changetoZeroIfNull(Supervisor.ThursdayOTHours)
                        + this.changetoZeroIfNull(Supervisor.FridayOTHours) + this.changetoZeroIfNull(Supervisor.SaturdayOTHours)
                        + this.changetoZeroIfNull(Supervisor.SundayOTHours));
                    SupervisorDblPW += (this.changetoZeroIfNull(Supervisor.MondayDBLHours) + this.changetoZeroIfNull(Supervisor.TuesdayDBLHours)
                        + this.changetoZeroIfNull(Supervisor.WednesdayDBLHours) + this.changetoZeroIfNull(Supervisor.ThursdayDBLHours)
                        + this.changetoZeroIfNull(Supervisor.FridayDBLHours) + this.changetoZeroIfNull(Supervisor.SaturdayDBLHours)
                        + this.changetoZeroIfNull(Supervisor.SundayDBLHours));
                }
                else
                {
                    SupervisorRegNonPW += (this.changetoZeroIfNull(Supervisor.MondayRegHours) + this.changetoZeroIfNull(Supervisor.TuesdayRegHours)
                    + this.changetoZeroIfNull(Supervisor.WednesdayRegHours) + this.changetoZeroIfNull(Supervisor.ThursdayRegHours)
                    + this.changetoZeroIfNull(Supervisor.FridayRegHours) + this.changetoZeroIfNull(Supervisor.SaturdayRegHours)
                    + this.changetoZeroIfNull(Supervisor.SundayRegHours));
                    SupervisorOTNonPW += (this.changetoZeroIfNull(Supervisor.MondayOTHours) + this.changetoZeroIfNull(Supervisor.TuesdayOTHours)
                    + this.changetoZeroIfNull(Supervisor.WednesdayOTHours) + this.changetoZeroIfNull(Supervisor.ThursdayOTHours)
                    + this.changetoZeroIfNull(Supervisor.FridayOTHours) + this.changetoZeroIfNull(Supervisor.SaturdayOTHours)
                    + this.changetoZeroIfNull(Supervisor.SundayOTHours));
                    SupervisorDblNonPW += (this.changetoZeroIfNull(Supervisor.MondayDBLHours) + this.changetoZeroIfNull(Supervisor.TuesdayDBLHours)
                    + this.changetoZeroIfNull(Supervisor.WednesdayDBLHours) + this.changetoZeroIfNull(Supervisor.ThursdayDBLHours)
                    + this.changetoZeroIfNull(Supervisor.FridayDBLHours) + this.changetoZeroIfNull(Supervisor.SaturdayDBLHours)
                    + this.changetoZeroIfNull(Supervisor.SundayDBLHours));
                }
            });
            this.PWReg = SupervisorRegPW; this.PWOT = SupervisorOTPW; this.PWDBL = SupervisorDblPW;
            this.NPWReg = SupervisorRegNonPW; this.NPWOT = SupervisorOTNonPW; this.NPWDBL = SupervisorDblNonPW;
        }
    }


    StartdateOnLoad(){

        var curr;
        var monday;
        var first;
        var d;
     //   console.log('StartdateOnLoad');
     //   console.log('TestingdailyTimesheetIdtosearch'+this.dailyTimesheetIdtosearch);
        if(this.dailyTimesheetIdtosearch != null)
        {
      //      console.log('if condition');
            this.Date_startDate = this.dailyTimesheetJobStartDate;
     //       console.log('Line : 1752 dailyTimesheetJobStartDate -----> '+this.dailyTimesheetJobStartDate);
     //       console.log('testingDate_startDate'+this.Date_startDate);
            return this.Date_startDate;
            
        }
        else{
     //       console.log('else');
        curr = new Date();         
        d = parseFloat(curr.getDay());
    //    console.log('Date ----> d =  '+d);
        if(d === 0)
        {
            d = 7;
        }
        first = curr.getDate() - d;   
        first = first + 1;
        monday = new Date(curr.setDate(first));
        this.Date_startDate = monday.getFullYear()+'-'+[monday.getMonth()+1]+'-'+monday.getDate();
        this.thisWeekstart = monday.getFullYear()+'-'+[monday.getMonth()+1]+'-'+monday.getDate();
        this.Disval = 'true'; 
    //    console.log('line : 1774 this.Date_startDate from startdate on load --->'+this.Date_startDate);
        return   this.Date_startDate;                
        } 
    }
    DatefilledOnload(){
       
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var sdate = new Date(this.Date_startDate+' 00:00');
        var CurrentDate = new Date();
        var convertedsdate = this.dateConversion(sdate);
        var convertedcurrentdate = this.dateConversion(CurrentDate);
        var nextweekclick;
        
      //  console.log('line : 1786 HeadInput StartDate ---- > '+this.template.querySelector('.StartDate').value);
     //   console.log('line : 1787 this.Date_startDate ---- > '+this.Date_startDate);
     //   console.log('line : 1789 this.sdate ---- > '+sdate);

       
        
        this.MonToCheck = convertedsdate;
     //   console.log('this.MonToCheck ----> '+this.MonToCheck);

        this.Date_mon = months[sdate.getMonth()]+' '+sdate.getDate();
        if(sdate > CurrentDate || this.restrict ===true) this.DisableMon = true; else this.DisableMon = false;

        this.sdate = sdate.setDate(sdate.getDate() +1);
        convertedsdate = this.dateConversion(sdate);

        this.Date_tue = months[sdate.getMonth()]+' '+sdate.getDate();
        this.TueToCheck = convertedsdate;
     //   console.log('TueDate:'+convertedsdate+' CurrentDate:'+convertedcurrentdate);
        if(sdate > CurrentDate || this.restrict ===true) this.DisableTue = true; else this.DisableTue = false;
        
        this.sdate = sdate.setDate(sdate.getDate() +1);
        convertedsdate = this.dateConversion(sdate);
        this.Date_wed = months[sdate.getMonth()]+' '+sdate.getDate();
        this.WedToCheck = convertedsdate;
        if(sdate > CurrentDate || this.restrict ===true) this.DisableWed = true; else this.DisableWed = false;
       
        this.sdate = sdate.setDate(sdate.getDate() +1);
        convertedsdate = this.dateConversion(sdate);
        this.Date_thu = months[sdate.getMonth()]+' '+sdate.getDate();
        this.ThuToCheck = convertedsdate;
        if(sdate > CurrentDate || this.restrict ===true) this.DisableThu = true; else this.DisableThu = false;
        
        this.sdate = sdate.setDate(sdate.getDate() +1);
        convertedsdate = this.dateConversion(sdate);
        this.Date_fri = months[sdate.getMonth()]+' '+sdate.getDate();
        this.FriToCheck = convertedsdate;
        if(sdate > CurrentDate || this.restrict===true) this.DisableFri = true; else this.DisableFri = false;
        
        this.sdate = sdate.setDate(sdate.getDate() +1);
        convertedsdate = this.dateConversion(sdate);
        this.Date_sat = months[sdate.getMonth()]+' '+sdate.getDate();
        this.SatToCheck = convertedsdate;
        if(sdate > CurrentDate || this.restrict===true) this.DisableSat = true; else this.DisableSat = false;
        
        this.sdate = sdate.setDate(sdate.getDate() +1);
        convertedsdate = this.dateConversion(sdate);
        this.Date_sun = months[sdate.getMonth()]+' '+sdate.getDate();
        this.SunToCheck = convertedsdate;
        if(sdate > CurrentDate || this.restrict===true) 
        {
            this.DisableSun = true; 
            this.NextWeekBlock = true; 
        }
        else 
        {
            this.DisableSun = false;
        }
       
//console.log('this.SunToCheck'+this.SunToCheck);


        this.Date_endDate = sdate.getFullYear()+'-'+[sdate.getMonth()+1]+'-'+sdate.getDate();
    //    console.log('this.Date_endDate '+this.Date_endDate);

        nextweekclick = new Date().getDay();

    //    console.log('nextweekclick --> '+nextweekclick+'sdate --> '+sdate.getDate());
        if(nextweekclick === 0)
        {
           // this.template.querySelector('.DateRit').disabled = 'true';
           this.NextWeekBlock = true;
      //     console.log('NextWeekBlock'+this.NextWeekBlock);
        }
    
        

    }

    dateConversion(testsdate){
        this.date = testsdate.getDate();
        this.month = testsdate.getMonth(); //Be careful! January is 0 not 1
        this.year = testsdate.getFullYear();
        this.testsdate = this.year + "-" +(this.month + 1) + "-" + this.date;
        return this.testsdate;
        }

    DeletePDRow(e){
        this.ProjectManagers = this.getAllProjectManagerObjects();
        let DeleteRowIndex = e.target.parentNode.parentNode.rowIndex;
        this.ProjectManagers.splice(DeleteRowIndex-1,1);

        this.Supervisors = this.getAllSupervisorObjects();
        this.CrewMembers = this.getAllCrewMembersObjects();
    }
    DeleteSUPRow(e){
        let TempSup = this.getAllSupervisorObjects();
        let DeleteRowIndex = e.target.parentNode.parentNode.rowIndex;
        TempSup.splice(DeleteRowIndex-1,1);
        this.Supervisors = TempSup;
        //this.template.querySelector('table.SupTbl tbody').deleteRow(DeleteRowIndex-1);
        this.ProjectManagers = this.getAllProjectManagerObjects();
        this.CrewMembers = this.getAllCrewMembersObjects();
        this.GetOvrallTot(TempSup, 'Sup');
    }
    DeleteCMRow(e){
        let TempCM = this.getAllCrewMembersObjects();
        let DeleteRowIndex = e.target.parentNode.parentNode.rowIndex;
        TempCM.splice(DeleteRowIndex-1,1);
        this.CrewMembers = TempCM;
        //this.template.querySelector('table.CWTbl tbody').deleteRow(DeleteRowIndex-1);
        this.ProjectManagers = this.getAllProjectManagerObjects();
        this.Supervisors = this.getAllSupervisorObjects();
        this.GetOvrallTot(TempCM, 'CM');
    }




}