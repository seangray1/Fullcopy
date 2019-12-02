public with sharing class SchedulePreviewController {
    
    /** List of Schedule__c fields that do not exist on the VF page that need to
     *  be referenced elsewhere in the code */
    public static List<String> ADDL_FIELDS = SchedulePDFController.ADDL_FIELDS;
    
    /** The Schedule to generate a PDF for */
    public Schedule__c Schedule {get; set;}
    

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
    public SchedulePreviewController(ApexPages.StandardController controller) {
        
        // Add any additional fields
        if (! Test.isRunningTest()) {
            controller.addFields(SchedulePDFController.ADDL_FIELDS);
        }
        
        // Initialize local variables
        Schedule = (Schedule__c) controller.getRecord();
        formGeneratePDF = new GeneratePDFForm(this);
        
        pdfVersion = 1;
      /*  if (Schedule.Current_PDF_Version__c != null || 1 <= Schedule.Current_PDF_Version__c) {
            pdfVersion = (Integer) Schedule.Current_PDF_Version__c.round(System.RoundingMode.DOWN);
        }*/
        
        // Normalize the current date to a string
        //pdfVersionDate = Date.today().format();
        
        // Get the proposed file names
        initFileNames();
        
    }
    
    
    public void initFileNames() {
        
        // The following parameters will be available
        // {0} - Opportunity name
        // {1} - Schedule Version
        // {2} - Schedule Date
        // {3} - Final Schedule string
        // {4} - No letterhead string
        String fileNameTemplateWLH = '{0}_{1}.pdf';
        
        
        List<String> formatParams = new List<String> {
            Schedule.name,
            String.valueOf(pdfVersion)
        };
        
        filenameWithLetterhead = String.format(fileNameTemplateWLH, formatParams);
          
        return;
        
    }
    
    
    /**************************************************************************
     * Function used to generate and attach PDFs to the original Schedule
     */
    public void attachPDFs() {
        
        PageReference pdfDLPageRef;
        String pdfDLUrl;
        Attachment pdfAttachment;
        List<Attachment> pdfAttachments = new List<Attachment>();
        
        String userSessionId = UserInfo.getSessionId();
        System.debug('SchedulePreviewController.attachPDFs: User session ID: '+userSessionId);
        
        // ***** PDF WITH LETTERHEAD *****
        // Determine Download URL
        pdfDLPageRef = Page.SchedulePDF;                             //This should be my page name
        pdfDLPageRef.getParameters().put('id', Schedule.Id);
        pdfDLUrl = pdfDLPageRef.getUrl();
        
        System.debug('Downloading PDF WITH Letterhead from "'+pdfDLUrl+'"');
        
        // Set up PDF attachment
        pdfAttachment = httpGetAsAttachment(pdfDLUrl);
        pdfAttachment.Name = filenameWithLetterhead;
        pdfAttachment.ParentId = Schedule.Id;                  //Parent ID
        
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
        cDe.LinkedEntityId = schedule.ATI_Job__c; // you can use objectId,GroupId etc
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
        HttpResponse res = SchedulePreviewController.makeRequest(getUrl, 10, null);
        
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
            System.debug(Logginglevel.ERROR, 'SchedulePreviewController.makeRequest: Reached redirect limit.  Returning null which will likely cause a Null Pointer Exception.');
            return null;
        }
        
        // Generate empty set of cookies
        if (cookies == null) {
            cookies = new List<Cookie>();
        }
        
        System.debug('SchedulePreviewController.makeRequest: ('+nRedirectsAllowed+' redirects allowed) Requesting data from URL: '+getUrl);
        
        // Set up the HTTP get request
        Http h = new Http();
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getUrl);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());
        
        // Make the HTTP request
        HttpResponse res = h.send(req);
        
        // Debug output information about the response
        System.debug('SchedulePreviewController.makeRequest: Response received!');
        System.debug('SchedulePreviewController.makeRequest: Response.Code: '+res.getStatusCode());
        for (String hdr : res.getHeaderKeys()) {
            if (hdr != null) {
                System.debug('SchedulePreviewController.makeRequest: Response.Header.'+hdr+': '+res.getHeader(hdr));
            }
        }
        System.debug('SchedulePreviewController.makeRequest: Response.Body: '+res.getBody());
        
        // If the response is a 302, attempt a redirect
        if (res.getStatusCode() == 302) {
            System.debug('SchedulePreviewController.makeRequest: 302 response received from server.  Attempting a redirect...');
            return SchedulePreviewController.makeRequest(res.getHeader('Location'), nRedirectsAllowed-1, cookies);
        }
        
        // A proper response was received.  Return it to the caller.
        return res;
        
    }
    
    
    
    public class GeneratePDFForm {
        
        private SchedulePreviewController controller;
        
        public GeneratePDFForm(SchedulePreviewController parentController) {
            controller = parentController;
        }
        
        public PageReference savePDF() {
            
            System.debug('SchedulePDFController.GeneratePDFForm.save: Method called');
            
            // Save needs to generate PDFs for the page
            try {
                
                // Generate and attach PDFs
                controller.attachPDFs();
                System.debug('SchedulePDFController.GeneratePDFForm.save: PDFs attached.  Returning to Schedule detail page.');
                
                // If the attachment succeeded, return to the Schedule
                PageReference redir = new PageReference('/'+controller.Schedule.Id);
                redir.setRedirect(true);
                return redir;
                
            }catch(Exception e){
                
                // Display errors on the page
                System.debug(Logginglevel.ERROR, 'SchedulePDFController.GeneratePDFForm.save: An exception was thrown: '+e.getMessage()+'\n'+e.getStackTraceString());
                ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(ErrorMsg);
                return null;
            }
            
            
        }
        
        public PageReference cancelPDF() {
            
            System.debug('SchedulePDFController.GeneratePDFForm.cancel: Method called');
            
            // Cancelling returns to the Schedule page
            PageReference redir = new PageReference('/'+controller.Schedule.Id);
            redir.setRedirect(true);
            return redir;
            
        }
        
        
    }
 }