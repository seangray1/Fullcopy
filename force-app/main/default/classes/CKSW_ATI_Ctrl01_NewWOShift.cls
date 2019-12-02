global class CKSW_ATI_Ctrl01_NewWOShift {
CKSW_BASE__Shift__c objShift {get; set;}
    Work_Order__c objWorkOrder;
    Id user;
    public Integer numberOfDuplicates{get;set;}
    
    public CKSW_ATI_Ctrl01_NewWOShift(ApexPages.StandardController stdController) {
       numberOfDuplicates = 1;
       objShift = (CKSW_BASE__Shift__c)stdController.getRecord();
       try{
           Work_Order__c wo = [select Id, Requested_Start_Date_Time__c, End_Date_Time__c, Office3__r.Name from Work_Order__c where Id =: ApexPages.currentPage().getParameters().get('WorkOrderId') limit 1];
           if (wo != null) {
               objShift.CKSW_BASE__Start__c = wo.Requested_Start_Date_Time__c;
               objShift.CKSW_BASE__Finish__c = wo.End_Date_Time__c;
               //objShift.CKSW_BASE__Location__c = [Select Id from CKSW_BASE__Location__c where Name =: wo.Office3__r.Name limit 1].Id;
               //objShift.CKSW_BASE__Start__c = Datetime.newInstance(Long.valueOf(ApexPages.currentPage().getParameters().get('Start')) );
               //objShift.CKSW_BASE__Finish__c = Datetime.newInstance(Long.valueOf(ApexPages.currentPage().getParameters().get('Finish')) );
               //objShift.CKSW_BASE__Location__c = Datetime.newInstance(Long.valueOf(ApexPages.currentPage().getParameters().get('Finish')) );
           }
       }catch(Exception ex){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Couldn\'t parse date parameter'));
       }
        
       try{
           objShift.ATI_Job__c = ApexPages.currentPage().getParameters().get('JobId');
           system.debug('JobId-----'+objShift.ATI_Job__c);
           objShift.CKSW_BASE__Gantt_Label__c = [select Id, Name From ATI_Job__c where Id =: ApexPages.currentPage().getParameters().get('JobId') limit 1].Name;
       }catch(Exception ex){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Wrong Job Id'));
       }
        
       try{
           user = ApexPages.currentPage().getParameters().get('UserId');
           if (user != null) {
                List<CKSW_BASE__Resource__c> resources = [select Id, CKSW_BASE__Location__c From CKSW_BASE__Resource__c where CKSW_BASE__User__c =: user limit 1];
                if (resources != null && resources.size() == 1){
           		    objShift.CKSW_BASE__Resource__c = resources[0].Id;
           		    if (resources[0].CKSW_BASE__Location__c != null) objShift.CKSW_BASE__Location__c = resources[0].CKSW_BASE__Location__c;
           		    else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Can\'t find Location according to Resource'));
                }
                else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Can\'t Resource according to User id'));
           }
       }catch(Exception ex){
			           
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Can\'t find Resource according to User id'));
       }
        
       try{
           objShift.Work_Order__c = ApexPages.currentPage().getParameters().get('WorkOrderId');
       }catch(Exception ex){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Wrong Work Order Id'));
       }
    }
    
    public pageReference createWorkOrderShifts() {
        List<CKSW_BASE__Shift__c> shiftsList = new List<CKSW_BASE__Shift__c>();
        
        for (Integer i = 0; i < numberOfDuplicates; i++) {
            CKSW_BASE__Shift__c shift = objShift.clone(false, true);
            shiftsList.add(shift);
        }
        try{
            insert shiftsList;
            return returnToOrigination();
        }catch(DmlException ex) {
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
     
    public pageReference cancel() {
        return returnToOrigination();
    }
    
   @ testvisible private pageReference returnToOrigination(){
        PageReference returnPage = new PageReference('/' + ApexPages.currentPage().getParameters().get('WorkOrderId'));  
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /*
     * Added by Tia for lightning compatibility
	 */
    
    @AuraEnabled
    public static Work_Order__c getWorkOrder(String woId){
        Work_Order__c wo = [select Id, Assigned_To__c, ATI_Job__c, Requested_Start_Date_Time__c from Work_Order__c where Id =: woId limit 1];
        return wo;
    }
}