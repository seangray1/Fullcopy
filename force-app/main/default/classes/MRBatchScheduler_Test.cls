/**
* @author           Gangadhar R
* @version          1.0
* @date             14-07-2017
* @status           Developed
* @Description      The purpose of this  class is to unit test the MRBatchScheduler apex class.
**/
@istest
public with sharing class MRBatchScheduler_Test 
{
    static testmethod void Schedule_Test() 
    {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_ScheduleClass', CRON_EXP, new MRBatchScheduler());   
        Test.stopTest();
    }

}