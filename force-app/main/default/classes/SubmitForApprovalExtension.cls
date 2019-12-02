public without sharing class SubmitForApprovalExtension {
    public Id objId { get; set; }
    public String doLock { get; set; }
    public SubmitForApprovalExtension(){
        objId = ApexPages.currentPage().getParameters().get('id');
        doLock = Apexpages.currentPage().getParameters().get('lock');
    }
    
    public PageReference submitForApproval(){
        try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(objId);
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            if( doLock == '0' ){
                Approval.Unlock(objId);
            }
        }catch( DmlException ex ){
            for( Integer i=0; i<ex.getNumDml(); i++ ){                
                Apexpages.addMessage( new ApexPages.message( Apexpages.Severity.ERROR, ex.getDmlMessage(i) ) );
            }
            return null;
        }catch( Exception ex ){
            Apexpages.addMessage( new ApexPages.message( Apexpages.Severity.ERROR, ex.getMessage() ) );
            return null;
        }
        return new PageReference( '/' + objId );
    }
    
    @AuraEnabled
    public static sObject getsObject(ID ObjectId){
        
        String sObjName = ObjectId.getSObjectType().getDescribe().getName();
        
        if(sObjName == 'ATI_Job__c'){
            ATI_Job__c job = (ATI_Job__c)Database.query('SELECT Id FROM ATI_Job__c where Id =: ObjectId LIMIT 1');
            return job;
        }
        else if(sObjName == 'Contact'){
                Contact con = (Contact)Database.query('Select Id from Contact where Id =: ObjectId limit 1');
                return con; 
        }
        else
            return null;



    }
}