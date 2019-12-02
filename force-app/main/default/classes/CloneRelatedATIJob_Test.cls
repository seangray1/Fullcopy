@isTest
private class CloneRelatedATIJob_Test {
    @isTest static void TestCloneJob() {
        // Test data setup
        
        TriggerStatus__c status = new TriggerStatus__c();
        status.JobSetJobNumber__c = true;
        insert status;
        
        ATI_Job__c job = new ATI_Job__c(Job_Name__c='Test Job',Project_Site_Address__c='Test Address',Project_Site_State__c='TE',Project_Site_Zipcode__c='A1A1A1',County__c='Test',Project_Site_City__c='Test',Primary_Account__c='Customer',IsCloned__c = true);
        insert job;
                

    }
    
}