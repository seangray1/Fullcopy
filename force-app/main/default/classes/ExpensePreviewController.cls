public with sharing class ExpensePreviewController {
    
    /** List of Expense__c fields that do not exist on the VF page that need to
     *  be referenced elsewhere in the code */
    public static List<String> ADDL_FIELDS = ExpensePDFController.ADDL_FIELDS;
    
    /** The expense to generate a PDF for */
    public Expense__c expense {get; set;}
    
    /** The version of the next PDF generated */
    //public Integer pdfVersion {get; set;}
    
    /** The date that will be used for the generated PDF */
    public String pdfVersionDate {get; set;}
    
    /** The form used on the PDF preview page */
    public GeneratePDFForm formGeneratePDF {get; set;}
    
    public String filenameWithLetterhead {get; set;}
    
    //public String filenameWithoutLetterhead {get; set;}
    
    /**************************************************************************
     * 
     */
    public ExpensePreviewController(ApexPages.StandardController controller) {
        
        // Add any additional fields
        if (! Test.isRunningTest()) {
            controller.addFields(ExpensePDFController.ADDL_FIELDS);
        }
        
        // Initialize local variables
        expense = (Expense__c) controller.getRecord();
        formGeneratePDF = new GeneratePDFForm(this);
        
        
        // Normalize the current date to a string
        pdfVersionDate = Date.today().format();
        
        // Get the proposed file names
        initFileNames();
        
    }
    
    
    public void initFileNames() {
        
        // The following parameters will be available
        // {0} - expense name
        // {1} - expense Version
        // {2} - expense Date
        // {3} - Final expense string
        // {4} - No letterhead string
        String fileNameTemplateWLH = '{0}_{1}.pdf';
        
        
        List<String> formatParams = new List<String> {
            expense.Name,
            pdfVersionDate
        };
        
        filenameWithLetterhead = String.format(fileNameTemplateWLH, formatParams);
          
        return;
        
    }
    
    
    /**************************************************************************
     * Function used to generate and attach PDFs to the original expense
     */
    public void attachPDFs() {
        
        PageReference pdfDLPageRef;
        String pdfDLUrl;
        Attachment pdfAttachment;
        List<Attachment> pdfAttachments = new List<Attachment>();
        
        String userSessionId = UserInfo.getSessionId();
        System.debug('ExpensePreviewController.attachPDFs: User session ID: '+userSessionId);
        
        // ***** PDF WITH LETTERHEAD *****
        // Determine Download URL
        pdfDLPageRef = Page.ExpensePDF;                             //This should be my page name
        pdfDLPageRef.getParameters().put('id', expense.Id);
        pdfDLUrl = pdfDLPageRef.getUrl();
        
        System.debug('Downloading PDF WITH Letterhead from "'+pdfDLUrl+'"');
        
        // Set up PDF attachment
        pdfAttachment = httpGetAsAttachment(pdfDLUrl);
        pdfAttachment.Name = filenameWithLetterhead;
        pdfAttachment.ParentId = expense.Id;                  //Parent ID
        
        // Remember attachment to be inserted later
        pdfAttachments.add(pdfAttachment);
        
        // ***** INSERT ATTACHMENTS *****
        insert pdfAttachments;
  
    }
    
    
    /**************************************************************************
     * Generates a new attachment based on the given URL, assuming standard
     * headers and a get request.  The attachment will contain the response of
     * the HTTP request as the body and will require that the caller set all
     * other attachment parameters (such as name and parent ID)
     */
    public Attachment httpGetAsAttachment(String getUrl) {
        
        // If the URL starts with a /, assume it is a relative path and needs
        // to be pre-pended with the base salesforce URL
        getUrl = URL.getSalesforceBaseUrl().toExternalForm() + getUrl;
        
        // Generate the new attachment
        Attachment a = new Attachment();
        
        // Make an HTTP request that handles 302s
        HttpResponse res = ExpensePreviewController.makeRequest(getUrl, 10, null);
        
        // Update the attachment body based on the HTTP request
        a.Body = res.getBodyAsBlob();
        a.ContentType = res.getHeader('Content-Type');
        return a;
        
    }
    
    
    
    /**************************************************************************
     * Basic function which will perform an HTTP get request, properly
     * following 302 responses generetade by Salesforce.
     *
     * @param cookies
     *        A list of cookies.  This is used primarily to handle issues with
     *        a 302 redirect providing cookies which then must be provided
     *        back on the redirect attempt.  It is only used for recursive
     *        calls to this function and may be left blank
     */
    public static HttpResponse makeRequest(String getURL, Integer nRedirectsAllowed, List<Cookie> cookies) {
        
        // If we are in an infinite redirect loop
        if (nRedirectsAllowed < 0) {
            System.debug(Logginglevel.ERROR, 'ExpensePreviewController.makeRequest: Reached redirect limit.  Returning null which will likely cause a Null Pointer Exception.');
            return null;
        }
        
        // Generate empty set of cookies
        if (cookies == null) {
            cookies = new List<Cookie>();
        }
        
        System.debug('ExpensePreviewController.makeRequest: ('+nRedirectsAllowed+' redirects allowed) Requesting data from URL: '+getUrl);
        
        // Set up the HTTP get request
        Http h = new Http();
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getUrl);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());
        
        // Make the HTTP request
        HttpResponse res = h.send(req);
        
        // Debug output information about the response
        System.debug('ExpensePreviewController.makeRequest: Response received!');
        System.debug('ExpensePreviewController.makeRequest: Response.Code: '+res.getStatusCode());
        for (String hdr : res.getHeaderKeys()) {
            if (hdr != null) {
                System.debug('ExpensePreviewController.makeRequest: Response.Header.'+hdr+': '+res.getHeader(hdr));
            }
        }
        System.debug('ExpensePreviewController.makeRequest: Response.Body: '+res.getBody());
        
        // If the response is a 302, attempt a redirect
        if (res.getStatusCode() == 302) {
            System.debug('ExpensePreviewController.makeRequest: 302 response received from server.  Attempting a redirect...');
            return ExpensePreviewController.makeRequest(res.getHeader('Location'), nRedirectsAllowed-1, cookies);
        }
        
        // A proper response was received.  Return it to the caller.
        return res;
        
    }
    
    
    
    public class GeneratePDFForm {
        
        private ExpensePreviewController controller;
        
        public GeneratePDFForm(ExpensePreviewController parentController) {
            controller = parentController;
        }
        
        public PageReference savePDF() {
            
            System.debug('ExpensePDFController.GeneratePDFForm.save: Method called');
            
            // Save needs to generate PDFs for the page
            try {
                
                // Generate and attach PDFs
                controller.attachPDFs();
                System.debug('ExpensePDFController.GeneratePDFForm.save: PDFs attached.  Returning to expense detail page.');
                
                // If the attachment succeeded, return to the expense
                PageReference redir = new PageReference('/'+controller.expense.Id);
                redir.setRedirect(true);
                return redir;
                
            }catch(Exception e){
                
                // Display errors on the page
                System.debug(Logginglevel.ERROR, 'ExpensePDFController.GeneratePDFForm.save: An exception was thrown: '+e.getMessage()+'\n'+e.getStackTraceString());
                ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(ErrorMsg);
                return null;
            }
            
//            return null;
            
        }
        
        public PageReference cancelPDF() {
            
            System.debug('ExpensePDFController.GeneratePDFForm.cancel: Method called');
            
            // Cancelling returns to the expense page
            PageReference redir = new PageReference('/'+controller.expense.Id);
            redir.setRedirect(true);
            return redir;
            
        }
        
        
    }
    
    /*************
    
    private static testmethod void test_cancelPDF() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TriggerStatus__c tStat = new TriggerStatus__c(
            AccountGenerateCustomerNumber__c = true,
            AccountSyncToTimberline__c = true,
            Forecast_Sync_to_Timberline__c = true,
            expenseAutomaticexpenseNumber__c = true,
            expenseSyncToTimberline__c= true,
            expenseLineItemAutoCreation__c= true,
            expenseLineItemAutomaticNaming__c= true,
            expenseLineItemAutomaticOrder__c= true,
            expenseTaxGroupSetUp__c= true,
            JobCopyPMToOwner__c= true,
            JobOpportunitySync__c= true,
            JobSetJobNumber__c= true,
            JobSyncToTimberline__c= true,
            LeadPMLeadSync__c= true,
            OpportunityJobSync__c= true,
            PMLeadCalculateJobNumber__c= true,
            PMLeadConversion__c= true,
            PMLeadLeadSync__c= true,
            TaskTaskSync__c= true,
            TaxGroupRefreshFromTimberline__c= true,
            TaxGroupSetName__c= true
        );
        insert tStat; 
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'TestBCountry',
            BillingState = 'TestBState',
            BillingStreet = 'TestBStreet',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acct;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            Account = acct,
            Phone = '1234'
        );    
        insert con;
        
        Expense__c inv = new Expense__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', ExpensePDFController.ADDL_FIELDS, 'Id');
        Expense__c r = (Expense__c) Database.query('SELECT '+fields+' FROM Expense__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        ExpensePreviewController controller = new ExpensePreviewController(std);
        controller.formGeneratePDF.cancelPDF();            
        Test.stopTest();        
    }
    
    // Fail case
    private static testmethod void test_savePDF_withoutMockCallout() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TriggerStatus__c tStat = new TriggerStatus__c(
            AccountGenerateCustomerNumber__c = true,
            AccountSyncToTimberline__c = true,
            Forecast_Sync_to_Timberline__c = true,
            expenseAutomaticexpenseNumber__c = true,
            expenseSyncToTimberline__c= true,
            expenseLineItemAutoCreation__c= true,
            expenseLineItemAutomaticNaming__c= true,
            expenseLineItemAutomaticOrder__c= true,
            expenseTaxGroupSetUp__c= true,
            JobCopyPMToOwner__c= true,
            JobOpportunitySync__c= true,
            JobSetJobNumber__c= true,
            JobSyncToTimberline__c= true,
            LeadPMLeadSync__c= true,
            OpportunityJobSync__c= true,
            PMLeadCalculateJobNumber__c= true,
            PMLeadConversion__c= true,
            PMLeadLeadSync__c= true,
            TaskTaskSync__c= true,
            TaxGroupRefreshFromTimberline__c= true,
            TaxGroupSetName__c= true
        );
        insert tStat; 
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'TestBCountry',
            BillingState = 'TestBState',
            BillingStreet = 'TestBStreet',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acct;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            Account = acct,
            Phone = '1234'
        );    
        insert con;
        
        Expense__c inv = new Expense__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', ExpensePDFController.ADDL_FIELDS, 'Id');
        Expense__c r = (Expense__c) Database.query('SELECT '+fields+' FROM Expense__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        ExpensePreviewController controller = new ExpensePreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();        
    }
    
    // Success case
    private static testmethod void test_savePDF_withMockCallout() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TriggerStatus__c tStat = new TriggerStatus__c(
            AccountGenerateCustomerNumber__c = true,
            AccountSyncToTimberline__c = true,
            Forecast_Sync_to_Timberline__c = true,
            expenseAutomaticexpenseNumber__c = true,
            expenseSyncToTimberline__c= true,
            expenseLineItemAutoCreation__c= true,
            expenseLineItemAutomaticNaming__c= true,
            expenseLineItemAutomaticOrder__c= true,
            expenseTaxGroupSetUp__c= true,
            JobCopyPMToOwner__c= true,
            JobOpportunitySync__c= true,
            JobSetJobNumber__c= true,
            JobSyncToTimberline__c= true,
            LeadPMLeadSync__c= true,
            OpportunityJobSync__c= true,
            PMLeadCalculateJobNumber__c= true,
            PMLeadConversion__c= true,
            PMLeadLeadSync__c= true,
            TaskTaskSync__c= true,
            TaxGroupRefreshFromTimberline__c= true,
            TaxGroupSetName__c= true
        );
        insert tStat; 
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'TestBCountry',
            BillingState = 'TestBState',
            BillingStreet = 'TestBStreet',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acct;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            Account = acct,
            Phone = '1234'
        );    
        insert con;
        
        Expense__c inv = new Expense__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', ExpensePDFController.ADDL_FIELDS, 'Id');
        Expense__c r = (Expense__c) Database.query('SELECT '+fields+' FROM Expense__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        ExpensePreviewController controller = new ExpensePreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();        
    }   
     ***********/

    
}