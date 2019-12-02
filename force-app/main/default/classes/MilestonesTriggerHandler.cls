/**
 * @File Name          : MilestonesTriggerHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : sean.gray@atirestoration.com
 * @Last Modified On   : 11/4/2019, 3:01:55 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/4/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class MilestonesTriggerHandler implements Support.MilestoneTriggerTimeCalculator {
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        Case c = [SELECT Next_Action_Date_Time__c FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        if (c.next_action_date_time__c != null) {
            Decimal int12 = (c.Next_Action_Date_Time__c.getTime() - system.now().getTime()) / 60000;
            //  int12.round();
             Integer int1 = Integer.valueOf(int12);
        return int1;
            //divide by 60k
        }
        else{
            return null;
        }
        
    }

}