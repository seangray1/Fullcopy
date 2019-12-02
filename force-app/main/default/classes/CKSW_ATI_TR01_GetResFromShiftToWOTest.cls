/*
* Test Class for Trigger CKSW_ATI_TR01_GetResourceFromShiftToWO - s.jeyarammoorthy - 6/28/2016 
*/
@isTest()
public class CKSW_ATI_TR01_GetResFromShiftToWOTest {
    
    public static Testmethod void testCKSW_ATI_TR01_GetResFromShiftToWO(){
        
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        
        Integer numToInsert =50;        
        //Create Account
         List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        List<Contact> con = TestDataUtil.createContacts(1, true, new Map<String, String>{'accountId' => accounts[0].Id});   
     
        List<ATI_Job__c> lstjob = TestDataUtil.createjob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
        
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = lstjob[i];
            job.RecordTypeId = rtypes[0].Id;
            job.Project_Site_Contact_Name__c = con[0].id;
            job.Project_Site_Contact_Account__c = accounts[0].Id;

        }
        update lstjob; 
        
        
        //Create Shift location
        CKSW_BASE__Location__c location = new CKSW_BASE__Location__c();
        location.Name ='test_location';
        insert location;
        
        //Create User
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      /*  User tempUser = TestDataUtil.createUsers(1, false, new Map<String, String>())[0];
        tempUser.ProfileId = prof.Id;
        insert tempUser;   */
        
         List<User> users = new List<User>();
            for( Integer i = 0; i < 10; i++ ) {
                User u = new User(
                    LastName='LastName_' + i, 
                    Alias='User_' + i, 
                    Email='test_' + i + '@gmail.com', 
                    UserName='testcaseuser_' + i + '@gmail.com',  
                    CommunityNickname='NickName_' + i,
                    Department = 'Some Department',
                    EmailEncodingKey = 'ISO-8859-1',
                    TimeZoneSidKey = 'America/Los_Angeles', 
                    LocaleSidKey = 'en_US', 
                    LanguageLocaleKey = 'en_US',
                    IsActive = true);
                    u.ProfileId = prof.Id;
                users.add(u);
            }
            
            insert users;
        
        //Create Shift Resources
        CKSW_BASE__Resource__c ckswResource = new CKSW_BASE__Resource__c();
        ckswResource.Name= 'ckswResource1';
        ckswResource.CKSW_BASE__Location__c = location.id;
        //ckswResource.CKSW_BASE__User__c = tempUser.id;
        ckswResource.CKSW_BASE__User__c = Users[0].id;
        insert ckswResource;
        
        CKSW_BASE__Resource__c ckswResource2 = new CKSW_BASE__Resource__c();
        ckswResource2.Name= 'ckswResource2';
        ckswResource2.CKSW_BASE__Location__c = location.id;
        //ckswResource2.CKSW_BASE__User__c = tempUser.id;
        ckswResource.CKSW_BASE__User__c = Users[0].id;
        insert ckswResource2;
        
        //Get RecordType id
        Recordtype workOrderRecordType =[select id from recordtype where name = 'Construction Work Order' LIMIT 1];
        
        //Create WorkOrder
        List<Work_Order__c> lstWorkOrder = new List<Work_Order__c>();
        for(Integer i=0;i<numToInsert;i++){
            Work_Order__c ckswWorkorder = new Work_Order__c();
            ckswWorkorder.RecordTypeId = workOrderRecordType.id;
            ckswWorkorder.Requested_Start_Date_Time__c = system.now();
            ckswWorkorder.ATI_Job__c = lstjob[0].id;
            lstWorkOrder.add(ckswWorkorder);
        }
        insert lstWorkOrder;
        
        //Create Shift object
        List<CKSW_BASE__Shift__c> ckswBaseShift = new List<CKSW_BASE__Shift__c>();
        for(Integer i=0; i<numToInsert ;i++){
            CKSW_BASE__Shift__c ckswTestBaseShift = new CKSW_BASE__Shift__c();
            ckswTestBaseShift.CKSW_BASE__Location__c = location.Id;
            ckswTestBaseShift.CKSW_BASE__Start__c  = system.now();
            ckswTestBaseShift.CKSW_BASE__Finish__c = system.now()+ 1;  
            ckswTestBaseShift.CKSW_BASE__Resource__c = ckswResource.Id;
            ckswTestBaseShift.Work_Order__c = lstWorkOrder[i].id;
            ckswBaseShift.add(ckswTestBaseShift);
        }
        insert ckswBaseShift;
        //Start Test
        Test.startTest();
        
        //Update shift
        for(CKSW_BASE__Shift__c shift:ckswBaseShift ){
            shift.CKSW_BASE__Finish__c = system.now()+ 2;  
            shift.CKSW_BASE__Resource__c = ckswResource2.Id;
        }
        try{
            Database.SaveResult[] updateResults = Database.update(ckswBaseShift,false);
            for(Database.SaveResult result : updateResults){
                system.assert(result.isSuccess()); 
            }
        }catch (Exception e){
            system.debug(LoggingLevel.DEBUG, 'error while updating.Trigger status'+ e.getStackTraceString());
        }
        
        //Delete shift
        try{
            Database.DeleteResult[] deleteResults = Database.delete(ckswBaseShift,false);
            for(Database.DeleteResult result : deleteResults){
                system.assert(result.isSuccess()); 
            }
        }catch (Exception e){
            system.debug(LoggingLevel.DEBUG, 'error while deleting.Trigger status'+ e.getStackTraceString());
        }
        //Stop test
        test.stopTest();
    } 
}