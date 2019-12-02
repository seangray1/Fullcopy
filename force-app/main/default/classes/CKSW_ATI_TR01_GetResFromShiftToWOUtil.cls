/*
* Utility Class for Trigger CKSW_ATI_TR01_GetResourceFromShiftToWO - s.jeyarammoorthy - 6/28/2016 
*/
public class CKSW_ATI_TR01_GetResFromShiftToWOUtil {
    
    public static void CKSWInsert(List<CKSW_BASE__Shift__c> lstShift, Map<Id,CKSW_BASE__Shift__c> mapShift){
        List<Work_Order__c> workOrdersToUpdate = new List<Work_Order__c>();
        //Profile profile = [Select p.Name, p.Id From Profile p where name =: 'Ops - Supervisor'];
        Set<Id> resourceIds = new Set<Id>();
        Set<Id> workOrderIds = new Set<Id>();
        for (CKSW_BASE__Shift__c shift : lstShift) {
            resourceIds.add(shift.CKSW_BASE__Resource__c);
            workOrderIds.add(shift.Work_Order__c);
        }
        
        Map<Id, Work_Order__c> woMap = new Map<Id, Work_Order__c>([SELECT Id, Assigned_To__c 
                                                                   FROM Work_Order__c 
                                                                   WHERE Id in: workOrderIds]);
        List<CKSW_BASE__Resource__c> resourcesList = [SELECT Id, CKSW_BASE__User__c, CKSW_BASE__User__r.ProfileId 
                                                      FROM CKSW_BASE__Resource__c 
                                                      WHERE Id in: resourceIds];
        Map<Id, Id> resourceIdToUserIdMap = new Map<Id,Id>();
        
        for (CKSW_BASE__Resource__c res : resourcesList) {
            //hard coded Ops - Supervisor ProfileId because of validation rule on Assigned_To__c field in Work_Order__c
            //if (res.CKSW_BASE__User__r.ProfileId == profile.Id) {
            resourceIdToUserIdMap.put(res.Id, res.CKSW_BASE__User__c);
            //}
        }
        if( !resourceIdToUserIdMap.isEmpty() && !woMap.isEmpty() ){
            for (CKSW_BASE__Shift__c shift : lstShift) {
                if (shift.Work_Order__c != null && shift.CKSW_BASE__Resource__c != null) {
                    Work_Order__c relatedWO = woMap.get(shift.Work_Order__c);
                    if (resourceIdToUserIdMap.get(shift.CKSW_BASE__Resource__c) != null) {
                        relatedWO.Assigned_To__c = resourceIdToUserIdMap.get(shift.CKSW_BASE__Resource__c);    
                        workOrdersToUpdate.add(relatedWO);
                    }
                }
            }
            if( !workOrdersToUpdate.isEmpty() ){
            	update workOrdersToUpdate;  
            }
        }
    }
    public static void CKSWUpdate(List<CKSW_BASE__Shift__c> lstShift, Map<Id,CKSW_BASE__Shift__c> mapShift){
        List<Work_Order__c> workOrdersToUpdate = new List<Work_Order__c>();
        //Profile profile = [Select p.Name, p.Id From Profile p where name =: 'Ops - Supervisor'];
        Set<Id> resourceIds = new Set<Id>();
        Set<Id> workOrderIds = new Set<Id>();
        for (CKSW_BASE__Shift__c shift : lstShift) {
            resourceIds.add(shift.CKSW_BASE__Resource__c);
            workOrderIds.add(shift.Work_Order__c);
        }
        if( !workOrderIds.isEmpty() ){
        	Map<Id, Work_Order__c> woMap = new Map<Id, Work_Order__c>([SELECT Id, Assigned_To__c 
                                                                   FROM Work_Order__c 
                                                                   WHERE Id in: workOrderIds]);
            if( !resourceIds.isEmpty() ){
            	List<CKSW_BASE__Resource__c> resourcesList = [SELECT Id, CKSW_BASE__User__c, CKSW_BASE__User__r.ProfileId 
                                                              FROM CKSW_BASE__Resource__c 
                                                              WHERE Id in: resourceIds];
                
                Map<Id, Id> resourceIdToUserIdMap = new Map<Id,Id>();
                for (CKSW_BASE__Resource__c res : resourcesList) {
                    //hard coded Ops - Supervisor ProfileId because of validation rule on Assigned_To__c field in Work_Order__c
                    //if (res.CKSW_BASE__User__r.ProfileId == profile.Id) {
                    resourceIdToUserIdMap.put(res.Id, res.CKSW_BASE__User__c);
                    //}
                }
                if(!resourceIdToUserIdMap.isEmpty() && !woMap.isEmpty() ){
                    for (CKSW_BASE__Shift__c shift : lstShift) {
                        CKSW_BASE__Shift__c oldShift = mapShift.get(shift.Id); 
                        if (shift.Work_Order__c != null && shift.CKSW_BASE__Resource__c != null) {
                            if (oldShift.CKSW_BASE__Resource__c != shift.CKSW_BASE__Resource__c) {
                                Work_Order__c relatedWO = woMap.get(shift.Work_Order__c);
                                if (resourceIdToUserIdMap.get(shift.CKSW_BASE__Resource__c) != null) {
                                    relatedWO.Assigned_To__c = resourceIdToUserIdMap.get(shift.CKSW_BASE__Resource__c);    
                                }    
                                else {
                                    relatedWO.Assigned_To__c = null;    
                                }
                                workOrdersToUpdate.add(relatedWO);                        
                            }
                        }
                    }
                    if( !workOrdersToUpdate.isEmpty() ){
                    	update workOrdersToUpdate;    
                    }
                }
            }
        }
    }
}