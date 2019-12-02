/******************************************************************************
 * Extension for 
 */
public class ExpensePDFController{
    
    /** List of Expense__c fields that do not exist on the VF page that need to
     *  be referenced elsewhere in the code */
    public static List<String> ADDL_FIELDS = new List<String> {
         'Name',
        'Amount__c',
        'Approved_Date__c',
        'Approved_by__c',
        'Count_Line_Items__c',
        'Date__c',
        'Date_Submitted__c',
        'Status__c',
        'Total_Amount__c'
    };
    
    /** The expense to generate a PDF for */
    public Expense__c expense {get; set;}
    
    public List<Expense_Line_Item__c> lineItems {get; set;}
        public Integer getLineItemsSize() {        return lineItems.size();
    }
    

    /**************************************************************************
     * 
     */
    public ExpensePDFController(ApexPages.StandardController controller) {
        
        // Add any additional fields
        if (! Test.isRunningTest()) {            controller.addFields(ExpensePDFController.ADDL_FIELDS);
        }
        
        // Initialize local variables
        Id expenseId = controller.getId();
        String fields = ADCUtil_Base.strJoin(',', ADDL_FIELDS, 'Id');
        expense = (Expense__c) Database.query('SELECT '+fields+' FROM Expense__c WHERE (Id = :expenseId) ORDER BY LastModifiedDate DESC LIMIT 1');
        
        // Retrieve all of the relevant line items
        lineItems = [SELECT  Id, Name, Serial_Number__c, Number_of_item__c, Amount__c, Code__c, Payee__c, Contact__c, Office__c, ATI_job__c, Date_of_Expense__c FROM Expense_Line_Item__c WHERE Expense__c = :expense.Id order by Serial_Number__c ASC ];
        
        System.debug('ExpensePDFController: Generating expense for '+expense);
        
    }
    
    
    
    /**************************************************************************
     * 
     */

    @IsTest(SeeAllData=true)
    private static void test_init() {
        
        Expense__c expense = new Expense__C(Name = 'test', Date__c = system.today());
        insert expense;
        
        
        String fields = ADCUtil_Base.strJoin(',', ADDL_FIELDS, 'expense.Id');
        Expense__c r = (Expense__c) Database.query('SELECT '+fields+' FROM Expense__c Order by LastModifiedDate ASC LIMIT 1');
        system.assert(r != null);
        
        PageReference ref = Page.ExpensePDF;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        ExpensePDFController controller = new ExpensePDFController(std);
        
        
        Test.stopTest();
        
    }
    
}