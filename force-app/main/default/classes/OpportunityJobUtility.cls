public class OpportunityJobUtility {

    public static final List<String> OPP_JOB_OWNER_ROLE = new List<String>{'Opportunity Owner', 'Project Director'};    
    /*************************************************************************/
    /*Helper Methods **************/  

    public static void ManagerToOwnerCopy( Map<Id, Opportunity> oldOppsMap, list<Opportunity> lstNewOpportunities){
        //logic to copies the Jobs Project Manager into the Owner field     
        if (! TriggerConfig.raw.JobCopyPMToOwner__c) {
            return;
        }        
               
        //loop through all of the jobs
        for (Opportunity j : lstNewOpportunities){
            //if project manager isn't empty
            if(j.Project_Manager__c != null){
                //copy the manager ID to the owner
                j.OwnerId = j.Project_Manager__c;
            }
        }   
    }
    
    public static void EmailUpdateOnJob(map<Id,Opportunity> mapOldOppty, list<Opportunity> mapNewOppty){                
        //Limit the size of list by using Sets which do not contain duplicate elements
        set<Id> ContactIds = new set<Id>();
        List<Opportunity> UpdateOpp = new List<Opportunity>();
        
        String Email = '';
        ID jobId = null;        
        
        //When adding new Jobss or updating existing Jobs
        for(Opportunity p : [select id, Project_site_Contact_Name__r.name, Project_site_Contact_Account__c, Project_site_Contact_Name__c, Add_Correct_Email__c from Opportunity where ID In: mapNewOppty]){
            String name = p.Project_site_Contact_Name__r.name;
            if(mapOldOppty!= null && p.Add_Correct_Email__c != null && p.Add_Correct_Email__c == mapOldOppty.get(p.id).Add_Correct_Email__c){
               continue;
            }
            else{ 
                if(name.containsIgnoreCase('ES Job Account') && p.Add_Correct_Email__c != null){
                    trigger.newMap.get(p.Id).addError('Updating email to an generic account is not allowed. Contact your administrator.');
                    //continue;
                }
                else if(p.Add_Correct_Email__c != null && p.Project_site_contact_name__c != null){
                    email = p.Add_Correct_Email__c;
                    jobId = p.id;
                    ContactIds.add(p.Project_site_contact_name__c);
                }  
            }

            List<Contact> contactNeedActions = new list<contact>();
            
            if(!contactIds.isEmpty() ){                
                for( Contact a : [Select Id, email from Contact where Id IN :ContactIds]){                    
                    System.debug('Email is::::::::::::::::::::::::::::::::::::::' + a.email);
                    System.debug('Contact Id is::::::::::::::::::::::::::::::::::::::' + a.Id);                    
                    a.email = email;                    
                    contactNeedActions.add(a);                    
                }
                
                if(!contactNeedActions.isEmpty() ){
                    update contactNeedActions;
                }
            }  
        }

    }
    
    
    /*
* @Method: removeOpptyOwnerfromTeam
* @ Functionality: remove opporutnity owner from the opportunity team if the owner exists in the team as "Opportunity Owner" 
    and Opportunity Project Manager is not blank 
*/
    
    public static void removeOpptyOwnerfromTeam(Map<Id, Opportunity> oldOppsMap, list<Opportunity> lstNewOppty){
        
        set<Id> opptyIds = new set<Id>();
        map<Id,Opportunity> mapOppty = new map<Id,Opportunity>();
        list<OpportunityTeamMember> lstDeleteOpptyTeam = new list<OpportunityTeamMember>();
        for(Opportunity oppty:lstNewOppty){
            Opportunity oldOpp = oldOppsMap != null ? oldOppsMap.get( oppty.Id ) : null ;
            if( oldOpp == null || oldOpp.OwnerId != oppty.OwnerId ){
                opptyIds.add( oppty.Id);
                mapOppty.put(oppty.Id, oppty);
            }
        }
        
        //Adding the split
        if( oldOppsMap != null && !opptyIds.isEmpty() ){
            List<OpportunitySplit> oppSplitsToDelete = new List<OpportunitySplit>();
            
            for( OpportunitySplit os : [ SELECT Id, SplitOwnerid, OpportunityId,
                                        Opportunity.OwnerId 
                                         FROM OpportunitySplit 
                                         WHERE OpportunityId IN : opptyIds ] ){  
               
                Opportunity owner = oldOppsMap.get( os.OpportunityId );
                            
                if(owner != null && os.SplitOwnerId == owner.ownerID){
                    oppSplitsToDelete.add( os );
                }  
            }
            
            if( !oppSplitsToDelete.isEmpty() ){
                delete oppSplitsToDelete;
            }
        }
        if( !opptyIds.isEmpty() ){
            //Query for Owner
            list<OpportunityTeamMember> lstOpptyTeam = [SELECT UserId, TeamMemberRole, OpportunityId, Id from  OpportunityTeamMember 
                                                        WHERE OpportunityId IN :opptyIds 
                                                        AND  TeamMemberRole = :OPP_JOB_OWNER_ROLE];
            for(OpportunityTeamMember opptyMem :lstOpptyTeam ){
                Opportunity oppty = mapOppty.get(opptyMem.OpportunityId);
                if(oppty!=null && (oppty.OwnerId != opptyMem.UserId )){
                    //do not delete the current Owner
                    lstDeleteOpptyTeam.add(opptyMem);
                }
            }
            
            if( !lstDeleteOpptyTeam.isEmpty() ){
                try{
                    delete lstDeleteOpptyTeam;
                }catch(DmlException dmlex){
                    for(Integer iFailedRow=0; iFailedRow<dmlex.getNumDml();iFailedRow++){
                        Integer Orginalindex = dmlex.getDmlIndex(iFailedRow);
                        OpportunityTeamMember opptyTeamMem = lstDeleteOpptyTeam[Orginalindex];
                        Opportunity oppty = mapOppty.get(opptyTeamMem.OpportunityId);
                        oppty.addError('Failed to remove the Opportunit Owner from team -'+ dmlex.getDmlMessage(iFailedRow) +
                                       ' - Stacktrace::'+dmlex.getStackTraceString());
                    }
                }
            }
        }
    }
    

    /**
* Call google map api first to get lat, lng
* Call FotoIn api to create project
* @param job [description]
*/
    public static void createFotoInProject( Map<Id, Opportunity> oldJobMap, List<Opportunity> jobs ){
        
        Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.Opportunity.RecordTypeInfosByName;
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for(Opportunity job : jobs){
            //job record type changed, only approved job will be considered to call FotoIn
            if(Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Job (Approved)') == null || 
               Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId != job.RecordTypeId || 
               (oldJobMap != null && job.RecordTypeId == oldJobMap.get(job.id).RecordTypeId)){
                continue;
            }
            // job division is Marketing will be ignored
            if(job.Division__c == 'Marketing'){
                continue;
            }
            /*if(job.Job_Number__c.contains('#')){
                continue;
            }*/
            if(job.Project_Site_Address__c == null 
               || job.Project_Site_Address__c == null //&& job.Project_Site_Address_2__c == null) 
               || job.Project_Site_City__c == null 
               || job.Project_Site_State__c == null 
               || job.Project_Site_Zipcode__c == null){
                   continue;
               }else{
                   oppMap.put(job.id, job);
               }
        }
        if( !oppMap.isEmpty() && !System.isBatch() && !System.isScheduled() ){
            callFotoIn2Create(oppMap.keySet());
        }
        
    }
    
    /**
* Call google map api first to get lat, lng
* Call FotoIn api to update project or delete project
* @param job [description]
*/
    public static void updateFotoInProject( Map<Id, Opportunity> oldJobMap, List<Opportunity> jobs ){
        
        Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.Opportunity.RecordTypeInfosByName;
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for(Opportunity job : jobs){
            // only when the job record Type is Job approved
            if(Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Job (Approved)') == null || 
               Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId != job.RecordTypeId){
                continue;
            }
            // job division is Marketing will be ignored
            if(job.Division__c == 'Marketing'){
                continue;
            }
            if(job.Project_Site_Record_Id__c == null){
                continue;
            }
            if(job.Job_Number__c.contains('#')){
                continue;
            }
            if((oldJobMap.get(job.id).Project_Site_Name_Fotoin__c != job.Project_Site_Name_Fotoin__c) 
               ||(oldJobMap.get(job.id).Project_Site_Address__c != job.Project_Site_Address__c) 
               //|| (oldJobMap.get(job.id).Project_Site_Address_2__c != job.Project_Site_Address_2__c) 
               || (oldJobMap.get(job.id).Project_Site_City__c != job.Project_Site_City__c)
               || (oldJobMap.get(job.id).Project_Site_State__c != job.Project_Site_State__c)
               || (oldJobMap.get(job.id).Project_Site_Zipcode__c != job.Project_Site_Zipcode__c) 
              ){
                  oppMap.put(job.id, job);
              }
        }
        if( !oppMap.isEmpty() && !System.isBatch() && !System.isScheduled()){
            callFotoIn2Update(oppMap.keySet());
            
        }
        
    }

    public static OpportunityJobWrap callGoogleMapAPI(Opportunity oppJob){
        String address = '';
        String oppId = oppJob.Id;
        if (oppJob.Project_Site_Address__c != null){
            address += oppJob.Project_Site_Address__c;
            /*
            if(oppJob.Project_Site_Address_2__c != null) {
                address += ' ' + oppJob.Project_Site_Address_2__c;
            }
            */
            address += ', ';
        }
        if (oppJob.Project_Site_City__c != null){
            address += oppJob.Project_Site_City__c +', ';
        }
        if (oppJob.Project_Site_State__c != null){
            address += oppJob.Project_Site_State__c +' ';
        }
        if (oppJob.Project_Site_Zipcode__c != null){
            address += oppJob.Project_Site_Zipcode__c +', ';
        }
        //address += 'USA';
        //address = EncodingUtil.urlEncode(address, 'UTF-8');
        system.debug('@@@ ADDRESS ===' +address);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyBuE7iBv1fugjx2Az7h-bCwJCoWOadglz8&address='+
                         EncodingUtil.urlEncode(address, 'UTF-8')+'&sensor=false');
        req.setMethod('GET');
        req.setTimeout(60000);
        OpportunityJobWrap opportunityJobWrap = new OpportunityJobWrap();
        // callout
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200){
            // parse coordinates from response
            System.debug('Google response body ...' + res.getBody());
            JSONParser parser = JSON.createParser(res.getBody());
            double lat = null;
            double lon = null;
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'location'){
                    parser.nextToken(); // object start
                    while (parser.nextToken() != JSONToken.END_OBJECT){
                        String txt = parser.getText();
                        parser.nextToken();
                        if (txt == 'lat'){
                            lat = parser.getDoubleValue();
                        }
                        else if (txt == 'lng'){
                            lon = parser.getDoubleValue();
                        } 
                    }
                    System.debug('@@@ LAT ====' +lat);
                }
            }
            // update coordinates if we get back
            opportunityJobWrap.locations = new List<OpportunityJobWrap.Location>();
            OpportunityJobWrap.Location location = new OpportunityJobWrap.Location();
            if (lat != null){
                location.latitude = lat;
            }
            if(lon != null){
                location.longitude = lon;
            }
            location.radius = Long.valueOf(Label.FotoIn_Project_Site_Radius);
            opportunityJobWrap.locations.add(location);
            opportunityJobWrap.archived = false;
            opportunityJobWrap.address = address;
            opportunityJobWrap.projectName = oppJob.Project_Site_Name_Fotoin__c;
        }
        else{
            throw new CallFotoInException(res.getBody());
        }
        return opportunityJobWrap;
    }
    
    public static HTTPResponse getHttpResponse(String method, String endPoint, String jsonInput, Opportunity updateOpp) {
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(Label.FotoIn_User_Name + ':' + Label.FotoIn_User_Password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod(method);
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type','application/json');
        req.setBody(jsonInput);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        Map<String, Object> responseMap = new Map<String, Object>();
        res = http.send(req);
        System.debug('This is the status code' + res.getStatuscode());
        if(res.getStatusCode() == 201){
            //todo need to save the project Id in the salesforce
            System.debug('Input: ... ' + jsonInput);
            System.debug('OutPut: ... ' + res.getBody());
            JSONParser parser = JSON.createParser(res.getBody());
            Long projectRecordId = 0;
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'data'){
                    parser.nextToken(); // object start
                    while (parser.nextToken() != JSONToken.END_OBJECT){
                        String txt = parser.getText();
                        parser.nextToken();
                        if (txt == 'id'){
                            projectRecordId = parser.getLongValue();
                        }
                    }
                    System.debug('@@@ projectRecordId ====' +projectRecordId);
                }
            }
            updateOpp.Project_Site_Record_Id__c = String.valueOf(projectRecordId);
            updateOpp.Last_Successful_FotoIn_Update__c = Datetime.now();
            updateOpp.Last_FotoIn_Update__c = Datetime.now();
            updateOpp.Project_Site_Call_Result_Message__c = '';
            update updateOpp;
        }else{
            throw new CallFotoInException(res.getBody());
        }
        return res;
    }
    
    /**
* credential to cal FotoIn 
* Custom label: 
* @param  jobWrap [description]
* @return         [description]
*/
    @future (callout=true)
    public static void callFotoIn2Create(Set<Id> jobIdSet){
    
        //took out Project_Site_Address_2__c from the soql query. 
        for(Opportunity oppJob : [SELECT Id, Name, Project_Site_Record_Id__c, Project_Site_Call_Result_Message__c, 
                                         Last_Successful_FotoIn_Update__c, Last_FotoIn_Update__c, Project_Site_Name__c, 
                                         Project_Site_Name_Fotoin__c, Project_Site_Address__c, 
                                         Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c 
                                  FROM Opportunity 
                                  WHERE Id IN: jobIdSet LIMIT 49999 ]){
            try{
                String jsonInput = JSON.serializePretty(callGoogleMapAPI(oppJob));
                getHttpResponse('POST', Label.FotoIn_Stage_Project_End_Point_URL, jsonInput, oppJob);
            }
            catch(Exception e){
                System.debug('Http call error ...' + e.getMessage());
                //oppJob.Project_Site_Record_Id__c = null;
                oppJob.Last_FotoIn_Update__c = Datetime.now();
                oppJob.Project_Site_Call_Result_Message__c = e.getMessage().left(2047);
                update oppJob;
            }
        }
    }
    @future (callout=true) 
    public static void callFotoIn2Update(Set<Id> jobIdSet) {
        
        //took out Project_Site_Address_2__c from the soql query. 
        for(Opportunity oppJob : [SELECT Id, Name, Project_Site_Name_Fotoin__c, Project_Site_Name__c, 
                                         Project_Site_Record_Id__c, Last_Successful_FotoIn_Update__c, 
                                         Last_FotoIn_Update__c, Project_Site_Address__c, Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c 
                                  FROM Opportunity WHERE Id IN: jobIdSet LIMIT 49999 FOR UPDATE ]){
            try{
                OpportunityJobWrap updateOppJobWrap = callGoogleMapAPI(oppJob);
                updateOppJobWrap.id = oppJob.Project_Site_Record_Id__c;
                String jsonInput = JSON.serializePretty(updateOppJobWrap);
                getHttpResponse('PUT', Label.FotoIn_Stage_Project_End_Point_URL, jsonInput, oppJob);
            }
            catch(Exception e){
                System.debug('Http call error ...' + e.getMessage());
                oppJob.Last_FotoIn_Update__c = Datetime.now();
                oppJob.Project_Site_Call_Result_Message__c = e.getMessage().left(2047);
                update oppJob;
            }
        }
    }

}