/**
 * @File Name          : MilestoneTimeCalculatorTest.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/25/2019, 11:30:57 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/25/2019   Sean Gray     Initial Version
**/
@isTest
private class MilestoneTimeCalculatorTest {
    static testMethod void testMilestoneTimeCalculator() {       
        // Select an existing milestone type to test with
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];     
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        Case c = new Case(priority = 'High', next_action_date_time__c = system.now() + 1);
        insert c;
        MilestonesTriggerHandler calculator = new MilestonesTriggerHandler();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(c.Id, mt.Id);
        //if(mt.name != null && mt.Name.equals('m1')) {
          //  System.assertEquals(actualTriggerTime, 7);
       // }
       // else {
        //    System.assertEquals(actualTriggerTime, 5);
       // }
        c.priority = 'Low';
        update c;
        actualTriggerTime = calculator.calculateMilestoneTriggerTime(c.Id, mt.Id);
        //System.assertEquals(actualTriggerTime, 18);
    }
}