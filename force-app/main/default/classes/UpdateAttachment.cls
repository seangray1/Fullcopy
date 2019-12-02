global class UpdateAttachment implements Database.Batchable<sObject> {
    global List<String> attachmentIds;
    String OpportunityParentID;
    String atiQuery;
    
    global UpdateAttachment(List<String> Ids) {
    	this.attachmentIds = Ids;
	}
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string query = 'SELECT Body,Name,ParentId FROM Attachment WHERE ParentId IN: attachmentIds';
         return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Attachment> Attachments) {
         Attachment[] insertAttList = new Attachment[]{};
		for (Attachment file : Attachments) {
            OpportunityParentID = file.parentID;
            atiQuery = 'Select Id from ATI_Job__c where ReferenceId__c = \''+OpportunityParentID+'\' Limit 1';
            ATI_Job__c[] AtiJobs = Database.query(atiQuery);
            
    		if(AtiJobs.size() >= 1){
            	Attachment tempAttachment = New Attachment(Name = file.name, body = file.body);
				tempAttachment.parentID = AtiJobs[0].Id;
                 insertAttList.add(tempAttachment);
            }
         }
        
        	if(insertAttList.size() > 0)
       		{
            	insert insertAttList;
       		}
    }

    global void finish(Database.BatchableContext bc) {

    }
}