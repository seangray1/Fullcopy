/**
 * This class contains unit tests for validating the behavior of MassUpdateController
 * and triggers.
 */
@isTest
private class MassUpdateSimpleControllerTest {


    static testMethod void singleUpdateTest() {
        ATI_Job__c Job = new ATI_Job__c();
        List<ATI_Job__c> JobList = [SELECT name FROM ATI_Job__c LIMIT 20];
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(JobList);
        setCtr.setSelected(new ATI_Job__c[]{Job});
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        System.assertEquals(1, controller.getRecordSize());
        
        System.assert(controller.getFieldTypeOptions().size()>1);
        
        system.assertEquals(1, controller.objsToUpdate.size());
        
        String value = '123test';
        controller.fieldName='name';
        controller.valueToUpdate=value; 
        //controller.convertedFieldData = controller.convertUserInputToFieldData(); 
        controller.step4();
        controller.step5();
        
        System.assert(Job.name==value);
        
        value ='123';
        controller.step3();
        controller.fieldName='amount__c';
        controller.valueToUpdate=value; 
        controller.step4();
        controller.step5();
        
        System.assert(Job.amount__c==decimal.valueOf(value));
        
/*      value ='true';
        controller.fieldName='IsPrivate';
        controller.step3();
        controller.valueToUpdate=value;     
        controller.step4();
        controller.step5();
        
        System.assert(o.IsPrivate); */
        // make sure no exception from display tips
        System.assertEquals(controller.getFieldInfoToDisplay()!=null,true);
                
        value ='2009-4-7';
        controller.fieldName='CloseDate__c';
        controller.valueToUpdate=value;     
        controller.step4();
        controller.step5();
        System.assert(Job.CloseDate__c==Date.valueOf(value));
        
        value ='Closed';
        controller.fieldName='Stage__c';
        controller.valueToUpdate=value;     
        controller.step4();
        controller.step5();
        System.assert(Job.Stage__c=='Closed'); 
    }
        
    static testMethod void linkTest() {
        ATI_Job__c Job = new ATI_Job__c();
        List<ATI_Job__c> JobList = [SELECT name FROM ATI_Job__c LIMIT 20];
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(JobList);
        setCtr.setSelected(new ATI_Job__c[]{Job});
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        
        // verify following exceptions will not cause exception
        System.assert(controller.step1()!=null);
        System.assert(controller.step2()!=null);
        System.assert(controller.step3()!=null);
        System.assert(controller.step4()!=null);
        System.assert(controller.step5()!=null);
        //System.assert(controller.cancel()!=null);
        
        System.assert(controller.getFieldTypeOptions()!=null);
    }
    
    static testMethod void fieldTest() {
        
        List<ATI_Job__c> JobList = new ATI_Job__c[]{};
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(JobList);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        System.assert(controller.cancel()!=null);
        System.assert(controller.getFieldTypeOptions()==null);
    }
    
    static testMethod void miscTest() {
        
        List<ATI_Job__c> JobList = new ATI_Job__c[]{};
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(JobList);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        
        System.assert(controller.getNow(true)!=null);
        System.assert(controller.getNow(false)!=null);
        System.assert(controller.getRecordSize()==0);
        System.assert(controller.getPicklistValues()==null);
    }
}