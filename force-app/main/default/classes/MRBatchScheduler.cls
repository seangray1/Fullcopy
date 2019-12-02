/**
 * @author           Gangadhar R.
 * @version          1.0 
 * @date             07/07/2017
 * @Status           Developed
 * @description      This class is used to schedule the SendMRBatch.
 *                   
*/
global class MRBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        SendMRBatch batch = new SendMRBatch();
        ID batchprocessid = Database.executeBatch(batch,200);           
    }
}