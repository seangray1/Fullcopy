/*
* Test Class for Trigger UpdateAmountOnLineItem on Expense_Line_Item__c - s.jeyarammoorthy - 6/28/2016 
*/
@isTest
public class UpdateAmountOnLineItem_Test{
    
    public static TestMethod void myUnitTest(){
   		
        //Create Expense
        Expense__c expense = new Expense__c(name = 'test', date__c = system.today());
        insert expense;
        
        //Create ExpenseLineItem
        List<Expense_Line_Item__c> lstExpenseLineItem = new List<Expense_Line_Item__c>();
        for(Integer i=0; i<=50;i++){
            Expense_Line_Item__c LineItem = new Expense_Line_Item__c();
            LineItem.Expense__c = expense.id;
            if(i<25){
                LineItem.Name = 'testing for Update trigger';
            }else{
                LineItem.Name = 'testing for Delete trigger';
            }
            LineItem.Amount__c = 500;
            LineItem.Date_Of_Expense__c = system.today();    
            lstExpenseLineItem.add(LineItem);
        }
        insert lstExpenseLineItem; 
        
        //Start Test
        Test.StartTest();
        
        //Delete ExpenseLineItem
        List<Expense_Line_Item__c> deleteExpenseLineItems =[SELECT id, contact__c, amount__c, Office__c FROM Expense_Line_Item__c WHERE expense__c =:expense.id AND Name = 'testing for Delete trigger'];
        try{
            Database.DeleteResult[] deleteResults = Database.delete(deleteExpenseLineItems,false);
            for(Database.DeleteResult result : deleteResults){
                system.assert(result.isSuccess()); 
            }
        }catch (Exception e){
            system.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
        }
        
        //Set FirstRun to true for fresh Update operation
        LineItemRunner.firstrun=true;
        
        //Update ExpenseLineitem
        List<Expense_Line_Item__c> updateExpenseLineItems =[SELECT id, contact__c, amount__c, Office__c FROM Expense_Line_Item__c WHERE expense__c =:expense.id AND Name = 'testing for Update trigger'];
        for(Expense_Line_Item__c lineItem:updateExpenseLineItems){
            lineItem.amount__c = 45;
            lineItem.Office__c = 'Chicago';    
        }
        try{
            Database.SaveResult[] updateResults = Database.update(updateExpenseLineItems,false);
            for(Database.SaveResult result : updateResults){
                system.assert(result.isSuccess()); 
            }
        }catch (Exception e){
            system.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
        }
        //Stop Test
        Test.stopTest(); 
    }
}