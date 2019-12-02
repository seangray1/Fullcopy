Public class SfObjectHelper{

    public static string GetObjectNameById(Id objId)
    {
        string objName = '';
        
        objName = objId.getSObjectType().getDescribe().getName();
        
        return objName;
    }
    //Get the fields of an object by Record ID.
    public static List<String> GetObjectFieldsById(Id objId)
    {
    
        Map<String, Schema.SObjectField> objectfields = Schema.getGlobalDescribe().get(GetObjectNameById(objId)).getDescribe().fields.getMap();
        
        List<String> objFields = new List<String>(objectFields.keySet());
        return objFields;
    }
    //Get the fields of an object by Record Name
    public static List<String> GetObjectFieldsByName(String Name)
    {
    
        Map<String, Schema.SObjectField> objectfields = Schema.getGlobalDescribe().get(Name).getDescribe().fields.getMap();
        
        List<String> objFields = new List<String>(objectFields.keySet());
        return objFields;
    }
    
    //Get the SObject and it's fields
    public static sObject getRecordById(Id recordId)
    {
        List<String> PrintValue = new List<String>();
        List<String> ADDL_FIELDS = new List<String>();
        
        string objectName = GetObjectNameById(recordId);

        String query = 'Select';
        String fields = '';
        Map<String, Schema.SObjectField> objectfields = Schema.getGlobalDescribe().get(objectname).getDescribe().fields.getMap();
        
        system.debug('This is the SObject Returned:' + Schema.getGlobalDescribe().get(objectname).getDescribe());
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keyset()){
            query += ' '+s+', ';
            fields += s+', ';
                        
            //to print out fields names with blank value
            if(string.valueof(query)==null)
                printValue.add(query);
        }
        
        
        
        // Strip off the last comma if it exists.
        /* if (query.subString(query.Length()-1,query.Length()) == ', '){
        query = query.subString(0,query.Length()-2);
        }*/
        
        query = query.subString(0,query.Length()-2);
        //fields = fields.subString(0,query.Length()-3);
        
        if(string.valueof(fields)==null)
            ADDL_FIELDS.add(fields);
        
        system.debug('This is the query string' + query.subString(0,query.Length()-2));
        
        // Add FROM statement
        query += ' FROM ' + objectName;
        
        // Add on a WHERE/ORDER/LIMIT statement as needed
        query += ' WHERE Id =  \''+ recordId+'\'  LIMIT 1'; // modify as needed   WHERE Id = \'test\' AND HasOpportunityLineItem = true LIMIT 1';
        system.debug('This is the query and all its fields:'+query);
        system.debug('These are the fields with blank values:' + PrintValue);
        
        sObject obj = database.query(query);
        
        return obj;
    }

}