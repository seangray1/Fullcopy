public without sharing class ContactTriggerUtility {
	
	public static string TASK_TYPE_LUNCH_LEARN = 'Lunch and Learn';
    public static void afterContactUpdate( Map<Id, Contact> oldContactsMap, List<Contact> newContacts ){        
    }
    
    public static void afterContactInsert(List<Contact> newContacts) {        
    }
    
    public static void beforeContactUpdate( Map<Id, Contact> oldContactsMap, Map<Id, Contact> newContactsMap ){
        updateContactOwnership( oldContactsMap, newContactsMap.values() );
        afterLunchAndLearnApproval( oldContactsMap, newContactsMap );
    }
        
    private static void updateContactOwnership( Map<Id, Contact> oldContactsMap, List<Contact> newContacts ){        
        for( Contact con : newContacts ){
            Contact oldCon = oldContactsMap.get( con.Id );
            if( con.Ownership_Request_Status__c != oldCon.Ownership_Request_Status__c &&
                con.Ownership_Request_Status__c == 'Approved'){
                if( con.Ownership_Requester_ID__c != null ){
                    con.OwnerId = con.Ownership_Requester_ID__c;
                }
            }
        }
    }

    public static void afterLunchAndLearnApproval( Map<Id, Contact> oldContactsMap, Map<Id, Contact> newContactsMap ){
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for (Contact con : newContactsMap.values()) {
            Contact oldCon = oldContactsMap == null ? null : oldContactsMap.get(con.Id);
            if ( oldCon.Lunch_and_Learn_Status__c != con.Lunch_and_Learn_Status__c  &&
                con.Lunch_and_Learn_Status__c == 'Approved') {
                ownerIds.add(con.OwnerId);
                contactIds.add( con.Id );
            }
        }
        if( !contactIds.isEmpty() ){
    		updateRelatedNonApprovedTasks( contactIds );        
        	for (Contact con : newContactsMap.values()) {
            Contact oldCon = oldContactsMap == null ? null : oldContactsMap.get(con.Id);
            if ((oldCon == null || oldCon.Lunch_and_Learn_Status__c != con.Lunch_and_Learn_Status__c ) &&
                con.Lunch_and_Learn_Status__c == 'Approved') {
                con.Lunch_and_Learn_Status__c = null;
            }
        }
        }
    }   
    
    private static void updateRelatedNonApprovedTasks( Set<Id> contactIds ){
        system.debug(contactIds);
        List<Task> relatedTasks = new List<Task>();
        for( Task t : [ SELECT Id, OwnerId 
                        FROM Task 
                        WHERE WhoId IN :contactIds
                       		AND Lunch_and_Learn_Approval_Date__c = null
        	                AND Type =: TASK_TYPE_LUNCH_LEARN ] ){
        	t.Lunch_and_Learn_Approval_Date__c = Date.today();
			relatedTasks.add( t );
		}
        if( !relatedTasks.isEmpty() ){
            update relatedTasks;
        }              
    }
    
    
    
    
    private static Map<Id, Id> getContactIdsWithOwnerChange( Map<Id, Contact> oldContactsMap, List<Contact> newContacts ){
        Map<id, Id> contactIdsToOwnerIdsMap = new Map<Id, Id>();
        for( Contact con : newContacts ){
            Contact oldCon = oldContactsMap.get( con.Id );
            if( con.OwnerId != oldCon.OwnerId ){
                contactIdsToOwnerIdsMap.put( con.Id, con.OwnerId );
            }
        }
        return contactIdsToOwnerIdsMap;
    }
    
}