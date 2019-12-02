@isTest
public class CKSW_ATI_Ctrl01_NewWOShift_Test {
    public static testmethod void method1(){
        System.runAs(new User(Id = userinfo.getUserId())){
            List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                'BillingStreet' => 'Street 12',
                'BillingCity' => 'San Francisco',
                'BillingCountry' => 'USA',
                'BillingPostalCode' => '1234',
                'BillingState' => 'CA' } );
            List<ATI_Job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id,
                'Project_Manager_new__c' => UserInfo.getUserId()});
            CKSW_BASE__Location__c baseLoc = new CKSW_BASE__Location__c();
            baseloc.name = 'TestLoc';
            insert baseLoc;
            Office__c ofc = new Office__c();
            ofc.name = 'testOfc';
            insert ofc;
            Work_Order__c wrkOrder = new Work_Order__c();
            wrkOrder.Requested_Start_Date_Time__c = system.today();
            wrkOrder.End_Date_Time__c = system.today()+5;
            wrkOrder.Office3__c = ofc.Id;
            wrkOrder.Operations_Manager__c = UserInfo.getUserId();
            wrkOrder.ATI_Job__c = jobs[0].id;
            insert wrkOrder;
            CKSW_BASE__Shift__c baseShift = new CKSW_BASE__Shift__c();
            baseShift.CKSW_BASE__Location__c = baseLoc.Id;
            baseShift.CKSW_BASE__Finish__c = system.today();
            baseShift.CKSW_BASE__Start__c = system.today() - 10;
            baseShift.Work_Order__c = wrkOrder.id;
            insert baseShift;
            CKSW_BASE__Resource__c baseResource = new CKSW_BASE__Resource__c();
            baseResource.CKSW_BASE__Location__c = baseLoc.id;
            baseResource.CKSW_BASE__User__c = userinfo.getUserId();
            insert baseResource; 
            System.currentPageReference().getParameters().put('UserId', userinfo.getUserId());
            CKSW_ATI_Ctrl01_NewWOShift obj = new CKSW_ATI_Ctrl01_NewWOShift(new ApexPages.StandardController(baseShift));
            PageReference pageRef = obj.returnToOrigination();
            PageReference pageRef1 = obj.createWorkOrderShifts();
            PageReference pageRef2 = obj.cancel() ;
            CKSW_ATI_Ctrl01_NewWOShift.getWorkOrder(wrkOrder.id) ;
            
        }
    }
}