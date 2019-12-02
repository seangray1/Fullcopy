/**
 * @File Name          : ChatterInfo.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/31/2019, 2:44:36 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/31/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class ChatterInfo {
    @AuraEnabled
    public static Case ChatterJobId(Id recordId) {
        Case cs = [Select Id, ATI_Job__c FROM Case Where Id =: recordId];
        system.debug('Cs is ' + cs);
        return cs;
    }
}