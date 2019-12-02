/*
Version : 1.0
Company : CloudSherpas
Date : 19 AUG 2013
Author : Ma. Katrina B. Atanacio 
Description : Handler class for JobContactTrigger
History : 1.0 - 19 AUG 2013 - MKBA - Created.
*/

public class JobContactHandler {
    /**
    * @description Method to Auto-populate Job Account Lookup field based on Job Contact
    * @param jobContactList A collection of Job_Contact__c records for insert/update
    */
    public static void populateJobAccount(List<Job_Contact__c> jobContactList){
    	//Retrieve all Contact IDs in context
    	Set<Id> contactIdSet = new Set<Id>();    	 
    	for(Job_Contact__c temp : jobContactList) { 
    		contactIdSet.add(temp.Contact__c); 
    	}
    	
        if( !contactIdSet.isEmpty() ){
            //Create Contact ID - Instance Map 
            Map<Id,Contact> contactIdInstanceMap = new Map<Id,Contact>([SELECT Id, AccountId 
                														FROM Contact WHERE Id IN :contactIdSet]);
            
            //Set Job Account field for each record    
            for(Job_Contact__c currJC : jobContactList) {
                if (currJC.Contact__c == null || currJC.Job_Acct__c != null) continue;
                Contact relContact = contactIdInstanceMap.get(currJC.Contact__c); 
                currJC.Job_Acct__c = relContact.AccountId; 
            }
        }
    }
}