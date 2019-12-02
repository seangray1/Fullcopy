public class ClonesObject {
 
    public static List<String> PrintValue;
    @auraEnabled           
    public static sObject getsObject(ID objectId)
    {
        
        string objectName = getObjectName(objectId);
                               
        if (objectName == 'ATI_Job__c'){
            return cloneOpp(objectId);
        }
        else 
        
            if (objectName == 'Waiver__c'){
            return cloneWaiver(objectId);
        }
        else
            if(objectName == 'Invoice__c'){
            return cloneInvoice(objectID);   
        }
        else {
            return null;
        }
    }
     
    @auraEnabled
    public static sObject cloneOpp(ID objectId)
    {   
        //we only want to clone these specific fields. 
        ATI_Job__c oldJob = [SELECT Id, name, Job_Name__c, Account__c, Contact__r.ID, Lead_Source__c, Description__c, Job_Class__c, Project_Site_Contact_Name__c, Project_Manager__r.id, Branch_Manager__r.id, Project_Site_Contact_Account__c, Office2__r.id, Stage__c, Taken_by__c, Project_type__c, Referred_by__r.id, CloseDate__c, County__c, City_of_LA__c, Project_Site_Address_2__C, Project_site_address__c, Project_site_city__c, Project_site_state__c, Project_site_zipcode__c, Year_Structure_built__c, Date_of_loss__c, Project_Site_Contact_Email__c, no_Email_Available__c, Policy__c, Deductible__c, Claim__c, Cont_P_O_Client_Job__c, PO__c, Send_prelim__c from ATI_job__c Where Id = :objectId];
        
        //ATI_Job__c oldJob = (ATI_Job__c)getRecordById(objectId);
        ATI_Job__c job = (ATI_Job__c)oldJob.clone(false,true,false,false);
      
        
        Id RT = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('New Job (Not Approved)').getRecordTypeId();
        System.debug('This is the query returned:' + RT);
        
        if(RT != null) 
            job.RecordTypeID = RT;
        System.debug('THIS IS THE RECORD TYPE:' + job.recordtype.developername);
         
        job.Stage__c = 'Qualification';
        job.Division__c='';
        job.Name = 'test';
        job.Job_Number_Sequence__c=null;
        //job.Job_Number_Sequence_Group__c='';
        job.Job_Number__c='';
        job.Date_Time_Taken__c= datetime.now();
        job.CloseDate__c= Date.TODAY();
        job.Project_Manager__c=null;
        job.Project_Manager_New__c = null;
        job.Cont_P_O_Client_Job__c =null;
        job.PO__c=null;
        
        
        system.debug('These are the fields with blank values:' + PrintValue);
        
            if(job.name!=null)
                insert job;
            
            system.debug('This is the new Job:'+ job.Id);  
            
        Return job; 

    } 
    
    @auraEnabled 
    public static sObject cloneWaiver(ID objectId)
    {
        Waiver__c oldWaiver = (Waiver__c) getRecordById(objectId);
        Waiver__c newWaiver = (Waiver__c)oldWaiver.clone(false, true, false, false);
        //List<Waiver__c> oldWaiver = [select id, Job__c, Invoice__c from Waiver__c where id =: objectId limit 1];
        //Waiver__c newWaiver = (Waiver__c)oldWaiver[0].clone(false, true, false, false);
        
        
        Id LetterRT = Schema.SObjectType.Waiver__c.getRecordTypeInfosByName().get('Letter').getRecordTypeId();
        Id LockedLetterRT = Schema.SObjectType.Waiver__c.getRecordTypeInfosByName().get('Locked Letter').getRecordTypeId();
        Id WaiverRT = Schema.SObjectType.Waiver__c.getRecordTypeInfosByName().get('Waiver').getRecordTypeId();
        //System.debug('This is the query returned:' + RT);

          if(newWaiver.RecordTypeId == LetterRT || newWaiver.RecordTypeId == LockedLetterRT)
            newWaiver.RecordTypeId = LetterRT;
        else
            newWaiver.RecordTypeId = WaiverRT;

        newWaiver.Final__c = false;
        insert newWaiver;
        
        return newWaiver;
    }
    @auraEnabled 
    public static sObject cloneInvoice(ID objectId)
    {
        Invoice__c oldinvoice = (Invoice__c) getRecordById(objectId);
        Invoice__c newInvoice = (Invoice__c)oldInvoice.clone(false, true, false, false);
        newInvoice.Status__c = 'In Process';
        newInvoice.Invoice_Number_Incremental__c = null;
        insert newInvoice;
        
        List<Invoice_Line_Item__c> NewlineItems = new list<Invoice_Line_Item__c>();
        
        //get the line items
        List<String> Childfields = SfObjectHelper.GetObjectFieldsByName('Invoice_line_item__c');
        string q = 'SELECT ' + string.join (Childfields, ', ') + ' FROM Invoice_line_item__c where invoice__c =: objectId';         
        List<Invoice_Line_Item__c> lineitems = database.query(q);
        
        for(Invoice_Line_Item__c OldlineItems: lineitems)
        {
            Invoice_Line_Item__c lineitem = oldLineItems.clone(false, true, false, false);
            lineitem.Invoice__c = newInvoice.Id;
            newLineItems.add(lineitem);
        }
        
        insert NewlineItems;
        
        return newInvoice;
    }
    
    @auraEnabled 
    public static sObject getRecordById(Id recordId)
    {
        //List<String> PrintValue = new List<String>();
        
        string objectName = getObjectName(recordId);

        String query = 'Select';
        Map<String, Schema.SObjectField> objectfields = Schema.getGlobalDescribe().get(objectname).getDescribe().fields.getMap();
        
        system.debug('This is the SObject Returned:' + Schema.getGlobalDescribe().get(objectname).getDescribe());
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keyset()){
            query += ' '+s+', ';
            
            //to print out fields names with blank value
            if(string.valueof(query)==null)
                printValue.add(query);
        }
        
        
        
        // Strip off the last comma if it exists.
        /* if (query.subString(query.Length()-1,query.Length()) == ', '){
        query = query.subString(0,query.Length()-2);
        }*/
        
        query = query.subString(0,query.Length()-2);
        system.debug('This is the query string' + query.subString(0,query.Length()-2));
        
        // Add FROM statement
        query += ' FROM ' + objectName;
        
        // Add on a WHERE/ORDER/LIMIT statement as needed
        query += ' WHERE Id =  \''+ recordId+'\'  LIMIT 1'; // modify as needed   WHERE Id = \'test\' AND HasJobLineItem = true LIMIT 1';
        system.debug('This is the query and all its fields:'+query);
        system.debug('These are the fields with blank values:' + PrintValue);
        
        sObject obj = database.query(query);
        
        return obj;
    }
    
    @auraEnabled 
    public static string getObjectName (Id objectId)
    {
        return ObjectId.getSObjectType().getDescribe().getName();
    }
}