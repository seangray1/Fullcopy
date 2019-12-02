@isTest
public class dummyTest { 

    static testMethod void dummyTest(){
        TestDataUtil.createCustomSettings_TriggerStatus();
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];
        RecordType tPersons = [Select Id from RecordType Where Name = 'Person Accounts' and SObjectType = 'Account'];      
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
            ERA__c = true,
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
        map<id,contact> conoldmap = new map<id,contact>();
        conoldmap.put(con.id,con);
        map<id,contact> connewmap = new map<id,contact>();
         Contact con1 = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acc.Id,
             id= con.id,
            Phone = '1234',
             Ownership_Request_Status__c = 'Approved',
            Lunch_and_Learn_Status__c = 'Approved'
        );    
        update con1;
        
        connewmap.put(con1.id,con1);


        ATI_job__c Job = new ATI_job__c(
                Account__c = acc.id,
                Name = 'TestJob',
                Stage__c = 'Estimating',
                CloseDate__c = Date.Today(),
                Job_Name__c = 'Test Job Name',
                Job_Number__c = 'TT-5555555',
                Project_Site_Contact_Name__c = con.id,
                Project_Site_Contact_Account__c = acc.id
        );

        insert Job;
        Invoice__c inv = new Invoice__c(
            //Name = 'TestInvoice',
            ATI_job__c = Job.Id,
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
        
        ATI_job__c cloneJob = new ATI_job__c(
                Account__c = acc.id,
                Name = 'TestJob',
                IsCloned__c = true,
                Parent_Job__c = job.id,
                Stage__c = 'Estimating',
                CloseDate__c = Date.Today(),
                Job_Name__c = 'Test Job Name',
                Job_Number__c = 'TT-5555555',
                Project_Site_Contact_Name__c = con.id,
                Project_Site_Contact_Account__c = acc.id
        );

        insert cloneJob;
        
       
        
        Test.startTest(); 
          Related_ATI_Job__c relatedjob = new Related_ATI_Job__c();
          relatedjob.ATI_ParentJob__c = job.id;
          relatedjob.Cloned_ATI_Job__c = cloneJob.id;
          insert relatedjob;
            List<Contact> cons = new List<Contact> { con };
            ContactTriggerUtility.afterContactInsert( cons);
            ContactTriggerUtility.afterLunchAndLearnApproval(conoldmap,connewmap);
            ContactTriggerUtility.afterContactUpdate( new Map<Id, Contact> ( cons ),  cons);
            ContactTriggerUtility.beforeContactUpdate(new Map<Id, Contact> ( cons ),  new Map<Id, Contact> ( cons));
          
          List<Account> accs = new List<Account> { acc};
            AccountTriggerUtility.afterAccountInsert(accs);
          AccountTriggerUtility.afterAccountUpdate(new Map<Id, Account>(accs), accs);
          List<Invoice__c> invoices = new List<Invoice__c>{ inv };
       //   InvoiceTriggerUtility.beforeInvoiceInsert(invoices);
          List<ATI_job__c> Jobs = new List<ATI_job__c>{ Job };
          JobAEBonusTriggerHandler oe = new JobAEBonusTriggerHandler();
          TaskTriggerUtility.afterTaskInsert( new lIst<Task>{});
            
        contract contr=new contract();
        contr.AccountId = acc.id;
        contr.Status = 'Draft';
        contr.StartDate = Date.newInstance(2019,3,25);
        contr.ContractTerm = 3;
       
        contr.Contract_Type__c = 'ERA';
         List<contract > contractList = new List<contract >();
         contractList .add(contr);
         insert contractList;
            
          ContractTriggerUtility.afterContractInsert( new List<Contract>{});
          ContractTriggerUtility.afterContractInsert( contractList);
          ContractTriggerUtility.afterContractUpdate( new Map<Id, Contract>(), new List<Contract>{});          
          JobTriggerHandler o = new JobTriggerHandler();
        Test.stopTest();
    }
}