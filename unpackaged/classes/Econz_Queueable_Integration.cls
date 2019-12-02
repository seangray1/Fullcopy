/**
 * @File Name          : Econz_Queueable_Integration.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/26/2019, 3:15:43 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/26/2019   Sean Gray     Initial Version
**/
public with sharing class Econz_Queueable_Integration implements Queueable, Database.AllowsCallouts {

    private Map<Id,ATI_Job__c> newMap;
    private Map<Id,ATI_Job__c> oldMap;

    public Econz_Queueable_Integration(Map<Id,ATI_Job__c> newMap) {
        this.newMap = newMap;
    }
    
    public Econz_Queueable_Integration(Map<Id,ATI_Job__c> newMap, Map<Id,ATI_Job__c> oldMap) {
        this.newMap = newMap;
        this.oldMap = oldMap;
    }
    
    public void execute(QueueableContext context) {
        system.debug('Record Id is ' + newMap);
    }
}