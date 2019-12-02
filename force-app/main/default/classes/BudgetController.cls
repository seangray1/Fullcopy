/**
 * @File Name          : BudgetController.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/12/2019, 7:58:28 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/12/2019   Sean Gray     Initial Version
**/
public class BudgetController {

    public List<WrapperClass> wrapBudget{get;set;}
    public Integer count{get;set;}
    public List<Budget_Line_Item__c> delBudgetLineItem;
    public Budget__c BudgetRecord;
    public String job{get;set;}
    ApexPages.StandardController ExtCon;
    
        //These are the values will auto populate on the first 10 lines
    public static List<String> FirstTenValues = new List<String>{
        'APP Appliances',
		'CAB Cabinetry',
		'CLN Cleaning',
		'CON Contents',
		'DMO General Demolition',
		'DOR Doors',
		'DRY Drywall',
		'ELE Electrical',
		'FCC Floor Covering Carpet',
		'FCW Floor Covering Wood',
		'FNC Finish Carpentry',
		'FRM Framing & Rough Carpentry',
		'HVC Heat, Vent, & Air Conditioning',
		'INS Insulation',
		'PLM Plumbing',
		'PNT Painting',
		'RFG Roofing',
		'SDG Siding',
		'WDV Window Vinyl'
    };
    
    public BudgetController(ApexPages.StandardController controller) {
         this.ExtCon = controller;
         BudgetRecord = (Budget__c)controller.getRecord();        
         getBudgetLineItem();
         //job = BudgetRecord.Job__c;  //Commented for Job Re-design
         job = BudgetRecord.ATI_Job__c;
         delBudgetLineItem = new List<Budget_Line_Item__c>();  
    }
    
    public void getBudgetLineItem(){     
         wrapBudget = new List<WrapperClass>();
         Integer listCount = 0;
         decimal AllocationCount = 0.0;
         decimal BudgetGoalCount = 0.0;
         decimal TotalFees = 0.0;
         decimal Revenuecount = 0.0;
         ID BudgetID = ExtCon.getID();
         
         system.debug('This is the Id Reurning: ' + BudgetID);
        
         //Query records if page returns an Id         
         for(Budget_Line_Item__c budgetline:[Select id, Actual_Costs__c, Allocations__c, X10_10_Allocation__c, Burden__c, Program_Fees__c, Estimated_Completion_Date__c, 
                                             Gross_Profit__c, In_House_Hours__c, In_House_Rate__c, In_House_Total__c, Materials__c, Profit__c, Revenue__c, Start_Date__c,
                                                Budget_Goal__c, Subcontractor__c, Subcontractor_bid__c, Trade__c, Trade_Option__c, OrderNumber__c,
                                             Allocation_Percentage__c, Allocation_Overhead__c From Budget_Line_Item__c  
                                         WHERE Budget__c =:budgetID ORDER BY OrderNumber__c])
         {
             WrapperClass wrapbudgetlineineItem = new WrapperClass(listCount ,budgetline);
             wrapBudget.add(wrapbudgetlineineItem);
             listCount = listCount + 1;
             AllocationCount = AllocationCount + budgetline.Allocations__c;
             BudgetGoalCount = BudgetGoalCount + budgetline.Budget_Goal__c;
             TotalFees = totalFees + budgetline.Program_Fees__c;
             //BudgetRecord.Subtotal_Allocations__c = allocationCount;
             //BudgetRecord.Total_Budget_Goal__c = BudgetGoalCount; 
             //BudgetRecord.Total_Program_Fees__c = TotalFees;
             
             //If the 10/10 checked, sum up the revenue
             if(budgetline.X10_10_Allocation__c == true && budgetline.Revenue__c != null)
                 Revenuecount = Revenuecount + budgetline.Revenue__c;   
              BudgetRecord.overhead__c = Revenuecount * Budgetline.Allocation_Percentage__c;
         BudgetRecord.profit__c = RevenueCount * Budgetline.Allocation_Percentage__c;
        //  if(budgetRecord.Overhead_Profit_Sales_Tax__c = True && BudgetRecord.Sales_Tax__c > 0){
        //      BudgetRecord.Sales_Tax_Percent__c = (BudgetRecord.Sales_Tax__c * (Budgetline.Allocation_Percentage__c * 2)) + BudgetRecord.Sales_Tax__c;
        //     //BudgetRecord.Sales_Tax_with_Overhead__c(BudgetRecord.Sales_Tax__c * BudgetRecord.Allocation_Percentage__c) * 2)- (Sales_Tax__c*2),
        //  }
         }
         
         //calculate the overhead profit
        
        
         //For Creation of new budget...wrapBudget will be empty since query returned no results
         //New budget must contain 3 empty line items
         if(wrapBudget.isEmpty()==true){
             wrapBudget = new List<WrapperClass>();
             createLineItem();
         }
    }

    //Create 3 empty budget Line Items
    public void createLineItem(){       
        integer i;
        for(i = 0;i<19;i++){
             Budget_Line_Item__c Budget = new Budget_Line_Item__c();
             budget.Trade__c = FirstTenValues[i];
             budget.Trade__c = budget.Trade__c.Substring(3);
             Budget.Trade_Option__c = FirstTenValues[i];
             WrapperClass wc = new WrapperClass(i,Budget);
             wc.Budget.OrderNumber__c = i+1;
             WrapBudget.add(wc);
        }
    }
     //Method for delete button of the VF page...add deleted items to temporary list(delInvoiceLineItems)
    //temp list will be used to delete records once user hits save
    public void deleteLineItem(){
        //delBudgetLineItem = new List<Budget_Line_Item__c>();
        system.debug('This is the delete List :' + delBudgetLineItem);
        if(wrapBudget.size()>0){
            for(integer i=0;i<wrapBudget.size();i++){ 
                if(count==wrapBudget[i].indx){
                    if(wrapBudget[i].budget.id!=null){
                    delBudgetLineItem.add(wrapBudget[i].budget);
                    }
                    wrapBudget.remove(i);
                }
                resetLineItemOrder();
            }
          if(wrapBudget.size()==0){
              createLineItem();
          }
        }
    }
    //reset order of Line items...Line Items must always start at 1
    public void resetLineItemOrder(){
        for(integer i=0;i<wrapBudget.size();i++){
            wrapBudget[i].Budget.OrderNumber__c = i+1;
        }

    }
    
    //Method for adding empty line items to pageblocktable 
    public void addLineItem(){
        Budget_Line_Item__c budget = new Budget_Line_Item__c();
        budget.X10_10_Allocation__c = true;
        WrapperClass wc = new WrapperClass(WrapBudget.size()+1,budget);
        WrapBudget.add(wc);
        resetLineItemOrder();

    }    

    
    public PageReference quickSaveBudget(){   
        
        PageReference pv;
        
        try{
              ExtCon.save();
              
              saveLineItem(ExtCon.getID());
              getBudgetLineItem();
              
              // Replicate 2nd click save
             ExtCon.save();
              
              //ExtCon.save();
              //BudgetRecord = (Budget__c)this.ExtCon.getRecord();


            system.debug('What is the pv returning? '+ pv);
            
            
        }catch(Exception e){
            ApexPages.Message emsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());    
            ApexPages.addMessage(emsg);
        }        
        
        //return pv;
        return null;
    }
    
    public pageReference saveBudget(){
     
        PageReference pv;
        
        try{
            
            ExtCon.save();
            saveLineItem(ExtCon.getID());
            getBudgetLineItem();
            //ExtCon.save();
            //BudgetRecord = (Budget__c)this.ExtCon.getRecord();
            
                
            system.debug('What is the pv returning? '+ pv);
            
        } catch(exception e){
            ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(ErrorMsg);
        }
        
        pv = ExtCon.view();
       
        return pv;
    }
    
    public void saveLineItem(ID budgetID){ 
    
        List<Budget_Line_Item__c> saveBudgetLineItem = new List<Budget_Line_Item__c>();
    
        //try{
        for(WrapperClass wc:wrapBudget){
           if(wc.budget.Trade__c != null && wc.budget.Trade__c != ''){
                if(wc.budget.id==null){
                    wc.budget.Budget__c = budgetID;
                 
                } 
    
                saveBudgetLineItem.add(wc.budget);
            } 
    
        } 
        
        upsert saveBudgetLineItem;
        
        if(delBudgetLineItem!=null){
           // system.debug('This is the delete List :' + delBudgetLineItem);
           delete delBudgetLineItem;
        }
        //delBudgetLineItem=null;
        
        // REFRESH THE LINE ITEMS HERE
        BudgetRecord = (Budget__c)this.ExtCon.getRecord(); 


    }
     
    public class WrapperClass{
        public Integer indx{get;set;}
        public Budget_Line_Item__c budget{get;set;}    
        public WrapperClass(Integer indx,Budget_Line_Item__c budget){
            this.indx = indx;
            this.budget = budget;
        }
    
    }
    
}