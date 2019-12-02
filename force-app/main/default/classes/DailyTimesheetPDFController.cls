public without sharing class DailyTimesheetPDFController {

    public String Location{ get; set; }
    public JSON2Apex DailyTimeSheet{ get; set; }
    public date StartDate{ get; set; }
    public date EndDate{ get; set; }
    public string JobName{ get; set; }
    public string JobNumber{ get; set; }
    public string Shift{ get; set; }
    public string Comments{ get; set; }
    
    public string GetSDate{get; set;}
    public string Date_mon{get; set;}
    public string Date_tue{get; set;}
    public string Date_wed{get; set;}
    public string Date_thu{get; set;}
    public string Date_fri{get; set;}
    public string Date_sat{get; set;}
    public string Date_sun{get; set;}
    public string GetEDate{get; set;}

    public  DailyTimesheetPDFController() {
    
    ID timesheetID= ApexPages.currentPage().getParameters().get('dt__id');
    List<daily_timesheet__c> timesheetDetailList = [SELECT DailyTimsheetRecord__c,EndDate__c,Final__c,Id,Job__c,Job__r.Job_Name__c,comments__c,Job__r.Job_Number__c,Location__c,Name,Shift__c,StartDate__c FROM Daily_Timesheet__c where Id =: timesheetID];
        string jsonstring = timesheetDetailList[0].DailyTimsheetRecord__c;
        location = timesheetDetailList[0].Location__c;
        StartDate = timesheetDetailList[0].StartDate__c;
        EndDate = timesheetDetailList[0].EndDate__c;
        JobName = timesheetDetailList[0].Job__r.Job_Name__c;
        JobNumber = timesheetDetailList[0].Job__r.Job_Number__c;
        Shift = timesheetDetailList[0].Shift__c;
        Comments = timesheetDetailList[0].comments__c;
        
        List<String> months = new List<String>{'', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
        date sdate = Date.valueOf(StartDate);
        GetSDate = months[sdate.month()]+' '+sdate.day()+', '+sdate.year();
        
     	Date_mon = months[sdate.month()]+' '+sdate.day();
    	sdate = sdate.addDays(1);
    	Date_tue = months[sdate.month()]+' '+sdate.day();
    	sdate = sdate.addDays(1);
        Date_wed = months[sdate.month()]+' '+sdate.day();
    	sdate = sdate.addDays(1);
        Date_thu = months[sdate.month()]+' '+sdate.day();
    	sdate = sdate.addDays(1);
        Date_fri = months[sdate.month()]+' '+sdate.day();
    	sdate = sdate.addDays(1);
        Date_sat = months[sdate.month()]+' '+sdate.day();
    	sdate = sdate.addDays(1);
        Date_sun = months[sdate.month()]+' '+sdate.day();
        
        GetEDate = months[sdate.month()]+' '+sdate.day()+', '+sdate.year();
    	
    // this.Date_endDate = months[sdate.getMonth()]+' '+sdate.getDate()+', '+sdate.getFullYear();
    	//Date_endDate = sdate.getFullYear()+'-'+[sdate.getMonth()+1]+'-'+sdate.getDate();
        
        
        DailyTimeSheet =(JSON2Apex)parse(timesheetDetailList[0].DailyTimsheetRecord__c); 
      //  attach();
        
    }
    
     public class JSON2Apex 
    {
        public List<ProjectManagers> ProjectManagers{ get; set; }
        public List<Supervisors> Supervisors{ get; set; }
        public List<CrewMembers> CrewMembers{ get; set; }
        public Decimal TotSupPWReg{ get; set; }
        public Decimal TotSupPWOT{ get; set; }
        public Decimal TotSupPWDBL{ get; set; }
        public Decimal TotSupNPWReg{ get; set; }
        public Decimal TotSupNPWOT{ get; set; }
        public Decimal TotSupNPWDBL{ get; set; }
        public Decimal TotCWPWReg{ get; set; }
        public Decimal TotCWPWOT{ get; set; }
        public Decimal TotCWPWDBL{ get; set; }
        public Decimal TotCWNPWReg{ get; set; }
        public Decimal TotCWNPWOT{ get; set; }
        public Decimal TotCWNPWDBL{ get; set; }
        public String TotSupMon{get; set;}
        public String TotSupTue{get; set;}
        public String TotSupWed{get; set;}
        public String TotSupThu{get; set;}
        public String TotSupFri{get; set;}
        public String TotSupSat{get; set;}
        public String TotSupSun{get; set;}
        public String TotCWMon{get; set;}
        public String TotCWTue{get; set;}
        public String TotCWWed{get; set;}
        public String TotCWThu{get; set;}
        public String TotCWFri{get; set;}
        public String TotCWSat{get; set;}
        public String TotCWSun{get; set;}
      
    }
    
    public class ProjectManagers
   {
        public String Name{get; set;}
        public String PW{get; set;}
        public String LaborCode{get; set;}
        public String MondayDBLHours{get; set;}
        public String MondayOTHours{get; set;}
        public String MondayRegHours{get; set;}
        public String TuesdayDBLHours{get; set;}
        public String TuesdayOTHours{get; set;}
        public String TuesdayRegHours{get; set;}
        public String WednesdayDBLHours{get; set;}
        public String WednesdayOTHours{get; set;}
        public String WednesdayRegHours{get; set;}
        public String ThursdayDBLHours{get; set;}
        public String ThursdayOTHours{get; set;}
        public String ThursdayRegHours{get; set;}
        public String FridayDBLHours{get; set;}
        public String FridayOTHours{get; set;}
        public String FridayRegHours{get; set;}
        public String SaturdayDBLHours{get; set;}
        public String SaturdayOTHours{get; set;}
        public String SaturdayRegHours{get; set;}
        public String SundayDBLHours{get; set;}
        public String SundayOTHours{get; set;}
        public String SundayRegHours{get; set;}

        
    }
    
     public class Supervisors
   {
        public String Name{get; set;}
        public String PW{get; set;}
        public String LaborCode{get; set;}
        public String MondayDBLHours{get; set;}
        public String MondayOTHours{get; set;}
        public String MondayRegHours{get; set;}
        public String TuesdayDBLHours{get; set;}
        public String TuesdayOTHours{get; set;}
        public String TuesdayRegHours{get; set;}
        public String WednesdayDBLHours{get; set;}
        public String WednesdayOTHours{get; set;}
        public String WednesdayRegHours{get; set;}
        public String ThursdayDBLHours{get; set;}
        public String ThursdayOTHours{get; set;}
        public String ThursdayRegHours{get; set;}
        public String FridayDBLHours{get; set;}
        public String FridayOTHours{get; set;}
        public String FridayRegHours{get; set;}
        public String SaturdayDBLHours{get; set;}
        public String SaturdayOTHours{get; set;}
        public String SaturdayRegHours{get; set;}
        public String SundayDBLHours{get; set;}
        public String SundayOTHours{get; set;}
        public String SundayRegHours{get; set;}

    }
    
     public class CrewMembers
   {
       public String Name{get; set;}
        public String PW{get; set;}
        public String LaborCode{get; set;}
        public String MondayDBLHours{get; set;}
        public String MondayOTHours{get; set;}
        public String MondayRegHours{get; set;}
        public String TuesdayDBLHours{get; set;}
        public String TuesdayOTHours{get; set;}
        public String TuesdayRegHours{get; set;}
        public String WednesdayDBLHours{get; set;}
        public String WednesdayOTHours{get; set;}
        public String WednesdayRegHours{get; set;}
        public String ThursdayDBLHours{get; set;}
        public String ThursdayOTHours{get; set;}
        public String ThursdayRegHours{get; set;}
        public String FridayDBLHours{get; set;}
        public String FridayOTHours{get; set;}
        public String FridayRegHours{get; set;}
        public String SaturdayDBLHours{get; set;}
        public String SaturdayOTHours{get; set;}
        public String SaturdayRegHours{get; set;}
        public String SundayDBLHours{get; set;}
        public String SundayOTHours{get; set;}
        public String SundayRegHours{get; set;}

        
    }
    
    public static JSON2Apex parse(String json) 
    {
        return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }
    public void attach()
    {
        
    ID timesheetID= ApexPages.currentPage().getParameters().get('dt__id');
    List<daily_timesheet__c> timesheetDetailedList = [SELECT DailyTimsheetRecord__c,EndDate__c,Final__c,Id,Job__c,Location__c,Name,Shift__c,StartDate__c FROM Daily_Timesheet__c where Id =: timesheetID];
    
     PageReference mypage = Page.DailyTimesheetPDFpageTemplate;
	 mypage.getParameters().put('dt__id',timesheetDetailedList[0].id);
	 mypage.setRedirect(true);
	 blob b = mypage.getContentAsPDF();
	 Attachment mydoc = new Attachment();
	 mydoc.body = b;
	 mydoc.Name=timesheetDetailedList[0].Name + Datetime.now();
	 mydoc.ContentType = '.pdf';
     mydoc.ParentId = timesheetDetailedList[0].job__c;
      
	 insert mydoc;
    }
    @AuraEnabled
    public static void attachonly(ID timesheetID)
    {
    List<daily_timesheet__c> timesheetDetailedList = [SELECT DailyTimsheetRecord__c,EndDate__c,Final__c,Id,Job__c,Location__c,Name,Shift__c,StartDate__c FROM Daily_Timesheet__c where Id =: timesheetID];
    
     PageReference mypage = Page.DailyTimesheetPDFpageTemplate;
	 mypage.getParameters().put('dt__id',timesheetDetailedList[0].id);
	 mypage.setRedirect(true);
	 blob b = mypage.getContentAsPDF();
	 Attachment mydoc = new Attachment();
	 mydoc.body = b;
	 mydoc.Name=timesheetDetailedList[0].Name + Datetime.now();
	 mydoc.ContentType = '.pdf';
     mydoc.ParentId = timesheetDetailedList[0].job__c;
      
	 insert mydoc;
    }
       
}