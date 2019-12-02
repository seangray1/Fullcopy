global class BatchToUpdateLastYrsRevenueOnContacts implements Database.batchable<AggregateResult>{
    
    global Iterable<AggregateResult> start(Database.batchableContext info){
        // just instantiate the new iterable here and return
        return new AggregateResultIterable();
    }
        
    
    global void execute(Database.BatchableContext info, List<AggregateResult> scope){
        List<Contact> contactsToUpdate = new List<Contact>();                
        
        for( AggregateResult ar : scope ){
			Decimal totalRevenueLastYear = (Decimal) ar.get('expr1');
			Integer totalJobsLastYear = (Integer) ar.get('expr0');
			if( totalRevenueLastYear > 0 || totalJobsLastYear > 0 ){
                contactsToUpdate.add( new Contact( Id = (Id) ar.get('Contact__c'), 
                                                   Number_of_Jobs_Last_Year__c = totalJobsLastYear, 
                                                   Job_Revenue_Last_Year__c = totalRevenueLastYear ));
                SYSTEM.debug('contactsToUpdate'+contactsToUpdate);
            }
        }

        if( !contactsToUpdate.isEmpty() ){
        	Database.update( contactsToUpdate, false); 
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
            String q = 'SELECT Contact__c, Count(Id), SUM(Amount__c) '+
				   	   'FROM ATI_job__c WHERE CreatedDate = THIS_YEAR GROUP BY Contact__c';
            results = Database.query(q); 
            system.debug('results'+results);
        } 
        
        global boolean hasNext(){ 
           return results != null && !results.isEmpty() && index < results.size(); 
        }    
        
        global AggregateResult next(){ 
            return results[index++];            
        }       
    }    
}