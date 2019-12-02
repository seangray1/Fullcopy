@isTest
public with sharing class TestATIWaiverApprovedTrigger {
    static testMethod void TestWaiverBeforeUpdate() {
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
            BillingCity = 'SFO',
            BillingCountry = 'USA',
            BillingState = 'CA',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '55555',
            Tax_Group__c = taxGrp.Id,
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
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


        ATI_job__c job = new ATI_job__c(
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

        //set up waiver
        List<RecordType> waiverRTIdList = [SELECT ID FROM RecordType WHERE Name='Waiver' LIMIT 1];
        RecordType waiverRT = null;
        if (waiverRTIdList.size()>=1) {waiverRT = waiverRTIdList[0];}
        System.assert(waiverRT!=null);
        Waiver__c waiver = new Waiver__c(
            RecordType = waiverRT,
            Waiver_Or_Letter_Type__c = 'Unconditional Final Waiver',
            Approved_By_Id__c = UserInfo.getUserId(),
            ATI_Job__c = job.Id
        );
        insert waiver;

        waiver.Approved_By_Id__c = UserInfo.getUserId();
        update waiver;

        //List<Waiver__c> waiverList = new List<Waiver__c> {waiver};
        //TestATIWaiverApprovedTrigger.onBeforeUpdate(waiverList);
        Waiver__c testwav = null;
        List<Waiver__c> tempWavList = [SELECT Signature_Date__c FROM Waiver__c WHERE Id=:waiver.id LIMIT 1];
        if (tempWavList.size()>=1) {testwav = tempWavList[0];} 
       // System.assertEquals(Date.today(), testwav.Signature_Date__c);

    }
}