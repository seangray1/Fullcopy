/*
Versoin 1.0
Created by   - Prabha Kalaivani Kannan
Date         - 07/06/2016
Purpose      - Test class for ExpenseReportHandler
*/
@isTest
private class UpdateApprovedBy_Test
{
    private static TestMethod void myUnitTest()
    {
        Test.startTest();
        TestDataUtil.createExpenseApprReq();
        Test.stopTest();
        
        // Assert if 'Approved By' field is updated
        //String actualApprover = [SELECT Id,Approved_By__c FROM Expense__c].Approved_By__c;
        //System.assertEquals(UserInfo.getName(),actualApprover,'Approved By field not updated');
    }
}