/**
AUTHOR:    LENNARD SANTOS
COMPANY:    CLOUDSHERPAS
DATE CREATED:  MARCH 5,2013
DESCRIPTION: Controller extension of ATIInvoicePage
HISTORY: 03-5-2013  Created.
**/

public class ATIInvoiceController{ 
    public List<WrapperClass> wrapInvoice{get;set;}
    public Integer count{get;set;}
    //public String accID{get;set;}
    public String sBillingStreet{get;set;}
    public String sMailStr{get;set;}
    public String sTaxGroupRate{get;set;}
    public Account acct {get;set;}
    public Contact con {get;set;}
    public List<Invoice_Line_Item__c> delInvoiceLineItem;
    public String job{get;set;}
    public Invoice__c invoiceRecord {get; set;}
    public String contextBusinessAddressId {get;set;}
    public String contextBusinessAddressType {get;set;}

    ApexPages.StandardController ExtCon;

    public void updateBillingTo() {
        System.debug('contextBusinessAddressId ....' + contextBusinessAddressId);
        List<Billing_Address__c> billingAddress = [SELECT Id, Account__c, Account__r.PersonContactId 
                                             FROM Billing_Address__c 
                                             WHERE Id =: contextBusinessAddressId limit 1];
        for(Billing_Address__c Address: billingAddress){ 
            if(contextBusinessAddressType == 'BillToAddress'){
                invoiceRecord.Bill_To__c = Address.Account__c;
                invoiceRecord.Bill_To_Address3__c = Address.Id;
                if( Address.Account__c != null ){
                    invoiceRecord.Bill_To_Attention_Lookup__c = Address.Account__r.PersonContactId;
                }
            }
            if(contextBusinessAddressType == 'CareOfAddress'){
                invoiceRecord.Care_of_Address_lookup__c = Address.Id;
                invoiceRecord.Care_Of__c = Address.Account__c;
            }
            if(contextBusinessAddressType == 'CCAddress'){
                invoiceRecord.CC_Address_Lookup__c = Address.Id;
                invoiceRecord.CC_Account__c = Address.Account__c;
            }
            if(contextBusinessAddressType == 'CCAddressCareOf'){
                invoiceRecord.CC_Address_Care_of_lookup__c = Address.Id;
                invoiceRecord.CC_CareOf__c = Address.Account__c;
            }
        }
        if(invoiceRecord.id != null)
            upsert invoiceRecord;
    }    

    
    public ATIInvoiceController(ApexPages.StandardController controller) {
        Map<String, Schema.SObjectField> invioceFieldMap = Schema.SObjectType.Invoice__c.fields.getMap();
        this.ExtCon = controller;
        if(!Test.isRunningTest()){
            controller.addFields(new List<String>(invioceFieldMap.keySet()));
        }
        invoiceRecord = (Invoice__c)controller.getRecord();        
        //conID = string.valueOf(invoiceRecord.CC__c);
        //accID = string.valueOf(invoiceRecord.Bill_To__c);
        getInvLineItem();
        job = invoiceRecord.ATI_Job__c;
        setup();
    }
    
    private void setup() {
         populateBillInfo();
         PrePopCC();
         PrePopData();
         PrePopTxRate();
    }
    
    public void populateBillInfo(){
        Job_Contact__c jobQry = null;
        Job_Contact__c jobQry2 = null;
      /*  if( job != null && job != ''){
            for(Job_Contact__c jc1 :[Select Job_Role__c,Job_Acct__c, Contact__c,Account_Name__c,Contact__r.AccountId,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingState,Contact__r.MailingPostalCode,Contact__r.MailingCountry From Job_Contact__c WHERE Job_Role__c INCLUDES ('Bill To') AND ATI_Job__c=:job LIMIT 1]){
                jobQry = jc1;
            }    
        
            for(Job_Contact__c jc2 :[Select Job_Role__c,Job_Acct__c, Contact__c,Account_Name__c,Contact__r.MailingStreet, Contact__r.MailingCity,Contact__r.MailingState,Contact__r.MailingPostalCode,Contact__r.MailingCountry From Job_Contact__c WHERE Job_Role__c INCLUDES ('CC') AND ATI_Job__c=:job LIMIT 1]){
                jobQry2 = jc2;
            }
        }
        
        if(jobQry != null && invoiceRecord.Bill_To__c == null){
            invoiceRecord.Bill_To__c = jobQry.Job_Acct__c;
        }
        if(jobQry2 != null && invoiceRecord.CC_Account__c == null){
            invoiceRecord.CC_Account__c = jobQry2.Job_Acct__c;
        }  */

        //Delano Johnson (perficient) added 9/17/2015
        if(invoiceRecord.Bill_To__c != null){
            Account billTo = new Account();
            billTo = [SELECT PersonContactId FROM Account WHERE Id =: invoiceRecord.Bill_To__c];
            if(billTo.PersonContactId != null){
                invoiceRecord.Bill_To_Attention_Lookup__c = billTo.PersonContactId;
            }
        }
    }
    

    public void getInvLineItem(){     
         wrapInvoice = new List<WrapperClass>();
         Integer listCount = 0;
         //Query records if page returns an Id         
         for(Invoice_Line_Item__c invl:[Select Taxable__c, PickListName__c, Other__c, 
                                         Order__c, Note__c,  IsDeleted,  IsCredit__c,  
                                         Invoice__c,  Description__c,  Amount__c 
                                         From Invoice_Line_Item__c  
                                         WHERE Invoice__c =:ApexPages.CurrentPage().getParameters().get('id')])
         {
         //add Invoice Line Items to wrapper list
             WrapperClass wrapInvLineItem = new WrapperClass(listCount,invl);
             wrapInvoice.add(wrapInvLineItem);
             listCount = listCount + 1;
         }
         //For Creation of new Invoice...wrapInvoice will be empty since query returned no results
         //New Invoice must contain 3 empty line items
         if(wrapInvoice.isEmpty()==true){
             wrapInvoice = new List<WrapperClass>();
             createLineItem();
         }
    }
    //method that will return value of fields related to the Bill to account Lookup field
    public void PrePopData(){
		 System.debug('This is Inside PrepopData - contextBusinessAddressId ....' + contextBusinessAddressId);
 
         List<Account> acctList = [Select a.BillingStreet, a.BillingState, a.BillingPostalCode, 
                           a.BillingCountry, a.BillingCity, a.Tax_Group__c, a.Billing_Notes__c From Account a WHERE a.Id =:invoiceRecord.Bill_To__c
                           or a.Id = :invoiceRecord.Care_Of__c];
         System.debug('Checking acctList--'+acctList +'--'+invoiceRecord.Care_Of__c)  ;                
       for(Account acc : acctList)  {   
       System.debug('checking accId--' + invoiceRecord.Bill_To__c+'--'+acc.Id)  ;
       System.debug('checking accId--Care_Of__c--' + invoiceRecord.Care_Of__c+'---'+acc.Id)  ;             
        if(invoiceRecord.Bill_To__c != null && invoiceRecord.Bill_To__c == acc.Id){
            acct = acc;
           // invoiceRecord.Bill_To_Address1__c = acct.BillingStreet +', '+ acct.BillingCity +', '+ acct.BillingState +' '+ acct.BillingPostalCode;
            if( invoiceRecord.Bill_to_Tax_Group__c == null ){
                invoiceRecord.Bill_to_Tax_Group__c = acct.Tax_Group__c;
            }
            invoiceRecord.Bill_To_Address1__c ='';
            if(acc.BillingStreet != null )
            invoiceRecord.Bill_To_Address1__c = invoiceRecord.Bill_To_Address1__c+ acc.BillingStreet +'\r\n'; 
              if(acc.BillingCity != null )
            invoiceRecord.Bill_To_Address1__c = invoiceRecord.Bill_To_Address1__c+  acc.BillingCity +', ';
            if(acc.BillingState != null )
             invoiceRecord.Bill_To_Address1__c = invoiceRecord.Bill_To_Address1__c+ acc.BillingState +' ';
            if(acc.BillingPostalCode != null )
             invoiceRecord.Bill_To_Address1__c = invoiceRecord.Bill_To_Address1__c+ acc.BillingPostalCode;
            PrePopTxRate(); 
            
            if(acc.Billing_Notes__c != invoiceRecord.Billing_Requirement__c)
                invoiceRecord.Billing_Requirement__c = acc.Billing_Notes__c;

            System.debug('inside--'+invoiceRecord.Bill_To_Address1__c);
        } else if(invoiceRecord.Bill_To__c == null ){
            invoiceRecord.Bill_To_Address1__c = '';
            invoiceRecord.Bill_to_Tax_Group__c = null;
            sTaxGroupRate = '';
        }

        if(invoiceRecord.Care_Of__c != null && invoiceRecord.Care_Of__c == acc.Id){
            invoiceRecord.Care_of_Address1__c = '';
            if(acc.BillingStreet != null )
            invoiceRecord.Care_of_Address1__c = invoiceRecord.Care_of_Address1__c+ acc.BillingStreet +'\r\n'; 
              if(acc.BillingCity != null )
            invoiceRecord.Care_of_Address1__c = invoiceRecord.Care_of_Address1__c+  acc.BillingCity +', ';
            if(acc.BillingState != null )
             invoiceRecord.Care_of_Address1__c = invoiceRecord.Care_of_Address1__c+ acc.BillingState +' ';
            if(acc.BillingPostalCode != null )
             invoiceRecord.Care_of_Address1__c = invoiceRecord.Care_of_Address1__c+ acc.BillingPostalCode;
        } else if(invoiceRecord.Care_Of__c == null ){
            invoiceRecord.Care_of_Address1__c = '';
        }
    }
}
    
    public void PrePopTxRate(){
        if(invoiceRecord.Bill_to_Tax_Group__c != null){
            Tax_Group__c txGrpQry = [Select Tax_Rate__c from Tax_Group__c WHERE Id =:invoiceRecord.Bill_to_Tax_Group__c];
            Decimal txRate = txGrpQry.Tax_Rate__c;
            sTaxGroupRate = String.valueOf(txRate.stripTrailingZeros()) + '%';
        }
    }
  
    //method that will return value of fields related to the CC to Account Lookup field    
    public void PrePopCC(){
        //system.debug('^^ ' + conID);
        sMailStr = '';
        if(invoiceRecord.CC_Account__c != null) {
            Account acct2 = [Select a.BillingStreet, a.BillingState, a.BillingPostalCode, 
                           a.BillingCountry, a.BillingCity From Account a WHERE a.Id =:invoiceRecord.CC_Account__c LIMIT 1];

            sMailStr = acct2.BillingStreet +', '+ acct2.BillingCity +', '+ acct2.BillingState +' '+ acct2.BillingPostalCode;
        }
    } 

    //Create 3 empty Invoice Line Items
    public void createLineItem(){       
        integer i;
        for(i = 0;i<3;i++){
             Invoice_Line_Item__c inv = new Invoice_Line_Item__c();
             WrapperClass wc = new WrapperClass(i,inv);
             wc.inv.Order__c = i+1;
             wc.inv.Amount__c = 0;
             WrapInvoice.add(wc);
        }
    }
    //Method for delete button of the VF page...add deleted items to temporary list(delInvoiceLineItems)
    //temp list will be used to delete records once user hits save
    public void deleteLineItem(){
        delInvoiceLineItem = new List<Invoice_Line_Item__c>();
        if(wrapInvoice.size()>0){
            for(integer i=0;i<wrapInvoice.size();i++){ 
                if(count==wrapInvoice[i].indx){
                    if(wrapInvoice[i].inv.id!=null){
                    delInvoiceLineItem.add(wrapInvoice[i].inv);
                    }
                    wrapInvoice.remove(i);

                }
                resetLineItemOrder();
            }
          if(wrapInvoice.size()==0){
              createLineItem();
          }
        }
    }
    //reset order of Line items...Line Items must always start at 1
    public void resetLineItemOrder(){
        for(integer i=0;i<wrapInvoice.size();i++){
            wrapInvoice[i].inv.Order__c = i+1;
        }
    
    }
    
    //Method for adding empty line items to pageblocktable 
    public void addLineItem(){
        Invoice_Line_Item__c inv = new Invoice_Line_Item__c();
        WrapperClass wc = new WrapperClass(WrapInvoice.size()+1,inv);
        WrapInvoice.add(wc);
        resetLineItemOrder();

    }
    
    
    public PageReference quickSaveInvoice(){  
        PrePopData();
        PrePopCC();
        try{
            system.debug(extCon.getRecord());
            ExtCon.getRecord();
            ExtCon.save();
            //upsert invoiceRecord;
            saveLineItem(ExtCon.getID());
        }catch(Exception e){
            ApexPages.Message emsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());    
            ApexPages.addMessage(emsg);
        }        
         //setup();
         return null;
    }
    
    public pageReference saveInvoice(){
        PrePopData();
        PrePopCC();
        System.debug('**BillTOTaxGroup*' + InvoiceRecord.Bill_To_Tax_Group__c);
        try{
            ExtCon.getRecord();
            ExtCon.save();
            //upsert invoiceRecord;
            saveLineItem(ExtCon.getID());
        } catch(exception e){
            ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(ErrorMsg);
        }
        PageReference pv = ExtCon.view();
       
        return pv;
    }
    
    public void saveLineItem(ID invoiceID){ 
  
        List<Invoice_Line_Item__c> saveInvoiceLineItem = new List<Invoice_Line_Item__c>();
        // Invoice__c newInvoice = [Select Tax_Rate__c from Invoice__c WHERE Id=:ExtCon.getID()];

        //try{
        for(WrapperClass wc:wrapInvoice){
            wc.inv.Name = wc.inv.PickListName__c;
            if(wc.inv.PickListName__c != null && wc.inv.PickListName__c != '' && wc.inv.Description__c != null && wc.inv.Description__c != '' && wc.inv.Name != null && wc.inv.Name != ''){
                if(wc.inv.id==null){
                    wc.inv.Invoice__c = invoiceID;
                }
                
                //Check values
                if(wc.inv.Note__c == true){
                    wc.inv.Taxable__c = false;
                }else if(wc.inv.IsCredit__c == true){
                    wc.inv.Taxable__c = false;
                }
                /* // EWL 2013-05-21 : Just accept the taxable status that the user entered
                else if(wc.inv.Amount__c == 0){
                    wc.inv.Taxable__c = false;
                }else if(newInvoice.Tax_Rate__c == 0){
                    wc.inv.Taxable__c = false;
                } else {
                    wc.inv.Taxable__c=true;
                }
                */
                saveInvoiceLineItem.add(wc.inv);
            }

        }
        
        upsert saveInvoiceLineItem;
        if(delInvoiceLineItem!=null){
            delete delInvoiceLineItem;
        }
       // } catch(exception e){
           // ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
           // ApexPages.addMessage(ErrorMsg);
        
       // }
    }
     
    public class WrapperClass{
        public Integer indx{get;set;}
        public Invoice_Line_Item__c inv{get;set;}    
        public WrapperClass(Integer indx,Invoice_Line_Item__c invoice){
            this.indx = indx;
            this.inv = invoice;
        }
    
    }
}