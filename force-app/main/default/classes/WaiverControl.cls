/*****************************************************************************
* Description: Contains helper functions for the ATICreateWaiverOrLetterController
*			   and the ATIWaiverApprovedTrigger.
* Author      : Eric Schrage (Perficient)
* Date        : 08/10/2015
* Version     : 1.0
*
* Version History:
*
*****************************************************************************/

public with sharing class WaiverControl {
	public static void SetSignatureUserFromApprovedById(List <Waiver__c> waivers){
		for (Waiver__c w : waivers) {
			//check approver id
				system.debug('Id of the approver:' + w.Approved_By_Id__c);
				if (w.Approved_By_Id__c!=null) {
					User u = [SELECT Id FROM User WHERE Id=:w.Approved_By_Id__c LIMIT 1];
					system.debug('User:' + u);
					//set signature to approver id
					if (u != null) {
						w.User_Signature__c = u.Id;
						w.Signature_Date__c = Date.today();
					}
				}
			
			}
	}
}