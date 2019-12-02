/*
    Run PDFController_Test for testclass.
*/

public with sharing class PDFPreviewController {
    
    /** List of Budget__c fields that do not exist on the VF page that need to
     *  be referenced elsewhere in the code */
    public static List<String> ADDL_FIELDS = PDFController.ADDL_FIELDS;
    
    /** The Budget to generate a PDF for */
    public sObject obj {get; set;}
//    public Material_Requisition__c obj {get; set;}
    

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
    public PDFPreviewController(ApexPages.StandardController controller) {
        
        // Initialize local variables
        ID sObjectId = controller.getId();
        String sObjectName = sObjectId.getSObjectType().getDescribe().getName();
        
        // Add any additional fields
        if (!Test.isRunningTest()) {
            controller.addFields(SfObjectHelper.GetObjectFieldsById(sObjectId ));
        }
        
        obj = controller.getRecord();
        formGeneratePDF = new GeneratePDFForm(this);
        
        pdfVersion = 1;
        Integer currentvalue = Integer.valueOF(obj.get('Current_PDF_Version__c'));
        
        if (currentvalue != null || 1 <= currentValue) {
            pdfVersion = (Integer)currentValue;
        }
        
        // Normalize the current date to a string
        //pdfVersionDate = Date.today().format();
        
        // Get the proposed file names
        initFileNames();
        
    }
 
    public void initFileNames() {
        
        // The following parameters will be available
        // {0} - Opportunity name
        // {1} - budget Version
        // {2} - budget Date
        // {3} - Final budget string
        // {4} - No letterhead string
        String fileNameTemplateWLH = '{0}_{1}.pdf';
        
        
        List<String> formatParams = new List<String> {
           (string)obj.get('name'),
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
        System.debug('PDFPreviewController.attachPDFs: User session ID: '+userSessionId);
        
        // ***** PDF WITH LETTERHEAD *****
        // Determine Download URL

//how to write a generic visualforce page?
        pdfDLPageRef = Page.MaterialReqPDF;                             //This should be my page name
        pdfDLPageRef.getParameters().put('id', obj.Id);
        //pdfDLPageRef = ApexPages.currentPage();
        pdfDLUrl = pdfDLPageRef.getUrl();
        
        System.debug('Downloading PDF WITH Letterhead from "'+pdfDLUrl+'"');
        
        // Set up PDF attachment
        pdfAttachment = httpGetAsAttachment(pdfDLUrl);
        pdfAttachment.Name = filenameWithLetterhead;
        pdfAttachment.ParentId = obj.Id;                  //Parent ID
        
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
        HttpResponse res = PDFPreviewController.makeRequest(getUrl, 10, null);
        
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
            System.debug(Logginglevel.ERROR, 'PDFPreviewController.makeRequest: Reached redirect limit.  Returning null which will likely cause a Null Pointer Exception.');
            return null;
        }
        
        // Generate empty set of cookies
        if (cookies == null) {
            cookies = new List<Cookie>();
        }
        
        System.debug('PDFPreviewController.makeRequest: ('+nRedirectsAllowed+' redirects allowed) Requesting data from URL: '+getUrl);
        
        // Set up the HTTP get request
        Http h = new Http();
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getUrl);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());
        
        // Make the HTTP request
        HttpResponse res = h.send(req);
        
        // Debug output information about the response
        System.debug('PDFPreviewController.makeRequest: Response received!');
        System.debug('PDFPreviewController.makeRequest: Response.Code: '+res.getStatusCode());
        for (String hdr : res.getHeaderKeys()) {
            if (hdr != null) {
                System.debug('PDFPreviewController.makeRequest: Response.Header.'+hdr+': '+res.getHeader(hdr));
            }
        }
        System.debug('PDFPreviewController.makeRequest: Response.Body: '+res.getBody());
        
        // If the response is a 302, attempt a redirect
        if (res.getStatusCode() == 302) {
            System.debug('PDFPreviewController.makeRequest: 302 response received from server.  Attempting a redirect...');
            return PDFPreviewController.makeRequest(res.getHeader('Location'), nRedirectsAllowed-1, cookies);
        }
        
        // A proper response was received.  Return it to the caller.
        return res;
        
    }
       
    public class GeneratePDFForm {
        
        private PDFPreviewController controller;
        
        public GeneratePDFForm(PDFPreviewController parentController) {
            controller = parentController;
        }
        
        public PageReference savePDF() {
            
            System.debug('PDFController.GeneratePDFForm.save: Method called');
            
            // Save needs to generate PDFs for the page
            try {
                
                // Generate and attach PDFs
                controller.attachPDFs();
                System.debug('PDFController.GeneratePDFForm.save: PDFs attached.  Returning to Budget detail page.');
                
                // If the attachment succeeded, return to the Budget
                PageReference redir = new PageReference('/'+controller.obj.Id);
                redir.setRedirect(true);
                return redir;
                
            }catch(Exception e){
                
                // Display errors on the page
                System.debug(Logginglevel.ERROR, 'PDFController.GeneratePDFForm.save: An exception was thrown: '+e.getMessage()+'\n'+e.getStackTraceString());
                ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(ErrorMsg);
                return null;
            }
            
            
        }
        
        public PageReference cancelPDF() {
            
            System.debug('PDFController.GeneratePDFForm.cancel: Method called');
            
            // Cancelling returns to the Budget page
            PageReference redir = new PageReference('/'+controller.obj.Id);
            redir.setRedirect(true);
            return redir;
            
        }
        
        
    }
 }