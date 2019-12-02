global class Econz_SchRetryBatch implements Schedulable {
    /**
     * @description Executes the scheduled Apex job. 
     * @param sc contains the job ID
     */ 
    global string condition;
    global Econz_SchRetryBatch(){
    }
    global Econz_SchRetryBatch(string condition_IN){
        condition = condition_IN;
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ECONZ_Integration_RetryBatch(condition),1);
    }
}