public class BudgetCloneController {

    public Budget__c BudgetRecord;
    public String job{get;set;}
    ApexPages.StandardController ExtCon;
  
    public BudgetCloneController(ApexPages.StandardController controller) {
         this.ExtCon = controller;
         BudgetRecord = (Budget__c)controller.getRecord();        
         job = BudgetRecord.ATI_Job__c;          
    }

    public void cloneLineItem(ID budgetId, ID oldBudget){

         System.debug('this is inside the clone method');
        // copy over the line items - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
         List<Budget_Line_Item__c> items = new List<Budget_Line_Item__c>();
         
         integer count = 0;
         
         //Query the old lineitems
         //clone each line item
         //assign them the new ID
         //add them to the list
         for (Budget_Line_Item__c LI : [Select Id, Name, Actual_Costs__c, Allocations__c, Budget__c, Burden__c, Program_Fees__c, Estimated_Completion_Date__c, Gross_Profit__c, 
                                         In_House_Hours__c, In_House_Rate__c, In_House_Total__c, Materials__c, Profit__c, Revenue__c, Start_Date__c, Budget_Goal__c, Subcontractor__c, Subcontractor_bid__c, 
                                             Trade__c, Trade_Option__c, OrderNumber__c FROM Budget_Line_Item__c WHERE Budget__c = :oldBudget]) {  
              Budget_Line_Item__c newLI = LI.clone(false);
              newLI.Budget__c = budgetId;
              
             items.add(newLI);
         }

       insert items; 
       

    }
    
    public PageReference saveBudget(){   
        
        PageReference pv;
        ID OldBudgetID = ExtCon.getID();
        
        ExtCon.save();
        
        try{
                   
            // Check if it is Save or Clone.
            // If CLone the execute clone line item
           // Then redirect to new budget ID.  
            
            if(OldBudgetID != ExtCon.getID()){
            
                cloneLineItem(ExtCon.getID(), OldBudgetID);     
                
                BudgetRecord = (Budget__c)this.ExtCon.getRecord();
                Budget__c newBudgetRecord = [select id from Budget__c where id=:ExtCon.getID()];
                
                pv = new Pagereference('/'+ExtCon.getID()+'/e');
            }

        }catch(Exception e){
            ApexPages.Message emsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());    
            ApexPages.addMessage(emsg);
        }        
        
        //pv.getParameters().put('id', ExtCon.getID());
        //return pv.setRedirect(true);
        return pv;
    }
    
   
}