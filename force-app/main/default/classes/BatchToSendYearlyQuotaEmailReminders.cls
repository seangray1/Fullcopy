// batch job to be scheduled every year 90 days before end of the current year - to remind branch managers to update quota on the agents
global class BatchToSendYearlyQuotaEmailReminders implements Database.batchable<SObject> {
	global Database.QueryLocator start(Database.BatchableContext info){ 
        String q = 'SELECT Id FROM User WHERE Profile.Name = \'Executive Management\' and isactive =true';
        return Database.getQueryLocator(q); 
    }     
    global void execute(Database.BatchableContext info, List<User> scope){
        List<User> usersToUpdate = new List<User>();
        for(User u : scope){ 
			u.Send_Anual_Quota_Update_Reminder_Email__c = true;
            usersToUpdate.add( u );
        } 
        if( !usersToUpdate.isEmpty() ){
        	update usersToUpdate; 
        }
    }     
    
    global void finish(Database.BatchableContext info){     
    } 
}