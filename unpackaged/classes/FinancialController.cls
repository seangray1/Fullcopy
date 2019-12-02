public with sharing class FinancialController
{    
    public string ATI_Job_Id{get;set;}
    public Id  RecID;
    public boolean editSection {get;set;}
    public Financial__c Finance_Record {get;set;}
    public FinancialController(ApexPages.StandardController controller)
     {
       ATI_Job_Id = ApexPages.CurrentPage().getparameters().get('id'); 
       //system.debug('ATI_Job_Id--'+ATI_Job_Id);
       Finance_Record = [SELECT ATI_Job__c,
                                Id,
                                Job_to_Date_Work_Billed__c, 
                                Quarter_to_Date_Work_Billed__c,
                                Job_to_Date_Costs__c,
                                Quarter_to_Date_Costs__c,
                                JTD_Profit__c,
                                Quarter_to_Date_GP__c,
                                Job_to_Date_GP_Percent__c, 
                                Quarter_to_Date_GP_Percent__c,
                                
                                Job_to_Date_Work_Billed_Next_Month__c,
                                Month_to_Date_Work_Billed__c,
                                Job_to_Date_Costs_Next_Month_Costs__c,
                                Month_to_Date_Costs__c,
                                JTD_NM_Profit__c,
                                Month_to_Date_GP__c,
                                JTD_NM_GP__c,
                                Month_to_Date_GP_Percent__c,
                                
                                Year_to_Date_Work_Billed__c,
                                Next_Month_Work_Billed__c,
                                Year_to_Date_Costs__c,
                                Next_Month_Costs__c,
                                Year_to_Date_GP__c,
                                Year_to_Date_GP_Percent__c,
                                
                                
                                Total_Billing_Forecast_Amount__c,
                                Amount_not_billed__c,
                                Year_to_Date_Work_Billed_Next_Month__c,
                                Year_to_Date_Costs_Next_Month_Cost__c,
                                Gross_Profit__c,
                                Year_to_Date_NM_GP__c,
                                Year_to_Date_NM_GP_Percent__c,
                                Last_Successful_Timberline_Forecast_Sync__c,
                                Forecast_Last_Timberline_Update__c,
                                Update_Forecast__c,
                                Receivable_Includes_Retention__c,
                                Receivable_Balance__c,
                                Retention_Receivable__c,
                                
                // Not in Financial Detail Section                    
                                Job_to_Date_Adjustments__c,
                                Actual_Gross_Profit_JTD_NM__c,
                                Estimate_Amount_JTD_worked_billed__c,
                                Forecast_Analysis_match__c,
                                GP_Adj__c,
                                JC_Adjustment__c,
                                Job_to_Date_Dollars_Paid__c,
                                Job_to_Date_Payments__c,
                                JTD_Costs_YTD_Costs__c,
                                Last_Month_Costs__c,
                                Last_Month_Dollars_Paid__c,
                                Last_Month_Work_Billed__c,
                                Month_to_Date_Dollars_Paid__c,
                                MTD_Profit__c,
                                Next_Month_Dollars_Paid__c,
                                Quarter_to_Date_Dollars_Paid__c,
                                Timberline_GPM__c, 
                                Year_to_Date_Dollars_Paid__c,
                                YTD_Billing_Forecast__c,YTD_GP__c
                         
                         FROM Financial__c WHERE ATI_Job__c =: ATI_Job_Id];       
    }
            
    public void saveChanges() 
     {
        update Finance_Record;
     }
  
    public PageReference EdittheSection()
     {
        editSection = true;
        if(Finance_Record.ATI_Job__c == ATI_Job_Id)
        RecID= Finance_Record.id; 
          if(editSection!=null)
           {
             Pagereference newpage = new Pagereference ('/lightning/r/Financial__c/'+RecID+'/edit');
             return newpage;           
           }
             return null;
      }
       
}