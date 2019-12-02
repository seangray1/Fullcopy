/*****************************************************************************
* Description: This is a controller extension for the Waiver__c standard controller. 
*               It is used to control the new letter and new waiver VF pages.
* Author      : Eric Schrage (Perficient)
* Date        : 08/04/2015
* Version     : 1.0
*
* Version History:
*
*****************************************************************************/
public class ATICreateWaiverOrLetterController { 
    
    //properties
    public Boolean renderLetterFields{get;set;} // property used to render conditional fields
    public Boolean renderCFWaiverFields{get;set;} // property used to render conditional fields
    public Boolean renderCPWaiverFields{get;set;} // property used to render conditional fields
    public Boolean renderUFWaiverFields{get;set;} // property used to render conditional fields
    public Boolean renderUPWaiverFields{get;set;} // property used to render conditional fields
    public Boolean renderSignatureSection{get;set;} // property used to render conditional fields
    public Boolean renderSignatureFields{get;set;} // property used to render conditional fields
    public User selectedSignature{get;set;} // used to display related signature data
    
    private final Waiver__c myWaiver; // holds global waiver object
    
    public static Map<String,Waiver_Settings__c> waiverSettings = Waiver_Settings__c.getAll();
    public static final String CUSTOM_SETTING_NAME = 'Apex Settings';
    public static final String UF_WAIVER_NAME = waiverSettings.get(CUSTOM_SETTING_NAME).Unconditional_Final_Name__c;
    public static final String UP_WAIVER_NAME = waiverSettings.get(CUSTOM_SETTING_NAME).Unconditional_Progress_Name__c;
    public static final String CF_WAIVER_NAME = waiverSettings.get(CUSTOM_SETTING_NAME).Conditional_Final_Name__c;
    public static final String CP_WAIVER_NAME = waiverSettings.get(CUSTOM_SETTING_NAME).Conditional_Progress_Name__c;
    public static final String LETTER_60_NAME = waiverSettings.get(CUSTOM_SETTING_NAME).Letter_60_Day_Name__c;
    
    public String lookupEmail{get;set;}
    public String careOfAddress{get;set;}
    private Invoice__c parentInvoice;
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ATICreateWaiverOrLetterController(ApexPages.StandardController stdController) {
        
        this.myWaiver = (Waiver__c)stdController.getRecord();
        
        try {
            //get the parent object id in parameter
            String parentId = ApexPages.currentPage().getParameters().get('retURL').substringAfterLast('/');
            System.debug('######## Origin id:' + parentId);
            Id objectId = Id.valueOf(parentId);
            initializeWaiver(objectId);
            
        } catch (Exception e) {
            //do nothing,allow user to enter without prepopulated fields
            System.debug('######## Error:' + e.getMessage());
        }
    }
    
    // Private function used with the constructor to prepopulate record fields
    private void initializeWaiver(Id objectId) {
        parentInvoice = null; 
        ATI_Job__c parentJob = null;
        
        //set recordtype
        String recordType = ApexPages.currentPage().getParameters().get('RecordType');
        Id recordTypeId = Id.valueOf(recordType);
        this.myWaiver.RecordTypeId = recordTypeId;
        
        String objectTypeName = objectId.getSObjectType().getDescribe().getName();
        //get the parent objects based on type
        if (objectTypeName == 'ATI_Job__c') {
            //Letters are initiated from ATI Jobs
            this.renderLetterFields = false;
            List<ATI_Job__c> tempJobList = [SELECT Id,Job_Name__c FROM ATI_Job__c WHERE Id=:objectId LIMIT 1];
            if (tempJobList.size()>=1) {
                parentJob = tempJobList[0];
            }
            //TO DO: verify most recent invoice used
            //find the most recent invoice
            List<Invoice__c> tempInvList = [SELECT Id,Due_Date__c,ATI_Job__c,Bill_To__c,Bill_To_Attention__c,Bill_To_Address_Formula__c,Bill_To_Address1__c,
                                            Bill_to_City__c,Bill_to_State__c,Bill_to_Zip__c,Bill_To_Attention_Lookup__c,Bill_To_Attention_Lookup__r.Email,Care_Of__c,
                                            Care_Of__r.FirstName,Care_Of__r.LastName, Care_of_Address_Formula__c, Care_Of__r.Name
                                            FROM Invoice__c 
                                            WHERE ATI_Job__c=:objectId 
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            if (tempInvList.size()>=1) {
                parentInvoice = tempInvList[0];
            }
            //set letter specific fields
            //Billing Address is concatenated into Bill_To_Address__c
            // Replace bill to address by Bill_To_Address_Formula__c = Rashmi Kalegowda 2/25/2016
            String Billing_Address = parentInvoice.Bill_To_Address_Formula__c;
            if( Billing_Address != null )
                Billing_Address = Billing_Address.replace('<br>','\r\n');
            this.myWaiver.Billing_Address__c = Billing_Address;
            this.myWaiver.Bill_To_Attention__c = parentInvoice.Bill_To_Attention_Lookup__c; //Delano added 9/17/2015
            this.myWaiver.ATI_Job__c = parentJob.Id;
            this.myWaiver.Invoice__c = parentInvoice.Id;
            this.myWaiver.Customer__c = parentInvoice.Bill_To__c;
            this.myWaiver.Customer_Type__c = 'Bill To';
            this.myWaiver.Waiver_Owner__c = parentJob.Job_Name__c;
            String firstName = '';
            if(parentInvoice.Care_Of__r.FirstName !=null){
                firstName = parentInvoice.Care_Of__r.FirstName + ' ';
            }
            String lastName = '';
            if(parentInvoice.Care_Of__r.LastName !=null){
                lastName = parentInvoice.Care_Of__r.LastName;
            }
            this.myWaiver.Care_Of__c = firstName + lastName;
            if( this.myWaiver.Care_Of__c == '' || this.myWaiver.Care_Of__c == null ){
                this.myWaiver.Care_Of__c = parentInvoice.Care_Of__r.Name;
            }
            //// replace Care_Of_Address__c with Care_of_Address_Formula__c- Rashmi - 2/25/2016
            this.myWaiver.Care_Of_Address__c = parentInvoice.Care_of_Address_Formula__c.replace('<br>','\r\n');
            
        } else if (objectTypeName == 'Invoice__c') {
            //Waivers are initiated from Invoices
            renderCFWaiverFields = false;
            renderCPWaiverFields = false;
            renderUFWaiverFields = false;
            renderUPWaiverFields = false;
            renderSignatureFields = false;
            renderSignatureSection = false;
            // replace Bill_To_Address__c with Bill_To_Address_Formula__c - Rashmi K (Perficient) - 2/25/2016
            List<Invoice__c> tempInvList = [SELECT Id,Due_Date__c,ATI_Job__c,Bill_To__c,Bill_To_Attention__c,Bill_To_Address__c,
                                            Bill_To_Address1__c, Net_Due__c, 
                                            Bill_to_City__c,Bill_to_State__c,Bill_to_Zip__c,Bill_To_Attention_Lookup__c,Bill_To_Attention_Lookup__r.Email,
                                            Care_Of__c,Care_Of_Address__c,Care_Of__r.FirstName,Care_Of__r.LastName , Care_Of__r.Name
                                            FROM Invoice__c WHERE Id=:objectId LIMIT 1];
            if (tempInvList.size()>=1) {parentInvoice = tempInvList[0];} 
            //find the job
            System.debug('######## Job Id:' + parentInvoice.ATI_Job__c);
            List<ATI_Job__c> tempJobList = [SELECT Id,Job_Name__c,Project_Site_Address_Concat__c FROM ATI_Job__c WHERE Id=:parentInvoice.ATI_Job__c LIMIT 1];
            if (tempJobList.size()>=1) {parentJob = tempJobList[0];}
            //set waiver specific fields
            this.myWaiver.Through_Date__c = parentInvoice.Due_Date__c;
            lookupEmail = parentInvoice.Bill_To_Attention_Lookup__r.Email;
            this.myWaiver.Bill_To_Attention__c = parentInvoice.Bill_To_Attention_Lookup__c; //Delano added 9/17/2015
            //Address is concatenated into Project_Site_Address_Concat__c
            String Job_Address = parentJob.Project_Site_Address_Concat__c;
            //Job_Address = Job_Address.replace('<br>','\r\n');
            this.myWaiver.Job_Location__c = Job_Address;
            String firstName = '';
            if(parentInvoice.Care_Of__r.FirstName !=null){
                firstName = parentInvoice.Care_Of__r.FirstName + ' ';
            }
            String lastName = '';
            if(parentInvoice.Care_Of__r.LastName !=null){
                lastName = parentInvoice.Care_Of__r.LastName;
            }
            this.myWaiver.Care_Of__c = firstName + lastName;
            if( this.myWaiver.Care_Of__c == '' || this.myWaiver.Care_Of__c == null ){
                this.myWaiver.Care_Of__c = parentInvoice.Care_Of__r.Name;
            }
            // replace Care_Of_Address__c with Care_of_Address_Formula__c- Rashmi - 2/25/2016
            this.myWaiver.Care_Of_Address__c = parentInvoice.Care_Of_Address__c.replace('<br>','\r\n');
        }
        this.myWaiver.ATI_Job__c = parentJob.Id;
        this.myWaiver.Invoice__c = parentInvoice.Id;
        this.myWaiver.Customer__c = parentInvoice.Bill_To__c;
        this.myWaiver.Customer_Type__c = 'Bill To';
        this.myWaiver.Waiver_Owner__c = parentJob.Job_Name__c;
        this.myWaiver.Check_Amount__c =  parentInvoice.Net_Due__c;
    }
    
    //Used with to render conditional fields when letter type is changed
    public PageReference checkLetterType() { 
        String para = this.myWaiver.Waiver_Or_Letter_Type__c;
        System.debug('######## Type:' + para);
        Boolean renderVal = (para != null && para.equals(LETTER_60_NAME));
        this.renderLetterFields = renderVal;
        
        return null;
    }
    
    //Used with to render conditional fields when invoice is changed
    public PageReference invoiceChanged() { 
        //search for invoice
        // replace Care_Of_Address__c with Care_of_Address_Formula__c- Rashmi - 2/25/2016
        parentInvoice = null; 
        List<Invoice__c> tempInvList = [SELECT Id,Due_Date__c,ATI_Job__c,Bill_To__c,Bill_To_Attention__c,Bill_To_Address__c,Bill_To_Address1__c,
                                        Bill_to_City__c,Bill_to_State__c,Bill_to_Zip__c,Bill_To_Attention_Lookup__c,Bill_To_Attention_Lookup__r.Email,
                                        Care_Of__c,Care_of_Address_Formula__c,Care_Of__r.FirstName,Care_Of__r.LastName 
                                        FROM Invoice__c WHERE Id=:this.myWaiver.Invoice__c LIMIT 1];
        if (tempInvList.size()>=1) {parentInvoice = tempInvList[0];}
        //set all of the fields related to invoice
        //Billing Address is concatenated into Bill_To_Address__c
        String Billing_Address = parentInvoice.Bill_To_Address__c;
        Billing_Address = Billing_Address.replace('<br>','\r\n');
        this.myWaiver.Billing_Address__c = Billing_Address;
        this.myWaiver.Invoice__c = parentInvoice.Id;
        String firstName = '';
        if(parentInvoice.Care_Of__r.FirstName !=null){
            firstName = parentInvoice.Care_Of__r.FirstName + ' ';
        }
        String lastName = '';
        if(parentInvoice.Care_Of__r.LastName !=null){
            lastName = parentInvoice.Care_Of__r.LastName;
        }
        this.myWaiver.Care_Of__c = firstName + lastName;
        // replace Care_Of_Address__c with Care_of_Address_Formula__c- Rashmi - 2/25/2016
        this.myWaiver.Care_Of_Address__c = parentInvoice.Care_of_Address_Formula__c.replace('<br>','\r\n');
        this.myWaiver.Customer__c = parentInvoice.Bill_To__c;
        
        return null;
    }
    
    //Used to render conditional fields when waiver type is changed.
    public PageReference checkWaiverType() { 
        String para = this.myWaiver.Waiver_Or_Letter_Type__c;
        System.debug('######## Type:' + para);
        
        // reset
        renderCFWaiverFields = false;
        renderCPWaiverFields = false;
        renderUFWaiverFields = false;
        renderUPWaiverFields = false;
        //clear signature
        renderSignatureSection = false;
        renderSignatureFields = false;
        selectedSignature =  null;
        this.myWaiver.Signature_Date__c = null;
        this.myWaiver.User_Signature__c = null;
        //clear fields from all other waiver types
        
        this.myWaiver.Exception_Unaffected__c =  null;
        this.myWaiver.Exception_Extras_Disputed_Amount__c =  null;
        this.myWaiver.Exception_Date_Waiver_Release__c =  null;
        this.myWaiver.Exception_Unpaid_Progress_Pymt_Amt__c =  null;
        this.myWaiver.Received_Progress_Pymt_Amt__c =  null;
        
        //render the corresponding section
        //signature is not shown for unconditional waivers
        if (para != null){
            if (para.equals(UF_WAIVER_NAME)){
                renderUFWaiverFields = true;
            } else if (para.indexOf(CF_WAIVER_NAME)>=0){
                renderCFWaiverFields = true;
                renderSignatureSection = true;
                //get the signature of the current user
                selectedSignature = [SELECT Name,Title,Signature_Image_URL__c FROM User WHERE Id = :UserInfo.getUserId()];
                this.myWaiver.User_Signature__c = UserInfo.getUserId();
                this.myWaiver.Signature_Date__c = Date.today();
                renderSignatureFields = true;
            } else if (para.indexOf(UP_WAIVER_NAME)>=0){
                renderUPWaiverFields = true;
            } else if (para.indexOf(CP_WAIVER_NAME)>=0){
                renderCPWaiverFields = true;    
                renderSignatureSection = true;   
                //get the signature of the current user
                selectedSignature = [SELECT Name,Title,Signature_Image_URL__c FROM User WHERE Id = :UserInfo.getUserId()];
                this.myWaiver.User_Signature__c = UserInfo.getUserId();
                this.myWaiver.Signature_Date__c = Date.today();
                renderSignatureFields = true;
            }
        }
        
        return null;
    }
    
    public pageReference setCustomerType(){
        system.debug(this.myWaiver.Customer_Type__c);
        if( this.myWaiver.Customer_Type__c == 'Bill To'){
            this.myWaiver.Customer__c = parentInvoice.Bill_To__c;
        }
        if( this.myWaiver.Customer_Type__c == 'Care of'){
            this.myWaiver.Customer__c = parentInvoice.Care_Of__c;
        }
        return null;
    }
    public PageReference save(){
        try{
            if( this.myWaiver.Waiver_Or_Letter_Type__c != CF_WAIVER_NAME && this.myWaiver.Waiver_Or_Letter_Type__c != CP_WAIVER_NAME ){
                this.myWaiver.Check_Amount__c =  null;
            }
            upsert this.myWaiver;
            PageReference upsertWaiver = new PageReference('/' + this.myWaiver.Id);
            upsertWaiver.setRedirect(true);
            return upsertWaiver;
        }
        catch (Exception e){
            Apexpages.addMessage(new Apexpages.Message(APEXPAGES.SEVERITY.ERROR, e.getMessage()));
            return null;
        }
        
    }
    //NOT USED,saved for requirement changes
    //Used to show the additional signature fields when a signature is selected
    /*public PageReference checkSignature() {
String para = this.myWaiver.User_Signature__c;
System.debug('######## Signature:' + para);

if (para != null){
renderSignatureFields = true;
selectedSignature = [SELECT Name,Title,Signature_Image_URL__c FROM User WHERE Id = :para];
System.debug('######## Selected Signature:' + selectedSignature);
this.myWaiver.Signature_Date__c = Date.today();
} else {
renderSignatureFields = false;
selectedSignature = null;
this.myWaiver.Signature_Date__c = null;
}

return null;
}*/
    
    @AuraEnabled
    public static ATI_Job__c getJob(String jobId){
        ATI_Job__c job = [select Id, name from ATI_Job__c where Id =: jobId limit 1];
        return job; 
    }
    
    @AuraEnabled
    public static Invoice__c getInv(String InvId){
        Invoice__c inv = [select Id, name from Invoice__c where Id =: InvId limit 1];
        return inv;
    }
    
}