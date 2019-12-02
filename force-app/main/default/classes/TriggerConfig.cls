public with sharing class TriggerConfig {
    
    //public static TriggerStatus__c raw = TriggerStatus__c.getInstance();
    public static TriggerStatus__c raw = TriggerStatus__c.getInstance(Userinfo.getUserId());
    
    private static testmethod void test() {
        try {
            update [SELECT Id FROM Account ORDER BY LastModifiedDate DESC LIMIT 2];
        } catch (Exception e) {System.debug('Not a big deal');}
        /*try {
            update [SELECT Id FROM Job__c ORDER BY LastModifiedDate DESC LIMIT 2];
         catch (Exception e) {System.debug('Not a big deal');}*/
        /*try {
            update [SELECT Id FROM Lead ORDER BY LastModifiedDate DESC LIMIT 2];
        } catch (Exception e) {System.debug('Not a big deal');}*/
        try {
            update [SELECT Id FROM ATI_Job__c ORDER BY LastModifiedDate DESC LIMIT 2];
        } catch (Exception e) {System.debug('Not a big deal');}
       /* try {
            update [SELECT Id FROM PMLead__c ORDER BY LastModifiedDate DESC LIMIT 2];
        } catch (Exception e) {System.debug('Not a big deal');}*/
        try {
            update [SELECT Id FROM Task ORDER BY LastModifiedDate DESC LIMIT 2];
        } catch (Exception e) {System.debug('Not a big deal');}
       /* try {
            update [SELECT Id FROM Tax_Group__c ORDER BY LastModifiedDate DESC LIMIT 2];
        } catch (Exception e) {System.debug('Not a big deal');}*/
    }
}