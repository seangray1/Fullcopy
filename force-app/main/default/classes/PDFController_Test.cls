@isTest()
public class PDFController_Test{

    private static testmethod void test_init() {
        
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        List<ATI_job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_job__c job = jobs[i];
            job.RecordTypeId = rtypes[0].Id;

        }
        update jobs;
        
        
        Material_Requisition__c Material = new Material_Requisition__c();
        material.ATI_Job__c = jobs[0].Id;
        material.Current_PDF_Version__c = 0;
        insert material;
        
              
        Material_Requisition_line_item__c lineitem = new Material_Requisition_line_item__c(); 
        lineItem.Material_Requisition__c = material.id;
        insert lineitem;       
     /*   
        String fields = ADCUtil_Base.strJoin(',', PDFController.ADDL_FIELDS, 'Id');
        List<Material_Requisition__c> recs = (List<Material_Requisition__c>)(Database.query('SELECT '+fields+' FROM Material_Requisition__c ORDER BY CreatedDate DESC LIMIT 1'));
        Material_Requisition__c r = recs.size() > 0 ? recs[0] : material;
     */   
        PageReference ref = Page.MaterialReqPDF;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(material);
        
        
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        PDFController controller = new PDFController(std);
        String query = 'SELECT Id, Name,Shipped__c, Returned__c FROM Material_Requisition_line_item__c where Material_Requisition__c =: RecordId  order by CreatedDate ASC';
        controller.setParamsmethod(query);
        
        PDFPreviewController controller2 = new PDFPreviewController(std);
        controller2.formGeneratePDF.cancelPDF();   
        controller2.formGeneratePDF.savePDF(); 
        
        DisplayChildRecordsController component = new DisplayChildRecordsController();
        component.ChildRecordQueryString = query;
        component.ParentPageController = controller; 
        
        Test.stopTest();
        
    } 
    
}