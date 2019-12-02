//Versoin 1.0
//Created by - Prabaharan Periasamy
//Date - 06/30/2016
//Tests tax group functionality , as upon update of one or bulk tax group objects.
//
@isTest  
private class Tax_Group_Test 
{   
    private static User usr;
    
    static 
    {
        usr = [select id,name from user where id =:System.label.TestClassRunAsUserId];
    }
    
    private static TestMethod void testTaxGroupInsert()
    {
        TestDataUtil.setUpAccount();
        Tax_Group__c tg = TestDataUtil.createTaxGroup();
        
        System.runAs(usr)
        {
            Test.startTest();                       
            try
            {
                Database.SaveResult result = Database.insert(tg);
                system.assert(result.isSuccess());
            }
            catch (Exception e)
            {
                system.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
            }
            Test.stopTest();
            Tax_Group__c insertedTg = [SELECT Id,Name,Timberline_Id__c FROM Tax_Group__c];
            System.assertEquals(insertedTg.Name,insertedTg.Timberline_Id__c,'Timberline Id is not copied into Name field');
       }
    }
    
    // BUlk tax group insert
    private static TestMethod void testBulkTaxGroupInsert()
    {
        TestDataUtil.setUpAccount();
        System.runAs(usr)
        {
            Test.startTest();
            try
            {
                List<Tax_Group__c> tgs = TestDataUtil.createBulkTaxGroups();
                List<Database.SaveResult> results = Database.insert(tgs, false);
                for(Database.SaveResult result : results)
                {
                   system.assert(result.isSuccess()); 
                }
           }
           catch(Exception e)
           {
               System.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
           }
           Test.stopTest();
           List<Tax_Group__c> insertedTgs = [SELECT Id,Name,Timberline_Id__c FROM Tax_Group__c];
           for(Tax_Group__c tGrp : insertedTgs)
           {
               System.assertEquals(tGrp.Name,tGrp.Timberline_Id__c,'Timberline Id is not copied into Name field:Timberline Id-'+tGrp.Timberline_Id__c+'@Name-'+tGrp.Name); 
           }
       }
    }
   
    private static TestMethod void testTaxGroupUpdate()
    {
        TestDataUtil.setUpAccount();
        Tax_Group__c tg = TestDataUtil.createTaxGroup();
        
        System.runAs(usr)
        {
            insert tg;
            Test.startTest();
            try
            {
                tg.Name = 'updatedName';
                Database.SaveResult result = Database.update(tg);
                System.assert(result.isSuccess());
            } 
            catch(Exception e)
            {
                System.debug(Logginglevel.WARN, 'exception while updating tax group ' + e.getStackTraceString());
            }
            Test.stopTest();
            Tax_Group__c updatedTg = [SELECT Id,Name,Timberline_Id__c FROM Tax_Group__c];
            System.assertEquals(updatedTg.Name,updatedTg.Timberline_Id__c,'Timberline Id is not copied into Name field');
       }
    }
    
}