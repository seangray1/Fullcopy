@isTest(SeeAllData=true)
private class CKSW_ATI_ut_TR01 {
	private static testMethod void WO_Shifts_test() {
	       User u=new User();
           u.Username= Datetime.now().getTime()+'testUser@shiftexpert.com';
           u.LastName= 'test';
           u.FirstName= 'test';
           u.Email= u.Username;
           u.Alias= 'TST';
           u.CommunityNickname= u.Username.substring(0, u.Username .indexOf('@'));
           u.TimeZoneSidKey = 'America/Los_Angeles';
           u.LocaleSidKey = 'en_US';
           u.EmailEncodingKey='ISO-8859-1';
           u.ProfileId = [Select p.Name, p.Id From Profile p where name = 'Ops - Supervisor'].id;
           u.LanguageLocaleKey = 'en_US';
           u.isActive=true;
           insert u;
	           
      System.runAs(u) {
	       Work_Order__c testWO = new Work_Order__c();
           List<Work_Order__c> testWOList = [select Id, ATI_Job__c from Work_Order__c];
           for (Work_Order__c wo : testWOList ) {
                 if (wo.ATI_Job__c != null) {
                       testWO = wo;
                       break;
                 }
           }
        
           CKSW_BASE__Location__c loc = new CKSW_BASE__Location__c();
           loc.Name = 'test location';      
           insert loc;
        
           CKSW_BASE__Resource__c res = new CKSW_BASE__Resource__c();
           res.Name = 'Test Test';
           res.CKSW_BASE__Location__c = loc.Id;
           res.CKSW_BASE__User__c = u.Id;      
           insert res;
        
        
           CKSW_BASE__Shift__c shift = new CKSW_BASE__Shift__c();
           shift.CKSW_BASE__Resource__c = res.Id;
           shift.CKSW_BASE__Location__c = loc.Id;
           shift.CKSW_BASE__Start__c = Datetime.Now();
           shift.CKSW_BASE__Finish__c = Datetime.Now().addHours(5);
           shift.Work_Order__c = testWO.Id;        
           insert shift;
        
        
           testWO = [select Id, Assigned_To__c from Work_Order__c where Id =: testWO.Id];
           system.assertNotEquals(testWO.Assigned_To__c, null);
        
           shift.CKSW_BASE__Resource__c = null;
           update shift;
        
           testWO = [select Id, Assigned_To__c from Work_Order__c where Id =: testWO.Id];
	  }
   }
}