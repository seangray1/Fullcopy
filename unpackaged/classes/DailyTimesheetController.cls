public without sharing class DailyTimesheetController {
     
    @AuraEnabled (cacheable=true)
    public static List<Daily_Timesheet__c> currentTimesheetDetails(String dailyTimesheetIdtosearch)
    {       
                List<Daily_Timesheet__c>  dailyTimesheetJobDetails = [SELECT DailyTimsheetRecord__c,Comments__c,Shift__c,Location__c,EndDate__c,Final__c,Id,Job__c,Job__r.Job_Name__c,Job__r.Job_Number__c,Job__r.Project_manager__r.Name,Name,StartDate__c FROM Daily_Timesheet__c WHERE Id =: dailyTimesheetIdtosearch ]; 
                system.debug('######'+dailyTimesheetJobDetails);
                return dailyTimesheetJobDetails; 
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ATI_Job__c> currentJobDetails(String jobIdtosearch)
    {
        List<ATI_Job__c>  JobDetailsFromDailyTimesheet = [SELECT Id,Job_Name__c,Job_Start_Date__c,CloseDate__c,Job_Number__c,Name,Project_Manager__c,Project_Site_Address_Concat__c,Project_Manager__r.Name,Project_Site_Address__c,Project_Site_City__c,Project_Site_State__c,Project_Site_Zipcode__c FROM ATI_Job__c WHERE Id =: jobIdtosearch ]; 
        system.debug('@#@#@@#'+JobDetailsFromDailyTimesheet);
        system.debug('$%$%$%$'+JobDetailsFromDailyTimesheet[0].Project_Manager__r.Name);
        return JobDetailsFromDailyTimesheet; 
    }
    
    @AuraEnabled(cacheable=true)
    public static String currentUserProfileName(String user)
    {
        Id profileId=userinfo.getProfileId();
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
		system.debug('ProfileName'+profileName);
        return profileName;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<Daily_Timesheet__c> OnchangeTimesheetDetails(String jobIdtosearch,String StartDate)
    {	
        string[] datesplit;
        if(StartDate.contains('-'))
        	datesplit = StartDate.split('-');
       	else
            datesplit = StartDate.split('/');
        system.debug('datesplit -------> '+datesplit);
        Integer yeartosearch =integer.valueof(datesplit[0]);
        Integer monthtosearch =integer.valueof(datesplit[1]);
        Integer datevaluetosearch =integer.valueof(datesplit[2]);
        Date dateToSearch = date.newInstance(yeartosearch,monthtosearch,datevaluetosearch);
         system.debug('!#!#!#!#if'+dateToSearch);
        List <Daily_Timesheet__c> dailyTimesheetJobDetails = new List <Daily_Timesheet__c>();
        List <Daily_Timesheet__c> dailyTimesheetJobDetails1 = new List <Daily_Timesheet__c>();
        
        dailyTimesheetJobDetails = [SELECT DailyTimsheetRecord__c,Comments__c,Shift__c,EndDate__c,Final__c,Id,Job__c,Job__r.Job_Name__c,Job__r.Job_Number__c,Job__r.Project_manager__r.Name,Name,StartDate__c,Location__c FROM Daily_Timesheet__c WHERE Job__c =: jobIdtosearch and StartDate__c =: dateToSearch ]; 
            if(!dailyTimesheetJobDetails.isEmpty()){
                system.debug('!#!#!#!#if'+dailyTimesheetJobDetails);
                return dailyTimesheetJobDetails;
                
            }
        
                else{
                        Daily_Timesheet__c Dailytimesheet1 = new Daily_Timesheet__c();
                        Dailytimesheet1.Shift__c='Day';
                        Dailytimesheet1.Final__c=false;
                        Dailytimesheet1.Location__c='';
                        Dailytimesheet1.comments__c='';
                        Dailytimesheet1.StartDate__c=dateToSearch;
                        Dailytimesheet1.EndDate__c= dateToSearch.addDays(6);
                        Dailytimesheet1.DailyTimsheetRecord__c='noData';
                        dailyTimesheetJobDetails1.add(Dailytimesheet1);
                    
                        system.debug('!#!#!#!#else'+dailyTimesheetJobDetails1);
                    
                        return dailyTimesheetJobDetails1;
                        
                        }
    }
    
    @AuraEnabled
    public static String saveDailyTimesheet(String timesheetID,String dailyTimesheetJson,String JobID,String StartDate,String EndDate,Boolean finalcheckbox,string location,string shift,string JobNumber, string comments) 
    {
        
        String success='Saved Successfully';
        String Error='Timesheet not saved';
                
                string[] datesplitstartdate = StartDate.split('-');
                Integer startdateyear =integer.valueof(datesplitstartdate[0]);
                Integer startdatemonth =integer.valueof(datesplitstartdate[1]);
                Integer startdatedate =integer.valueof(datesplitstartdate[2]);
                Date newstartdate = date.newInstance(startdateyear,startdatemonth,startdatedate);
              
                
                string[] datesplitenddate = EndDate.split('-');
                Integer enddateyear =integer.valueof(datesplitenddate[0]);
                Integer enddatemonth =integer.valueof(datesplitenddate[1]);
                Integer enddatedate =integer.valueof(datesplitenddate[2]);
                Date newenddate = date.newInstance(enddateyear,enddatemonth,enddatedate);

           
             List<Daily_Timesheet__c> timesheetList =[SELECT ID,Name,EndDate__c,Job__c,StartDate__c,Final__c,Location__c,Shift__c,DailyTimsheetRecord__c, comments__c FROM Daily_Timesheet__c WHERE Job__c =: JobID and StartDate__c =: newstartdate];
             List<Daily_Timesheet__c> timesheetListUpdated = new List<Daily_Timesheet__c>();
             Daily_Timesheet__c Dailytimesheet =new Daily_Timesheet__c();
                if(!timesheetList.isEmpty())
                {   
                    
                    Dailytimesheet.Id=timesheetList[0].id;
                    Dailytimesheet.StartDate__c=newstartdate;
                    Dailytimesheet.EndDate__c=newenddate;
                    Dailytimesheet.Name=JobNumber+'-'+StartDate+'-'+EndDate;
                    Dailytimesheet.DailyTimsheetRecord__c=dailyTimesheetJson;
                    Dailytimesheet.Shift__c= shift;
                    Dailytimesheet.Location__c=location;
                    Dailytimesheet.Final__c=finalcheckbox;
                    Dailytimesheet.comments__c=comments;
                    
                    timesheetListUpdated.add(Dailytimesheet);   
                    
                    system.debug('upadateaction'+timesheetListUpdated);
                }
                else
                {
                   Dailytimesheet.Job__c=JobID;
                   Dailytimesheet.StartDate__c=newstartdate;
                   Dailytimesheet.EndDate__c=newenddate;
                   Dailytimesheet.DailyTimsheetRecord__c=dailyTimesheetJson;
                   Dailytimesheet.Final__c=finalcheckbox;
                   Dailytimesheet.Location__c=location;
                   Dailytimesheet.Shift__c= shift;
                   Dailytimesheet.Name=JobNumber+'-'+StartDate+'-'+EndDate;
                   Dailytimesheet.comments__c=comments;
                    
                   
                   timesheetListUpdated.add(Dailytimesheet);     
                 }
                     
        
        if(!timesheetListUpdated.isEmpty()){
            upsert timesheetListUpdated;
            system.debug('Test$$$$$'+timesheetListUpdated);
            return timesheetListUpdated[0].id;
           
        }
        else{
            return Error;
        }
          

    }
    
    @AuraEnabled(cacheable=true)
    public static List<ATI_Job__c> findJobs(String searchKey) {
        system.debug('parameter -' + searchKey);
        String key = '%' + searchKey + '%';
        return [SELECT Id,Job_Name__c,Job_Number_No_Dashes__c,Job_Number_No_Dash_Last_5__c,Job_Number__c,Name,
                Project_Site_Address_2__c,Project_Site_Address_CityStZIP__c,Project_Site_Address_Concat__c,
                Project_Site_Address_Link__c,Project_Site_Address__c,Project_Site_City__c,Project_Site_State__c,Project_Site_Zipcode__c
                FROM ATI_Job__c WHERE Name LIKE :key LIMIT 10];
    }
    
}