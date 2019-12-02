global class ScheduleBatchToUpdateAEBonusOnForecasts implements Schedulable{

    global void execute(SchedulableContext sc) {        
		BatchToUpdateAEBonusOnForecasts b = new BatchToUpdateAEBonusOnForecasts();
        Database.executeBatch(b);
    }

}