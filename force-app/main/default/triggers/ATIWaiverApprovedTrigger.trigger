/*****************************************************************************
* Description: This trigger sets the signature user based on the approved by id set
*               in the approval process.
* Author      : Eric Schrage (Perficient)
* Date        : 08/10/2015
* Version     : 1.0
*
* Version History:
*
*****************************************************************************/

trigger ATIWaiverApprovedTrigger on Waiver__c (before update) {

    if (trigger.isBefore) {

        // before delete
        // if (trigger.isDelete) -- NOTHING TO DO

        // before insert
        //if (trigger.isInsert) -- NOTHING TO DO

        // before update
        if (trigger.isUpdate) {
            WaiverControl.SetSignatureUserFromApprovedById(Trigger.New);
        }
    }

    if (trigger.isAfter) {

        // after delete
        // if (trigger.isDelete) -- NOTHING TO DO

        // after insert
        // if (trigger.isInsert) -- NOTHING TO DO
        
        // after undelete (Be careful - an after insert also fires for these records)
        // if (trigger.isUnDelete) -- NOTHING TO DO
    
        // after update
        //if (trigger.isUpdate)  -- NOTHING TO DO
            

    }
}