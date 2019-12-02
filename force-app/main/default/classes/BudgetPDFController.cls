/******************************************************************************
 * Extension for 
 */
public class BudgetPDFController{

    public static List<String> ADDL_FIELDS = new List<String> {
        'Name',
        'Current_PDF_Version__c',
        'Allocations__c',
        'X3_Program_Fees__c',
        'Estimated_Completion_Date__c',
        'Job__c',
        'Overhead__c',
        'Overhead_Allocations__c',
        'Profit__c',
        'Profit_Allocations__c',
        'Project_Manager__c',
        'Project_Director__c',
        'Regional_Manager__c',
        'Sales_Tax__c',
        'Overhead_Profit_Sales_Tax__c',
        'Sales_Tax_Allocations__c',
        'Start_Date__c',
        'Subtotal_Allocations__c',
        'Subtotal_Revenue__c',
        'Total_Actual_Costs__c',
        'Total_Allocations__c',
        'Total_Program_Fees_New__c',
        'Total_Gross_Profit__c',
        'Total_In_House_Total__c',
        'Total_Materials__c',
        'Total_Profit__c',
        'Total_Revenue__c',
        'Total_Subcontractor_bid__c',
        'ATI_Job__c',
         'BlankValue__c'
    };
    
    /** The budget to generate a PDF for */
    public Budget__c Budget {get; set;}
    
    public List<Budget_Line_Item__c> lineItems {get; set;}
        public Integer getLineItemsSize() {        return lineItems.size();
    }
    

    /**************************************************************************
     * 
     */
    public BudgetPDFController(ApexPages.StandardController controller) {
        
        // Add any additional fields
        if (! Test.isRunningTest()) {            controller.addFields(BudgetPDFController.ADDL_FIELDS);
        }
        
        // Initialize local variables
        Id budgetId = controller.getId();
        String fields = ADCUtil_Base.strJoin(',', ADDL_FIELDS, 'Id');
        budget = (Budget__c) Database.query('SELECT '+fields+' FROM Budget__c WHERE (Id = :budgetId) ORDER BY CreatedDate DESC LIMIT 1');
        
        // Retrieve all of the relevant line items
        lineItems = [SELECT  Id, Name, Actual_Costs__c, Allocations__c, Budget__c, Burden__c, Budget_Goal_Amount__c, Program_Fees__c, Estimated_Completion_Date__c, Gross_Profit__c, In_House_Hours__c, In_House_Rate__c, In_House_Total__c, Materials__c, Profit__c, Revenue__c, Start_Date__c, Budget_Goal__c, Subcontractor__c, Subcontractor_bid__c, Trade__c, Trade_Option__c FROM Budget_Line_Item__c WHERE Budget__c = :budget.Id order by CreatedDate ASC ];
        
        System.debug('BudgetPDFController: Generating budget for '+budget);
        
    }
    
    

    
}