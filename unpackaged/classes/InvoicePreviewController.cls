public with sharing class InvoicePreviewController {
    
    /** List of Invoice__c fields that do not exist on the VF page that need to
     *  be referenced elsewhere in the code */
    public static List<String> ADDL_FIELDS = InvoicePDFController.ADDL_FIELDS;
    
    /** The invoice to generate a PDF for */
    public Invoice__c invoice {get; set;}
    
    /** The version of the next PDF generated */
    public Integer pdfVersion {get; set;}
    
    public Boolean isDeliveryByEmail { get; set; }
    
    /** The date that will be used for the generated PDF */
    public String pdfVersionDate {get; set;}
    
    /** The form used on the PDF preview page */
    public GeneratePDFForm formGeneratePDF {get; set;}
    
    public String filenameWithLetterhead {get; set;}
    
    public String filenameWithoutLetterhead {get; set;}
    
    /**************************************************************************
     * 
     */
    public InvoicePreviewController(ApexPages.StandardController controller) {
        
        // Add any additional fields
        if (! Test.isRunningTest()) {
            controller.addFields(InvoicePDFController.ADDL_FIELDS);
        }
        
        // Initialize local variables
        invoice = (Invoice__c) controller.getRecord();
        formGeneratePDF = new GeneratePDFForm(this);
        
        // Normalize the PDF version
        pdfVersion = 1;
        if (invoice.Current_PDF_Version__c != null || 1 <= invoice.Current_PDF_Version__c) {
            pdfVersion = (Integer) invoice.Current_PDF_Version__c.round(System.RoundingMode.DOWN);
        }
        
        if( invoice.Delivery_Method__c == 'Email'){
            isDeliveryByEmail = true;
        }else{
            isDeliveryByEmail = false;
        }
        // Normalize the current date to a string
        Datetime nowDT = System.now();
        pdfVersionDate = nowDT.format('yyyy-MM-dd');
        
        // Get the proposed file names
        initFileNames();
        
    }
    
    
    public void initFileNames() {
        
        // The following parameters will be available
        // {0} - Invoice name
        // {1} - Invoice Version
        // {2} - Invoice Date
        // {3} - Final invoice string
        // {4} - No letterhead string
        String fileNameTemplateWLH = 'Invoice_{0}_v{1}{3}{4}{5}_{2}.pdf';
        String fileNameTemplateWOLH = 'Invoice_{0}_v{1}{3}{4}{5}_{2} {6}.pdf';
        
        List<String> formatParams = new List<String> {
            invoice.Name,
            String.valueOf(pdfVersion),
            pdfVersionDate,
            ((invoice.Internal__c) ? '_INTERNAL' : ''),
            ((invoice.Is_Dummy_Invoice__c) ? '_PROFORMA' : ''),
            ((invoice.Status__c == 'Final') ? '_FINAL' : ''),
            '(No letterhead)'
        };
        
        filenameWithLetterhead = String.format(fileNameTemplateWLH, formatParams);
        filenameWithoutLetterhead = String.format(fileNameTemplateWOLH, formatParams);
        
        return;
        
    }
    
    
    /**************************************************************************
     * Function used to generate and attach PDFs to the original invoice
     */
    public void attachPDFs() {
        
        PageReference pdfDLPageRef;
        String pdfDLUrl;
        Attachment pdfAttachment;
        List<Attachment> pdfAttachments = new List<Attachment>();
        
        String userSessionId = UserInfo.getSessionId();
        System.debug('InvoicePreviewController.attachPDFs: User session ID: '+userSessionId);
        
        // ***** PDF WITH LETTERHEAD *****
        // Determine Download URL
        pdfDLPageRef = Page.InvoicePDF;
        pdfDLPageRef.getParameters().put('id', invoice.Id);
        pdfDLPageRef.getParameters().put('dlh', '1');
        System.debug(pdfDLPageRef + 'is the pdfDLPageRef');
        //pdfDLPageRef.getParameters().put('sid', userSessionId);
        pdfDLUrl = pdfDLPageRef.getUrl();
        
        System.debug('Downloading PDF WITH Letterhead from "'+pdfDLUrl+'"');
        
        // Set up PDF attachment
        pdfAttachment = httpGetAsAttachment(pdfDLUrl);
        pdfAttachment.Name = filenameWithLetterhead;
        pdfAttachment.ParentId = invoice.ATI_Job__c;
        
        // Remember attachment to be inserted later
        pdfAttachments.add(pdfAttachment);
        
        // ***** PDF WITHOUT LETTERHEAD *****
        // Determine Download URL
        pdfDLPageRef = Page.InvoicePDF;
        pdfDLPageRef.getParameters().put('id', invoice.Id);
        pdfDLPageRef.getParameters().put('dlh', '0');
        //pdfDLPageRef.getParameters().put('sid', userSessionId);
        pdfDLUrl = pdfDLPageRef.getUrl();
       
        System.debug('Downloading PDF WITHOUT Letterhead from "'+pdfDLUrl+'"');
        
        // Set up PDF attachment
        pdfAttachment = httpGetAsAttachment(pdfDLUrl);
        pdfAttachment.Name = filenameWithoutLetterhead;
        pdfAttachment.ParentId = invoice.ATI_Job__c;
        
        // Remember attachment to be inserted later
        pdfAttachments.add(pdfAttachment);
        
        // ***** INSERT ATTACHMENTS *****
        insert pdfAttachments;
        // ***** Convert to Files ******
        system.debug('Pdf attachments body is ' + pdfAttachments[0].body);
        ContentVersion conVer = new ContentVersion();
        conVer.PathOnClient = '/' + pdfAttachments[0].name; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = pdfAttachments[0].name; // Display name of the files
        conVer.VersionData = pdfAttachments[0].body; // converting your binary string to Blog
        insert conVer;
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :conVer.Id];
        system.debug('test content is ' + testContent);
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = testContent.ContentDocumentId;
        cDe.LinkedEntityId = invoice.ATI_Job__c; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        
        system.debug('Pdf attachments body is ' + pdfAttachments[1].body);
        
        ContentVersion conVer1 = new ContentVersion();
        //conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer1.PathOnClient = '/' + pdfAttachments[1].name; // The files name, extension is very important here which will help the file in preview.
        conVer1.Title = pdfAttachments[1].name; // Display name of the files
        
        conVer1.VersionData = pdfAttachments[1].body; // converting your binary string to Blog
        //conVer.ownerId = attachmentPdf.ownerId;
        insert conVer1;
        ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :conVer1.Id];
        //Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        system.debug('test content is ' + testContent1);
        //Create ContentDocumentLink
        ContentDocumentLink cDe1 = new ContentDocumentLink();
        cDe1.ContentDocumentId = testContent1.ContentDocumentId;
        cDe1.LinkedEntityId = invoice.ATI_Job__c; // you can use objectId,GroupId etc
        cDe1.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe1.Visibility = 'AllUsers';
        insert cDe1;
        delete pdfAttachments;
        
        
        // Since both of the invoices were added, increment the version number
        // on the invoice record itself.  The version number cannot be
        // incremented on finalized invoices
        if (invoice.Status__c != 'Final') {
            invoice.Current_PDF_Version__c = pdfVersion + 1;
            update invoice;
        }
        
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
        HttpResponse res = InvoicePreviewController.makeRequest(getUrl, 10, null);
        
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
            System.debug(Logginglevel.ERROR, 'InvoicePreviewController.makeRequest: Reached redirect limit.  Returning null which will likely cause a Null Pointer Exception.');
            return null;
        }
        
        // Generate empty set of cookies
        if (cookies == null) {
            cookies = new List<Cookie>();
        }
        
        System.debug('InvoicePreviewController.makeRequest: ('+nRedirectsAllowed+' redirects allowed) Requesting data from URL: '+getUrl);
        
        // Set up the HTTP get request
        Http h = new Http();
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getUrl);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());
        
        // Make the HTTP request
        HttpResponse res = h.send(req);
        
        // Debug output information about the response
        System.debug('InvoicePreviewController.makeRequest: Response received!');
        System.debug('InvoicePreviewController.makeRequest: Response.Code: '+res.getStatusCode());
        for (String hdr : res.getHeaderKeys()) {
            if (hdr != null) {
                System.debug('InvoicePreviewController.makeRequest: Response.Header.'+hdr+': '+res.getHeader(hdr));
            }
        }
        System.debug('InvoicePreviewController.makeRequest: Response.Body: '+res.getBody());
        
        // If the response is a 302, attempt a redirect
        if (res.getStatusCode() == 302) {
            System.debug('InvoicePreviewController.makeRequest: 302 response received from server.  Attempting a redirect...');
            return InvoicePreviewController.makeRequest(res.getHeader('Location'), nRedirectsAllowed-1, cookies);
        }
        
        // A proper response was received.  Return it to the caller.
        return res;
        
    }
    
    
    
    public class GeneratePDFForm {
        
        private InvoicePreviewController controller;
        
        public GeneratePDFForm(InvoicePreviewController parentController) {
            controller = parentController;
        }
        
        public PageReference savePDF() {
            
            System.debug('InvoicePDFController.GeneratePDFForm.save: Method called');
            
            // Save needs to generate PDFs for the page
            try {
                
                // Generate and attach PDFs
                controller.attachPDFs();
                System.debug('InvoicePDFController.GeneratePDFForm.save: PDFs attached.  Returning to invoice detail page.');
                
                // If the attachment succeeded, return to the invoice
                PageReference redir = new PageReference('/'+controller.invoice.Id);
                redir.setRedirect(true);
                return redir;
                
            }catch(Exception e){
                
                // Display errors on the page
                System.debug(Logginglevel.ERROR, 'InvoicePDFController.GeneratePDFForm.save: An exception was thrown: '+e.getMessage()+'\n'+e.getStackTraceString());
                ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(ErrorMsg);
                return null;
            }
            
//            return null;
            
        }
        
        public pageReference next(){
            try {
                
                // Generate and attach PDFs
                controller.attachPDFs();
                System.debug('InvoicePDFController.GeneratePDFForm.next: PDFs attached.  Returning to invoice detail page.');
                
                List<Attachment> attachments = [ SELECT Id FROM Attachment WHERE Name =: controller.filenameWithLetterhead ];
                Id attachmentId;
                if( !attachments.isEmpty() ){
                    attachmentId = attachments[0].Id;
                }                
                // If the attachment succeeded, return to the invoice
                PageReference redir = new PageReference('/apex/SendEmail?id='+controller.invoice.Id + '&attachmentId=' + attachmentId );
                redir.setRedirect(true);
                return redir;
                
            }catch(Exception e){
                
                // Display errors on the page
                System.debug(Logginglevel.ERROR, 'InvoicePDFController.GeneratePDFForm.next: An exception was thrown: '+e.getMessage()+'\n'+e.getStackTraceString());
                ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(ErrorMsg);
                return null;
            }

        }
        
        public PageReference cancelPDF() {
            
            System.debug('InvoicePDFController.GeneratePDFForm.cancel: Method called');
            
            // Cancelling returns to the invoice page
            PageReference redir = new PageReference('/'+controller.invoice.Id);
            redir.setRedirect(true);
            return redir;
            
        }
        
        
    }
    
/**********************************************     
    private static testmethod void test_cancelPDF() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TriggerStatus__c tStat = new TriggerStatus__c(
            AccountGenerateCustomerNumber__c = true,
            AccountSyncToTimberline__c = true,
            Forecast_Sync_to_Timberline__c = true,
            InvoiceAutomaticInvoiceNumber__c = true,
            InvoiceSyncToTimberline__c= true,
            InvoiceLineItemAutoCreation__c= true,
            InvoiceLineItemAutomaticNaming__c= true,
            InvoiceLineItemAutomaticOrder__c= true,
            InvoiceTaxGroupSetUp__c= true,
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
            type = 'Insurance Company',
            Status__c = 'Active',
            BillingCity = 'test',
            BillingCountry = 'US',
            BillingState = 'st',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '23232',
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
        //insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id
            //CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', InvoicePDFController.ADDL_FIELDS, 'Id');
        Invoice__c r = (Invoice__c) Database.query('SELECT '+fields+' FROM Invoice__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.InvoicePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        InvoicePreviewController controller = new InvoicePreviewController(std);
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
            InvoiceAutomaticInvoiceNumber__c = true,
            InvoiceSyncToTimberline__c= true,
            InvoiceLineItemAutoCreation__c= true,
            InvoiceLineItemAutomaticNaming__c= true,
            InvoiceLineItemAutomaticOrder__c= true,
            InvoiceTaxGroupSetUp__c= true,
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
            type = 'Insurance Company',
            Status__c = 'Active',
            BillingCity = 'test',
            BillingCountry = 'US',
            BillingState = 'st',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '87765',
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
        //insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.id
            //CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', InvoicePDFController.ADDL_FIELDS, 'Id');
        Invoice__c r = (Invoice__c) Database.query('SELECT '+fields+' FROM Invoice__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.InvoicePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        InvoicePreviewController controller = new InvoicePreviewController(std);
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
            InvoiceAutomaticInvoiceNumber__c = true,
            InvoiceSyncToTimberline__c= true,
            InvoiceLineItemAutoCreation__c= true,
            InvoiceLineItemAutomaticNaming__c= true,
            InvoiceLineItemAutomaticOrder__c= true,
            InvoiceTaxGroupSetUp__c= true,
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
            type = 'Insurance Company',
            Status__c = 'Active',
            BillingCity = 'test',
            BillingCountry = 'US',
            BillingState = 'Ts',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '00073',
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
        //insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id
           // CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', InvoicePDFController.ADDL_FIELDS, 'Id');
        Invoice__c r = (Invoice__c) Database.query('SELECT '+fields+' FROM Invoice__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.InvoicePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        InvoicePreviewController controller = new InvoicePreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();        
    }
******************************/  

    
}