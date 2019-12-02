global class ScheduleBatchToSendYearlyQuotaEmail implements Schedulable{

    global void execute(SchedulableContext sc) {        
        BatchToSendYearlyQuotaEmailReminders b = new BatchToSendYearlyQuotaEmailReminders();        
        database.executebatch(b);        
    }
}