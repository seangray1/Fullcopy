global class BatchToUpdateLastYrsRevenueOnAcc implements Database.batchable<AggregateResult>{

	global Iterable<AggregateResult> start(Database.batchableContext info){
        // just instantiate the new iterable here and return
        return new AggregateResultIterable();
    }    
	  
    global void execute(Database.BatchableContext info, List<AggregateResult> scope){
        List<Account> accountsToUpdate = new List<Account>();
        
        for( AggregateResult ar : scope ){
			Decimal totalRevenueLastYear = (Decimal) ar.get('expr1');
			Integer totalJobsLastYear = (Integer) ar.get('expr0');
			if( totalRevenueLastYear > 0 || totalJobsLastYear > 0 ){
                accountsToUpdate.add( new Account( Id = (Id) ar.get('Account__c'), 
                                                   Number_of_Jobs_Last_Year__c = totalJobsLastYear, 
                                                   Job_Revenue_Last_Year__c = totalRevenueLastYear ));
                //system.debug('+++++++accountsToUpdate'+accountsToUpdate);
            }
        }
                                     
        if( !accountsToUpdate.isEmpty() ){
        	Database.update( accountsToUpdate, false); 
        }
                
    }     
    
    global void finish(Database.BatchableContext info){     
    } 
    
    global class AggregateResultIterable implements Iterable<AggregateResult> {
        global Iterator<AggregateResult> Iterator(){
            return new AggregateResultIterator();
       }
    }

    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results {get;set;}
        Integer index {get; set;} 
                
        global AggregateResultIterator() {
            index = 0;
            String q = 'SELECT Account__c, Count(Id), SUM(Amount__c) FROM ATI_Job__c '+ 
            	   	   'WHERE CreatedDate = LAST_YEAR GROUP BY Account__c';
            results = Database.query(q); 
            //system.debug('+++++++results'+results);
        } 
        
        global boolean hasNext(){ 
           return results != null && !results.isEmpty() && index < results.size(); 
        }    
        
        global AggregateResult next(){ 
            return results[index++];            
        }       
    }    
}