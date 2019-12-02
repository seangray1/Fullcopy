/*
 *@Auhtor: Narasimha (Perficient)
 *@Created: 17.MAR.2015 
 *@Desc: Single Trigger for Opportunity Object
 */

trigger OpportunityTrigger on Opportunity ( before insert, before update,
                                            after insert,after update,
                                             before delete
                                            ) {                
                                           
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            OpportunityTriggerHandler.handleBeforeInsertUpdate();
        }
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            OpportunityTriggerHandler.handleAfterInsertUpdate();
        }
                
        if(Trigger.isBefore && Trigger.isInsert){
            OpportunityTriggerHandler.handleBeforeInsertOnly();
        }
        
        if(Trigger.isBefore && Trigger.isUpdate){
            OpportunityTriggerHandler.handleBeforeUpdatesOnly();
        }
        
        if(Trigger.isAfter && Trigger.isInsert){
            OpportunityTriggerHandler.handleAfterInsertOnly();
        }
        
        if(Trigger.isAfter && Trigger.isUpdate){
            OpportunityTriggerHandler.handleAfterUpdatesOnly();            
        }      
                
}