/******************************************************************************
 * Extension for 
 */
public with sharing class InvoicePDFController {
    
    /** List of Invoice__c fields that do not exist on the VF page that need to
     *  be referenced elsewhere in the code */
    public static List<String> ADDL_FIELDS = new List<String> {
        'Id',
        'Bill_To__c',
        'Bill_To__r.Name',
        'Bill_To__r.Timberline_Customer_Number__c',
        'Bill_To__r.IsPersonAccount', //Delano Johnson (Perficient) added 9/28/2015
        'Bill_To_Address__c',
        'Bill_To_Address_Formula__c',//Rashmi Kalegowda(Perficient) added 2/24/2016
        'Delivery_Method__c', //Rashmi Kalegowda(Perficient) added 4/24/2016
        'Bill_To_Attention__c',
        'Omit_Bill_To__c', //Rashmi Kalegowda(Perficient) added 5/2/2016
        'Bill_To_Attention_Line_2__c',//Rashmi Kalegowda(Perficient) added 5/2/2016
        'Bill_To_Attention_Lookup__c', //Delano Johnson (Perficient) added 9/17/2015
        'Bill_To_Attention_Lookup__r.FirstName', //Delano Johnson (Perficient) added 9/17/2015
        'Bill_To_Attention_Lookup__r.LastName', //Delano Johnson (Perficient) added 9/17/2015
        'Bill_to_City__c',
        'Bill_to_State__c',
        'Bill_to_Zip__c',
        'Bill_To_Address3__r.Name',
        'Care_of_Address_lookup__r.Name',
        'CC_Address_Care_of_lookup__r.Name',
        'CC_CareOf__c',
        'CC_Address_Care_of_Formula__c',//Rashmi Kalegowda(Perficient) added 2/24/2016
        'CC_Address_Lookup__r.Name',
        'CC_Account__c',
        'CC_Account__r.Name',
        'CC_Company__c',
        'CC_Address__c',
        'CC_Address_Formula__c',//Rashmi Kalegowda(Perficient) added 2/24/2016
        'CC_Attention__c',
        'CC_City__c',
        'CC_State__c',
        'CC_Zip__c',
        'Current_PDF_Version__c',
        'Due_Date__c',
        'Federal_Id__c',
        'Internal__c',
        'Is_Dummy_Invoice__c',
        'Status__c',
        'Care_of_Address__c',
        'Care_of_Address_Formula__c',//Rashmi Kalegowda(Perficient) added 2/24/2016
        'Care_Of__c',
        'Care_Of__r.Name',
        'Care_Of_Address1__c',
        /**
            COMPANY: CLOUD SHERPAS
            EDITED BY: LENNARD PAUL SANTOS
            DESCRIPTION: ADDED Job Name and Total Credits Field
        **/
        'ATI_Job__r.Job_Name__c',
        'Total_Credits__c',
        'ATI_Job__r.Project_Site_Name__c',
        'ATI_Job__r.Project_Site_Contact_Name__c',
        'ATI_Job__r.Project_Site_Contact_Name__r.Name',
        'ATI_Job__r.Project_Site_Address__c',
        'ATI_Job__r.Project_Site_Address_2__c',
        'ATI_Job__r.Project_Site_City__c',
        'ATI_Job__r.Project_Site_State__c',
        'ATI_Job__r.Project_Site_Zipcode__c',
        'ATI_Job__r.Customer__c',
        'ATI_Job__r.Customer__r.AccountId',
        'ATI_Job__r.Customer__r.Account.Timberline_Customer_Number__c',
        'ATI_Job__r.Account__c',
        'ATI_Job__r.Account__r.Timberline_Customer_Number__c',
        'ATI_Job__r.Job_Number__c',
        'Name',
        'Net_Due__c',
        'Project_Manager__c',
        'Reference_Number__c',
        'Retainage_Held__c',
        'Superintedent__c',
        'Superintedent__r.Name',
        'Total_Costs_Per_Contract__c',
        'Total_Tax__c',
        'LastModifiedDate',
        /**
            EDITED BY: Semira Roy
            DESCRIPTION: ADDED New Checkboxed
        **/
        'Work_authorization_sent_to_adjuster__c',
        'Scope_sent_approved_by_adjuster__c',
        'Customer_satisfaction_obtained__c',
        'Customer_satisfaction_sent_delivered__c',
        'Send_authorization_with_invoice__c',
        'Send_invoice_to_customer_insurance__c',
        'Send_scope_contract_with_invoice__c',
        'Due_Date_new__c'

    };    //I removed 'Project_Manager__r.Name', from above {} - Semira
    
    /** The invoice to generate a PDF for */
    public Invoice__c invoice {get; set;}
    
    public List<Invoice_Line_Item__c> lineItems {get; set;}
    
    public Integer getLineItemsSize() {
        return lineItems.size();
    }
    
    /** Data structure of page parameters */
    public Parameters params {get; set;} 
    
    public String billToFormatted {get; set;}
    
    public String jobLocationFormatted {get; set;}
    
    public String ccFormatted {get; set;}
    
    public String neg {get;set;}
    
    /**************************************************************************
     * 
     */
    public InvoicePDFController(ApexPages.StandardController controller) {
        
        // Add any additional fields
        if (! Test.isRunningTest()) {
            controller.addFields(InvoicePDFController.ADDL_FIELDS);
        }
        
        // Initialize local variables
        Id invoiceId = controller.getId();
        System.Debug('Id:' + invoiceId);
        
        String fields = ADCUtil_Base.strJoin(',', ADDL_FIELDS, 'Id');
        invoice = (Invoice__c) Database.query('SELECT '+fields+' FROM Invoice__c WHERE (Id = :invoiceId) ORDER BY LastModifiedDate DESC LIMIT 1');
        params  = new Parameters();
        neg = '';
        if(invoice.Retainage_Held__c!=null){
            neg = '-';
        }
        
        // Retrieve all of the relevant line items
        lineItems = [SELECT Id, Name, Description__c, Amount__c,Note__c,IsCredit__c FROM Invoice_Line_Item__c WHERE Invoice__c = :invoice.Id  and IsCredit__c = false order by Order__c ASC ];
        
        System.debug('InvoicePDFController: Generating invoice for '+invoice);
        
    }
    
    
    
    /**************************************************************************
     * 
     */
    public class Parameters extends ADCUtil_Params {
        
        public String pDisplayLetterhead = 'dlh';
        
        public boolean displayLetterhead {get; set;}
        
        public Parameters() {
            super();
        }
        
        protected override void load(Map<String, String> source) {
            displayLetterhead = getBoolean(source, pDisplayLetterhead);
            System.debug('InvoicePDFController.Parameters.load: displayLetterhead:'+displayLetterhead);
        }
        
        protected override void dump(Map<String, String> target) {
            putBoolean(target, pDisplayLetterhead, displayLetterhead);
        }
        
    }
    
    
    
    
    @IsTest(SeeAllData=true)
    private static void test_init() {
        
        String fields = ADCUtil_Base.strJoin(',', ADDL_FIELDS, 'Id');
        Invoice__c r = (Invoice__c) Database.query('SELECT '+fields+' FROM Invoice__c ORDER BY LastModifiedDate DESC LIMIT 1');
        system.debug(r);
        PageReference ref = Page.InvoicePDF;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        InvoicePDFController controller = new InvoicePDFController(std);
        
        ref = Page.InvoicePDF;
        ref.getParameters().put('dlh', '1');
        Test.setCurrentPage(ref);
        controller = new InvoicePDFController(std);
        
        Test.stopTest();
        
    }
    
}