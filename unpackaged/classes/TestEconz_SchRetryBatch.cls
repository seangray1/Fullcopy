@istest
public class TestEconz_SchRetryBatch {
 static testMethod void TestEconz_SchRetryBatch() {
     String condition='test';     
        Test.startTest();
     Integer year = system.today().year() + 1;
     String sch = '0 0 0 1 1 ? ' + year;
Id jobId = System.schedule('test_sch_batch', sch, new Econz_SchRetryBatch(''));
        Test.stopTest();
        System.assertNotEquals(null,[select id from CronTrigger]);
    }

}