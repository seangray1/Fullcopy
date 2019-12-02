global class BatchToConsolidateAccounts implements Database.batchable<sobject>{

    String sobjectName;
    String fieldName;
    
    global BatchToConsolidateAccounts( string objName, string fName ){
        this.sobjectName = objName;
        this.fieldName = fName;
    }
    global Database.QueryLocator start(Database.BatchableContext info){ 
        String q = 'SELECT Id, Master_Account__c FROM Account WHERE Master_Account__c != null';
        return Database.getQueryLocator(q); 
    }     
    global void execute(Database.BatchableContext info, List<Account> scope){
        Map<Id, Account> accountsMap = new Map<Id, Account> (scope);

        List<sobject> objects = getRelatedSObjects( accountsMap, sobjectName, fieldName );              
        if( !objects.isEmpty() ){
            if( sobjectName == 'Attachment' ){
                for( SObject a : objects ){
                    a.Id = null;
                }
                insert objects;

            }else{        
                //Notes and Attachments cannot be updated
                update objects;
            }
        }
                        
    }     
    
    List<Sobject> getRelatedSObjects( Map<Id, Account> accountsMap, String sobjectName, String accFieldName ){
        List<Sobject> objectsToUpdate = new List<Sobject>();
        Set<Id> accountIds = accountsMap.keySet();
        String query = 'SELECT Id, ' ;
        if( sobjectName == 'Attachment' ){
            query += 'Name, Body, ' ;
        }else if( sobjectName == 'EventRelation' || sobjectName == 'EventWhoRelation'){
            query += 'EventId, ' ;
        }else if( sobjectName == 'TaskRelation' || sobjectName == 'TaskWhoRelation'){
            query += 'TaskId,';
        }
        query += accFieldName + ' FROM ' + sobjectName + ' WHERE ' + accFieldName + ' IN :accountIds LIMIT 50000';
        system.debug(query);
        for( Sobject obj : Database.query(query) ){
            Id accId = (Id) obj.get( accFieldName );
            if( accId != null ){
                if( sobjectName == 'Attachment' ){
                    Sobject obj2 = obj.clone();
                    obj2.id = null;
                    obj2.put( accFieldName, accountsMap.get( accId ).Master_Account__c );
                    objectsToUpdate.add( obj );
                }else if( sobjectName == 'EventRelation' || sobjectName == 'EventWhoRelation'){
                    Event ev = new Event( Id = (Id)obj.get('EventId'), WhatId = accountsMap.get( accId ).Master_Account__c );
                    objectsToUpdate.add( ev );
                }else if(sobjectName == 'TaskRelation' || sobjectName == 'TaskWhoRelation'){
                    Task t = new task( Id = (Id)obj.get('TaskId'), WhatId = accountsMap.get( accId ).Master_Account__c );
                    objectsToUpdate.add( t );                    
                }else{
                    obj.put( accFieldName, accountsMap.get( accId ).Master_Account__c );
                    objectsToUpdate.add( obj );
                }
			}
        }
        return objectsToUpdate;
    }
    
    
    global void finish(Database.BatchableContext info){     
    } 
}