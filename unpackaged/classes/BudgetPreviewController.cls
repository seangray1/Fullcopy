public with sharing class BudgetPreviewController {
    
    /** List of Budget__c fields that do not exist on the VF page that need to
     *  be referenced elsewhere in the code */
    public static List<String> ADDL_FIELDS = BudgetPDFController.ADDL_FIELDS;
    
    /** The Budget to generate a PDF for */
    public Budget__c budget {get; set;}
    
    /** The date that will be used for the generated PDF */
    public String pdfVersionDate {get; set;}
    
    /** The version of the next PDF generated */
    public Integer pdfVersion {get; set;}
    
    /** The form used on the PDF preview page */
    public GeneratePDFForm formGeneratePDF {get; set;}
    
    public String filenameWithLetterhead {get; set;}
    
    //public String filenameWithoutLetterhead {get; set;}
    
    /**************************************************************************
     * 
     */
    public BudgetPreviewController(ApexPages.StandardController controller) {
        
        // Add any additional fields
        if (! Test.isRunningTest()) {
            controller.addFields(BudgetPDFController.ADDL_FIELDS);
        }
        
        // Initialize local variables
        budget = (Budget__c) controller.getRecord();
        formGeneratePDF = new GeneratePDFForm(this);
        
        pdfVersion = 1;
        if (budget.Current_PDF_Version__c != null || 1 <= budget.Current_PDF_Version__c) {
            pdfVersion = (Integer) budget.Current_PDF_Version__c.round(System.RoundingMode.DOWN);
        }
        
        // Normalize the current date to a string
        //pdfVersionDate = Date.today().format();
        
        // Get the proposed file names
        initFileNames();       
    }
    
        public void initFileNames() {
        
        String fileNameTemplateWLH = '{0}_{1}.pdf';
        
        
        List<String> formatParams = new List<String> {
            budget.name,
            String.valueOf(pdfVersion)
        };
        
        filenameWithLetterhead = String.format(fileNameTemplateWLH, formatParams);
          
        return;
        
    }
    
        /**************************************************************************
     * Function used to generate and attach PDFs to the original Budget
     */
    public void attachPDFs() {
        
        PageReference pdfDLPageRef;
        String pdfDLUrl;
        Attachment pdfAttachment;
        List<Attachment> pdfAttachments = new List<Attachment>();
        
        String userSessionId = UserInfo.getSessionId();
        System.debug('ATI_Job_BudgetPreviewController.attachPDFs: User session ID: '+userSessionId);
        
        // ***** PDF WITH LETTERHEAD *****
        // Determine Download URL
        pdfDLPageRef = Page.BudgetPDF;                             //This should be my page name
        pdfDLPageRef.getParameters().put('id', budget.Id);
        pdfDLUrl = pdfDLPageRef.getUrl();
        
        System.debug('Downloading PDF WITH Letterhead from "'+pdfDLUrl+'"');
        
        // Set up PDF attachment
        pdfAttachment = httpGetAsAttachment(pdfDLUrl);
        pdfAttachment.Name = filenameWithLetterhead;
        pdfAttachment.ParentId = budget.Id;                  //Parent ID
        
        // Remember attachment to be inserted later
        pdfAttachments.add(pdfAttachment);
        
        // ***** INSERT ATTACHMENTS *****
        insert pdfAttachments;
        ContentVersion conVer = new ContentVersion();
        //conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = '/' + pdfAttachments[0].name; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = pdfAttachments[0].name; // Display name of the files
        
        conVer.VersionData = pdfAttachments[0].body; // converting your binary string to Blog
        //conVer.ownerId = attachmentPdf.ownerId;
        insert conVer;
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :conVer.Id];
        //Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        system.debug('test content is ' + testContent);
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = testContent.ContentDocumentId;
        cDe.LinkedEntityId = budget.ATI_Job__c; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        Delete pdfAttachments;
        
        
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
        HttpResponse res = BudgetPreviewController.makeRequest(getUrl, 10, null);
        
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
            System.debug(Logginglevel.ERROR, 'ATI_Job_BudgetPreviewController.makeRequest: Reached redirect limit.  Returning null which will likely cause a Null Pointer Exception.');
            return null;
        }
        
        // Generate empty set of cookies
        if (cookies == null) {
            cookies = new List<Cookie>();
        }
        
        System.debug('ATI_Job_BudgetPreviewController.makeRequest: ('+nRedirectsAllowed+' redirects allowed) Requesting data from URL: '+getUrl);
        
        // Set up the HTTP get request
        Http h = new Http();
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getUrl);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());
        
        // Make the HTTP request
        HttpResponse res = h.send(req);
        
        // Debug output information about the response
        System.debug('ATI_Job_BudgetPreviewController.makeRequest: Response received!');
        System.debug('ATI_Job_BudgetPreviewController.makeRequest: Response.Code: '+res.getStatusCode());
        for (String hdr : res.getHeaderKeys()) {
            if (hdr != null) {
                System.debug('ATI_Job_BudgetPreviewController.makeRequest: Response.Header.'+hdr+': '+res.getHeader(hdr));
            }
        }
        System.debug('ATI_Job_BudgetPreviewController.makeRequest: Response.Body: '+res.getBody());
        
        // If the response is a 302, attempt a redirect
        if (res.getStatusCode() == 302) {
            System.debug('ATI_Job_BudgetPreviewController.makeRequest: 302 response received from server.  Attempting a redirect...');
            return BudgetPreviewController.makeRequest(res.getHeader('Location'), nRedirectsAllowed-1, cookies);
        }
        
        // A proper response was received.  Return it to the caller.
        return res;
        
    }
    
    
    
    public class GeneratePDFForm {
        
        private BudgetPreviewController controller;
        
        public GeneratePDFForm(BudgetPreviewController parentController) {
            controller = parentController;
        }
        
        public PageReference savePDF() {
            
            System.debug('ATI_Job_BudgetPDFController.GeneratePDFForm.save: Method called');
            
            // Save needs to generate PDFs for the page
            try {
                
                // Generate and attach PDFs
                controller.attachPDFs();
                System.debug('ATI_Job_BudgetPDFController.GeneratePDFForm.save: PDFs attached.  Returning to Budget detail page.');
                
                // If the attachment succeeded, return to the Budget
                PageReference redir = new PageReference('/'+controller.budget.Id);
                redir.setRedirect(true);
                return redir;
                
            }catch(Exception e){
                
                // Display errors on the page
                System.debug(Logginglevel.ERROR, 'ATI_Job_BudgetPDFController.GeneratePDFForm.save: An exception was thrown: '+e.getMessage()+'\n'+e.getStackTraceString());
                ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(ErrorMsg);
                return null;
            }
            
            
        }
        
        public PageReference cancelPDF() {
            
            System.debug('ATI_Job_BudgetPDFController.GeneratePDFForm.cancel: Method called');
            
            // Cancelling returns to the Budget page
            PageReference redir = new PageReference('/'+controller.budget.Id);
            redir.setRedirect(true);
            return redir;
            
        }
        
        
    }
}