public class SendForSignatureCustomLT {
    
    @AuraEnabled
    public static List<echosign_dev1__Agreement_Template__c> getEchoSignAgreements(String jobId){
        
        ATI_Job__c currentJob = [select Id, Project_Site_State__c from ATI_Job__c where Id=: jobId];
        system.debug('----'+ currentJob);
        system.debug('------'+ jobId);
        if (currentJob != null){
            String stateSearch = '%'+ currentJob.Project_Site_State__c +'%';
            
            return [SELECT  Id, 
                    Name 
                    FROM echosign_dev1__Agreement_Template__c 
                    WHERE echosign_dev1__Master_Object_Type__c = 'ATI_Job__c' 
                    AND (State__c like : stateSearch 
                         OR State__c = '') 
                    Order by Name asc];
        } 
        return null;
    }

}