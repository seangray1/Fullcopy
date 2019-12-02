public with sharing class AccountExecutiveController {
    
    
    
    /* Job Object Record Insert */
          
    public static void UpdateAccountExecutives(List<ati_job__c> jobs)
    {

        list<Account_Executive_Revenue__c> AccountExecutiveList = new list<Account_Executive_Revenue__c>([SELECT Account_Executive__c,Id,IsActive__c,Job__c,Name,Type__c FROM Account_Executive_Revenue__c where Job__c in: jobs]);
        list<Account_Executive_Revenue__c> UpdatableAccountExecutiveList = new list<Account_Executive_Revenue__c>();
        list<Account_Executive_Revenue__c> InsertableAccountExecutiveList = new list<Account_Executive_Revenue__c>();
        boolean accountExecutive1IsInserted = false;
        boolean accountExecutive2IsInserted = false;
        
        for(ati_job__c jobRecord:jobs)
        {
           list<Account_Executive_Revenue__c> filteredAccountExecutives = FilterAccountExecutive(AccountExecutiveList, jobRecord.ID);
           accountExecutive1IsInserted = false;
           accountExecutive2IsInserted = false; 
           for(Account_Executive_Revenue__c AccountExecutiveRecord:filteredAccountExecutives) 
           { 
               if(AccountExecutiveRecord.Type__c == 'Account Executive 1')
               {
                   accountExecutive1IsInserted = true;
                   UpdatableAccountExecutiveList.add(GetUpdatedAccountExecutives(AccountExecutiveRecord, jobRecord.Account_Executive_1__c));                  
               }
               else if(AccountExecutiveRecord.Type__c == 'Account Executive 2')
               {
                   accountExecutive2IsInserted = true;
                   UpdatableAccountExecutiveList.add(GetUpdatedAccountExecutives(AccountExecutiveRecord, jobRecord.Account_Executive_2__c));
               }  
           }
            
           if(!accountExecutive1IsInserted)
           		InsertableAccountExecutiveList.add(GetInsertableAccountRevenueRecord(jobRecord.id,jobRecord.Name,jobRecord.Job_Name__c,jobRecord.Account_Executive_1__c,'Account Executive 1'));           
           if(!accountExecutive2IsInserted)
            	InsertableAccountExecutiveList.add(GetInsertableAccountRevenueRecord(jobRecord.id,jobRecord.Name,jobRecord.Job_Name__c,jobRecord.Account_Executive_2__c,'Account Executive 2'));            
        }
       
        if(UpdatableAccountExecutiveList.size() > 0)
        {
          update UpdatableAccountExecutiveList;
        }
            
        if(InsertableAccountExecutiveList.size() > 0)
        {
          //  insert InsertableAccountExecutiveList;
        }    
        
        UpdateForecastAccountExecutiveRecord(Jobs);
        
    }
    
    public static Account_Executive_Revenue__c GetInsertableAccountRevenueRecord(ID Job, String jobNumber,String jobName, ID AccountExecutive,String AccountExecutiveName)
    {
        Account_Executive_Revenue__c AccountExecutiveRecord = new Account_Executive_Revenue__c();
        
        AccountExecutiveRecord.Name = jobNumber + '|' + AccountExecutiveName;
        AccountExecutiveRecord.Job__c = Job;
        AccountExecutiveRecord.Type__c = AccountExecutiveName;
        AccountExecutiveRecord.IsActive__c = true; 
        AccountExecutiveRecord.Account_Executive__c = AccountExecutive;
        
        return AccountExecutiveRecord;        
    }
       
    public static Account_Executive_Revenue__c GetUpdatedAccountExecutives(Account_Executive_Revenue__c AccountExecutiveRecord, ID AccountExecutive)
    {
        if(string.isnotblank(AccountExecutive))
        {
        	AccountExecutiveRecord.Account_Executive__c = AccountExecutive;
        	AccountExecutiveRecord.IsActive__c = true;
        }
        else
        {
            AccountExecutiveRecord.Account_Executive__c = null;
        	AccountExecutiveRecord.IsActive__c = false;
            
        }
        return AccountExecutiveRecord;
    }
    
    public static List<Account_Executive_Revenue__c> FilterAccountExecutive(List<Account_Executive_Revenue__c> unFilteredAccountExecutives, ID JobID)
    {
        List<Account_Executive_Revenue__c> FilteredAccountExecutive = new List<Account_Executive_Revenue__c>();
        for(Account_Executive_Revenue__c unFilteredAccountExecutive:unFilteredAccountExecutives)
        {
            if(JobID == unFilteredAccountExecutive.Job__c)
               FilteredAccountExecutive.add(unFilteredAccountExecutive);
        }
        return FilteredAccountExecutive;
    } 
     
    
    public static void UpdateForecastAccountExecutiveRecord(List<ATI_Job__c> Jobs)
    {
        List<Forecast__c> ForecastList = new List<Forecast__c>([SELECT ATI_Job__c,Id,Invoice_Date__c,Name,Revenue_Amount__c FROM Forecast__c where ATI_Job__c in: Jobs]);
        AccountExecutiveBillingForecastInsertHandler(ForecastList);
        
    }
    
    
    /* Billing Forecast Object Record Insert */
    
        public static Account_Executive_Revenue__c GetUpdatedForecastAccountExecutives(Account_Executive_Revenue__c AccountExecutiveRecord, ID AccountExecutive)
    {
        if(string.isnotblank(AccountExecutive))
        {
        	AccountExecutiveRecord.Account_Executive__c = AccountExecutive;
        	AccountExecutiveRecord.IsActive__c = true;
        }
        else
        {
            AccountExecutiveRecord.Account_Executive__c = null;
        	AccountExecutiveRecord.IsActive__c = false;
            
        }
        return AccountExecutiveRecord;
    }
    
     Public Static Set<id> GetJobsFromForecastObject(List<Forecast__c> billingforecasts)
    {
        Set<id> JobID =new Set<id>();
		List<Forecast__c> ForecastRecord = new List<Forecast__c>();
		ForecastRecord = [select ATI_Job__c from Forecast__c where id in:billingforecasts ];
        
        for(Forecast__c forecastrec :ForecastRecord)
        {
            JobID.add(forecastrec.ATI_Job__c);
        }
        return JobID;
    }
    
    Public Static ati_job__c GetJobFromList(List<ati_job__c> jobs, Id JobId)
    {
        ati_job__c job = new ati_job__c();
        
        for(ati_job__c jobrecord:jobs)
        {
            if(JobId == jobrecord.Id)
               job = jobrecord;
        }       
        return job;
    }
    
    public static List<Account_Executive_Revenue__c> FilterAccountExecutiveForForecast(List<Account_Executive_Revenue__c> unFilteredAccountExecutives, ID JobID, ID BillingForecastID)
    {
        List<Account_Executive_Revenue__c> FilteredAccountExecutive = new List<Account_Executive_Revenue__c>();
        for(Account_Executive_Revenue__c unFilteredAccountExecutive:unFilteredAccountExecutives)
        {
            if(JobID == unFilteredAccountExecutive.Job__c && BillingForecastID == unFilteredAccountExecutive.Billing_Forecast__c)
               FilteredAccountExecutive.add(unFilteredAccountExecutive);
        }
        return FilteredAccountExecutive;
    }
    
    Public static List<Account_Executive_Revenue__c> SeperateAccountExecutiveDeleteList(List<Account_Executive_Revenue__c> AccountExecutiveRevenueList)
    {
        List<Account_Executive_Revenue__c> SeperateAccountExecutiveDeleteList = new List<Account_Executive_Revenue__c>();
       
        for(Account_Executive_Revenue__c AccountExecutiveRevenueRecord: AccountExecutiveRevenueList)
        {
            Account_Executive_Revenue__c AccountExecutiveRevenueObject = new Account_Executive_Revenue__c();
            
            if(AccountExecutiveRevenueRecord.IsActive__c == false )                
            {
                AccountExecutiveRevenueObject.id = AccountExecutiveRevenueRecord.id;
                SeperateAccountExecutiveDeleteList.add(AccountExecutiveRevenueObject);
            }    
        }
        return SeperateAccountExecutiveDeleteList;
    }
    
        Public static List<Account_Executive_Revenue__c> SeperateAccountExecutiveUpdateList(List<Account_Executive_Revenue__c> AccountExecutiveRevenueList)
    {
        List<Account_Executive_Revenue__c> SeperateAccountExecutiveUpdateList = new List<Account_Executive_Revenue__c>();
       
        for(Account_Executive_Revenue__c AccountExecutiveRevenueRecord: AccountExecutiveRevenueList)
        {
            Account_Executive_Revenue__c AccountExecutiveRevenueObject = new Account_Executive_Revenue__c();
            
            if(AccountExecutiveRevenueRecord.IsActive__c == true )                
            {
                AccountExecutiveRevenueObject.id = AccountExecutiveRevenueRecord.id;
                AccountExecutiveRevenueObject.IsActive__c = true;
                SeperateAccountExecutiveUpdateList.add(AccountExecutiveRevenueObject);
            }
            
        }
        return SeperateAccountExecutiveUpdateList;
    }

    
    Public Static void AccountExecutiveBillingForecastInsertHandler(List<Forecast__c> billingforecasts){
        
        list<Account_Executive_Revenue__c> UpdatableAccountExecutiveList = new list<Account_Executive_Revenue__c>();
        list<Account_Executive_Revenue__c> InsertableAccountExecutiveList = new list<Account_Executive_Revenue__c>();
        list<Account_Executive_Revenue__c> DeletableAccountExecutiveList = new list<Account_Executive_Revenue__c>();
        Set<id> JobID = GetJobsFromForecastObject(billingforecasts);
        List<ati_job__c> JobList = new List<ati_job__c>([select id,Account_Executive_1__c,Account_Executive_2__c,Name,CreatedDate,Amount__c from Ati_job__c where id in:JobID]);
        list<Account_Executive_Revenue__c> AccountExecutiveList = new list<Account_Executive_Revenue__c>([SELECT Account_Executive__c,Id,IsActive__c,Job__c,Name,Billing_Forecast__c,Type__c FROM Account_Executive_Revenue__c where Job__c in: JobID]);
        boolean accountExecutive1IsInserted = false;
        boolean accountExecutive2IsInserted = false;
        
        for(Forecast__c billingforecastsrecord:billingforecasts)
        {
            List<Account_Executive_Revenue__c> ForecastBasedAccountExecutive = FilterAccountExecutiveForForecast(AccountExecutiveList, billingforecastsrecord.ATI_Job__c, billingforecastsrecord.Id);
            ati_job__c JobRecord = GetJobFromList(JobList, billingforecastsrecord.ATI_Job__c);
            accountExecutive1IsInserted = false;
        	accountExecutive2IsInserted = false;   
            for(Account_Executive_Revenue__c AccountExecutiveRecord: ForecastBasedAccountExecutive)
        	{
               if(AccountExecutiveRecord.Type__c == 'Account Executive 1')
               {
                   accountExecutive1IsInserted = true;
                   UpdatableAccountExecutiveList.add(GetUpdatedForecastAccountExecutives(AccountExecutiveRecord, JobRecord.Account_Executive_1__c));                  
               }
               else if(AccountExecutiveRecord.Type__c == 'Account Executive 2')
               {
                   accountExecutive2IsInserted = true;
                   UpdatableAccountExecutiveList.add(GetUpdatedForecastAccountExecutives(AccountExecutiveRecord, JobRecord.Account_Executive_2__c));
               } 
          
        	}
            
            
                if(!accountExecutive1IsInserted && string.isnotblank(jobRecord.Account_Executive_1__c))
           		InsertableAccountExecutiveList.add(GetInsertableBillingForecastAccountRevenueRecord(JobRecord.id,billingforecastsrecord.id,jobRecord.Name,jobRecord.Account_Executive_1__c,'Account Executive 1'));           
                if(!accountExecutive2IsInserted && string.isnotblank(jobRecord.Account_Executive_2__c))
            	InsertableAccountExecutiveList.add(GetInsertableBillingForecastAccountRevenueRecord(JobRecord.id,billingforecastsrecord.id,jobRecord.Name,jobRecord.Account_Executive_2__c,'Account Executive 2'));
        }
        
        List<Account_Executive_Revenue__c> DeleteAccountExecutiveRevenueList = new List<Account_Executive_Revenue__c>();
        List<Account_Executive_Revenue__c> UpdateAccountExecutiveRevenueList = new List<Account_Executive_Revenue__c>();
        
        DeleteAccountExecutiveRevenueList.addall(SeperateAccountExecutiveDeleteList(UpdatableAccountExecutiveList));
        UpdateAccountExecutiveRevenueList.addall(SeperateAccountExecutiveUpdateList(UpdatableAccountExecutiveList));
        
        system.debug(DeleteAccountExecutiveRevenueList);
        system.debug(UpdateAccountExecutiveRevenueList);
        
        
        if(DeleteAccountExecutiveRevenueList.size() > 0)
            delete DeleteAccountExecutiveRevenueList;
        if(UpdateAccountExecutiveRevenueList.size() > 0)
            update UpdateAccountExecutiveRevenueList;
        if(InsertableAccountExecutiveList.size() > 0)
            insert InsertableAccountExecutiveList;
              
    }
    
    public static Account_Executive_Revenue__c GetInsertableBillingForecastAccountRevenueRecord(ID Job,ID Forecast, String jobNumber, ID AccountExecutive,String AccountExecutiveName)
    {
        Account_Executive_Revenue__c AccountExecutiveRecord = new Account_Executive_Revenue__c();
        
        AccountExecutiveRecord.Name = AccountExecutiveRecord.Name = jobNumber + '|' + AccountExecutiveName;
        AccountExecutiveRecord.Job__c = Job;
        AccountExecutiveRecord.Type__c = AccountExecutiveName;
        AccountExecutiveRecord.IsActive__c = true;
        AccountExecutiveRecord.Account_Executive__c = AccountExecutive;
        AccountExecutiveRecord.Billing_Forecast__c = Forecast;        
   
        return AccountExecutiveRecord;        
    }
    
    /* Revenue Amount Calculation */
    
     public static List<Account_Executive_Revenue__c> FilterRevenueAccountExecutiveForForecast(List<Account_Executive_Revenue__c> unFilteredRevenueAccountExecutives, ID JobID, ID BillingForecastID)
    {
        List<Account_Executive_Revenue__c> FilteredRevenueAccountExecutive = new List<Account_Executive_Revenue__c>();
        for(Account_Executive_Revenue__c unFilteredRevenueAccountExecutive:unFilteredRevenueAccountExecutives)
        {
            if( JobID == unFilteredRevenueAccountExecutive.Job__c && BillingForecastID == unFilteredRevenueAccountExecutive.Billing_Forecast__c)
               FilteredRevenueAccountExecutive.add(unFilteredRevenueAccountExecutive);
        }
        system.debug(FilteredRevenueAccountExecutive);
        return FilteredRevenueAccountExecutive;       
    }
    
    
    public static void AccountExecutiveRevenueRecordDeletion(list<Forecast__c> CheckBillingForecastFieldInRecord)
    {
        List<Account_Executive_Revenue__c> DeleteAccountExecutiveRevenueRecord = [SELECT Billing_Forecast__c,Id,Name FROM Account_Executive_Revenue__c where  Billing_Forecast__c in:CheckBillingForecastFieldInRecord];
        if(!DeleteAccountExecutiveRevenueRecord.isEmpty())
            {
                delete DeleteAccountExecutiveRevenueRecord;
            }
    }
    
}