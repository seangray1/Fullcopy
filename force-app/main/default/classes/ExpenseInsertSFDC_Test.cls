@isTest(seealldata = true)
public class ExpenseInsertSFDC_Test{
    
    public static testMethod void testExpenseInsertSFDC(){
    
   
        Expense__c expense = new Expense__c(name = 'testing', date__c = system.today());
    insert expense; 
        
    Contact con = [select id, name from Contact limit 1];
    
     Expense_Line_Item__c testline = new Expense_Line_Item__c();
     testLine.Expense__c = expense.id;
     testLine.Name = 'test class';
     testLine.Amount__c = 500;
     testLine.Contact__c = con.id;
     testLine.Date_Of_Expense__c = system.today();
     //testLine.Number_of_item__c = 0;
        
     
     insert testline;
     
   ApexPages.StandardController sc = new ApexPages.standardController(testLine);
   ExpenseInsertSFDC test = new ExpenseInsertSFDC(sc);
   pageReference pr = page.ExpenseLineItem;
        
        pr.getParameters().put('id', testline.id);
        
   test.addrow();
   //test.removerow();     
     
   String nextPage = test.save().getUrl();
        
    //System.assertEquals('/a01Q0000004IKLAIA4', nextPage);    
    
    }
}