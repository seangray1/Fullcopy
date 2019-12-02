@isTest
private class TestATICreateWaiverOrLetterController {
    
    static testMethod void TestNewLetter() {
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];
        RecordType tPersons = [Select Id from RecordType Where Name = 'Person Accounts' and SObjectType = 'Account'];    
        //Create Test Record for Custom Setting
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
            JobSetJobNumber__c= false,
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
        
        Waiver_Settings__c wStat = new Waiver_Settings__c(
            Name = 'Apex Settings',
            Unconditional_Final_Name__c = 'Unconditional Final Waiver',
            Unconditional_Progress_Name__c = 'Unconditional Progress Waiver',
            Conditional_Final_Name__c = 'Conditional Final Waiver',
            Conditional_Progress_Name__c = 'Conditional Progress Waiver',
            Letter_60_Day_Name__c = '60 Day Letter'
        );
        insert wStat;

        Tax_Group__c taxGrp = new Tax_Group__c(
            
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup'   
        );
        insert taxGrp;


         Account acc = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'USA',
            BillingState = 'CA',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '55555',
            Tax_Group__c = taxGrp.Id,
            ShippingCity = 'TestSCity',
            ShippingCountry = 'USA',
            ShippingState = 'CA',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acc.Id,
            Phone = '1234'
        );    
        insert con;   


        ATI_Job__c job = new ATI_Job__c(
                Account__c = acc.id,
                Name = 'TestOpp',
                Stage__c = 'Estimating',
                CloseDate__c = Date.Today(),
                Job_Name__c = 'Test Job Name',
                Job_Number__c = 'TT-5555555',
                Project_Site_Contact_Name__c = con.id,
                Project_Site_Contact_Account__c = acc.id
        );

        insert job;
        Invoice__c inv = new Invoice__c(
            //Name = 'TestInvoice',
            ATI_Job__c = job.Id,
            Due_Date__c = Date.Today(),
            Bill_To__c = acc.Id,
            CC__c = con.Id,
            status__c = 'Ready for Billing'
            
        );
        insert inv;
        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = true,
            Taxable__c = true
        );
        insert invLineItem1;
        Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 0,
            Order__c = 1
        );    
        insert invLineItem2;
        Invoice_Line_Item__c invLineItem3 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Note__c = true,
            Order__c = 1
        );       
        insert invLineItem3;
        Invoice_Line_Item__c invLineItemWC = new Invoice_Line_Item__c(
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Note__c = true,
            Order__c = 1
        );
        
        Waiver__c waiver = new Waiver__c( );
        waiver.Waiver_Or_Letter_Type__c = '60 Day Letter';
        Test.startTest();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(waiver);
        Test.setCurrentPage( Page.ATICreateWaiver );
        
        ApexPages.currentPage().getParameters().put('retURL', '/' + job.id);
        ApexPages.currentPage().getParameters().put('id', waiver.id);
        List<RecordType> letterRTIdList = [SELECT ID FROM RecordType WHERE Name='Letter' LIMIT 1];
        RecordType letterRT = null;
        if (letterRTIdList.size()>=1) {letterRT = letterRTIdList[0];}
        System.assert(letterRT!=null);
        ApexPages.currentPage().getParameters().put('RecordType', letterRT.Id);
        ATICreateWaiverOrLetterController ATIcon = new ATICreateWaiverOrLetterController(controller);
        system.debug(controller);
        //init from ATI_Job__c
        ATI_Job__c parentOpp = null;
        Invoice__c parentInvoice = null;

            List<ATI_Job__c> tempOppList = [SELECT Id, Job_Name__c FROM ATI_Job__c WHERE Id=:job.id LIMIT 1];
            if (tempOppList.size()>=1) {parentOpp = tempOppList[0];} 
            List<Invoice__c> tempInvList = [SELECT Id, Bill_To__c, Bill_To_Attention__c, Bill_To_Address__c, 
                                                   Bill_To_Address1__c, Bill_to_City__c, Bill_to_State__c, Bill_to_Zip__c  
                                            FROM Invoice__c WHERE ATI_Job__c=:job.id ORDER BY CreatedDate DESC LIMIT 1];
            if (tempInvList.size()>=1) {parentInvoice = tempInvList[0];} 
            ATICon.save();
        Test.stopTest();
        waiver = [SELECT Id, RecordTypeId, ATI_Job__c, Invoice__c, Customer__c, Waiver_Owner__c, Billing_Address__c 
                  FROM Waiver__c WHERE ATI_Job__c =:job.id LIMIT 1][0];

        System.assertEquals(ApexPages.currentPage().getParameters().get('RecordType'),waiver.RecordTypeId);
        System.assertEquals(waiver.ATI_Job__c, parentOpp.Id);
        System.assertEquals(waiver.Invoice__c, parentInvoice.Id);
        System.assertEquals(waiver.Customer__c, parentInvoice.Bill_To__c);
        System.assertEquals(waiver.Waiver_Owner__c, parentOpp.Job_Name__c);

        //check letter

        ATIcon.checkLetterType();
        System.assert(ATIcon.renderLetterFields);

        //invoice changed

        ATIcon.invoiceChanged();
        System.assertEquals(waiver.Invoice__c, parentInvoice.Id);

    }
    
    static testMethod void TestNewWaiver() {
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];
        RecordType tPersons = [Select Id from RecordType Where Name = 'Person Accounts' and SObjectType = 'Account'];    
        //Create Test Record for Custom Setting
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
            JobSetJobNumber__c= false,
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
        
        Waiver_Settings__c wStat = new Waiver_Settings__c(
            Name = 'Apex Settings',
            Unconditional_Final_Name__c = 'Unconditional Final Waiver',
            Unconditional_Progress_Name__c = 'Unconditional Progress Waiver',
            Conditional_Final_Name__c = 'Conditional Final Waiver',
            Conditional_Progress_Name__c = 'Conditional Progress Waiver',
            Letter_60_Day_Name__c = '60 Day Letter'
        );
        insert wStat;

        Tax_Group__c taxGrp = new Tax_Group__c(
            
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup'   
        );
        insert taxGrp;


         Account acc = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'USA',
            BillingState = 'CA',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '55555',
            Tax_Group__c = taxGrp.Id,
            ShippingCity = 'TestSCity',
            ShippingCountry = 'USA',
            ShippingState = 'CA',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acc.Id,
            Phone = '1234'
        );    
        insert con;   


        ATI_Job__c job = new ATI_Job__c(
                Account__c = acc.id,
                Name = 'TestOpp',
                Stage__c = 'Estimating',
                CloseDate__c = Date.Today(),
                Job_Name__c = 'Test Job Name',
                Job_Number__c = 'TT-5555555',
                Project_Site_Contact_Name__c = con.id,
                Project_Site_Contact_Account__c = acc.id
        );

        insert job;
        Invoice__c inv = new Invoice__c(
            //Name = 'TestInvoice',
            ATI_job__c = job.Id,
            Due_Date__c = Date.Today(),
            Bill_To__c = acc.Id,
            CC__c = con.Id,
            status__c = 'Ready for Billing'
            
        );
        insert inv;
        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = true,
            Taxable__c = true
        );
        insert invLineItem1;
        Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 0,
            Order__c = 1
        );    
        insert invLineItem2;
        Invoice_Line_Item__c invLineItem3 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Note__c = true,
            Order__c = 1
        );       
        insert invLineItem3;
        Invoice_Line_Item__c invLineItemWC = new Invoice_Line_Item__c(
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Note__c = true,
            Order__c = 1
        );
        
        Waiver__c waiver = new Waiver__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(waiver);
        
        ApexPages.currentPage().getParameters().put('retURL', '/' + inv.id);
        ApexPages.currentPage().getParameters().put('id', waiver.id);
        List<RecordType> waiverRTIdList = [SELECT ID FROM RecordType WHERE Name='Waiver' LIMIT 1];
        RecordType waiverRT = null;
        if (waiverRTIdList.size()>=1) {waiverRT = waiverRTIdList[0];}
        System.assert(waiverRT!=null);
        ApexPages.currentPage().getParameters().put('RecordType', waiverRT.Id);
        ATICreateWaiverOrLetterController ATIcon = new ATICreateWaiverOrLetterController(controller);

        //init from ATI_Job__c
        ATI_Job__c parentJob = null;
        Invoice__c parentInvoice = null;

        List<Invoice__c> tempInvList = [SELECT Id, Due_Date__c, ATI_Job__c, Bill_To__c, Bill_To_Attention__c, Bill_To_Address__c, Bill_To_Address1__c, Bill_to_City__c, Bill_to_State__c, Bill_to_Zip__c  FROM Invoice__c WHERE Id=:inv.Id LIMIT 1];
        if (tempInvList.size()>=1) {parentInvoice = tempInvList[0];} 
        List<ATI_Job__c> tempOppList = [SELECT Id, Job_Name__c, Project_Site_Address_Concat__c FROM ATI_Job__c WHERE Id=:job.Id LIMIT 1];
        if (tempOppList.size()>=1) {parentJob = tempOppList[0];}

        
        System.assertEquals(ApexPages.currentPage().getParameters().get('id'),waiver.Id);
        System.assertEquals(ApexPages.currentPage().getParameters().get('RecordType'),waiver.RecordTypeId);
        System.assertEquals(waiver.ATI_Job__c, parentJob.Id);
        System.assertEquals(waiver.Invoice__c, parentInvoice.Id);
        System.assertEquals(waiver.Customer__c, parentInvoice.Bill_To__c);
        System.assertEquals(waiver.Waiver_Owner__c, parentJob.Job_Name__c);
        System.assertEquals(waiver.Through_Date__c,parentInvoice.Due_Date__c);
        System.assertEquals(waiver.Job_Location__c,parentJob.Project_Site_Address_Concat__c);

        //set waiver type
        waiver.Waiver_Or_Letter_Type__c = 'Unconditional Final Waiver';
        ATIcon.checkWaiverType();
        System.assert(ATIcon.renderUFWaiverFields);

        waiver.Waiver_Or_Letter_Type__c = 'Unconditional Progress Waiver';
        ATIcon.checkWaiverType();
        System.assert(ATIcon.renderUPWaiverFields);

        waiver.Waiver_Or_Letter_Type__c = 'Conditional Final Waiver';
        ATIcon.checkWaiverType();
        System.assert(ATIcon.renderCFWaiverFields);
        System.assertEquals(UserInfo.getUserId(), waiver.User_Signature__c);
        System.assertEquals(Date.today(), waiver.Signature_Date__c);

        waiver.Waiver_Or_Letter_Type__c = 'Conditional Progress Waiver';
        ATIcon.checkWaiverType();
        System.assert(ATIcon.renderCPWaiverFields);
        System.assertEquals(UserInfo.getUserId(), waiver.User_Signature__c);
        System.assertEquals(Date.today(), waiver.Signature_Date__c);
       
    }
}