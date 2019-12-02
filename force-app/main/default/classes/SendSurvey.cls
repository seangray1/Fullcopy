global class SendSurvey {
    
    webservice static String SmartEmail(ID jodID) {
        
        String result = ''; 
        ID SmartEmailID = null;
        List <ATI_Job__c> JobList = new List<ATI_Job__c>();
        
        if(jodID != null)
        {
            JobList = [Select id, division__c from ATI_Job__c where ID=: jodID];
            for(ATI_Job__c Job: JobList)
            {
                if(Job.Division__c == 'Asbestos' || Job.Division__c == 'Biohazard' || Job.Division__c == 'Lead' || Job.Division__c == 'Microbial') 
                    SmartEmailId = 'a3I70000000Eo0DEAS'; 
                else if(Job.Division__c == 'Demolition' || Job.Division__c == 'Construction') 
                    SmartEmailId = 'a3I70000000Eo2xEAC'; 
                if (Job.Division__c == 'Contents') 
                    SmartEmailId = 'a3I70000000Eo4eEAC'; 
                else if(Job.Division__c == 'Catastrophes' || Job.Division__c == 'Emergency Svces') 
                    SmartEmailId = 'a3I70000000Eo4oEAC'; 
                else if(Job.Division__c == 'Consulting') 
                    SmartEmailId = 'a3I70000000Eo4UEAS'; 
                else if(Job.Division__c == 'Technical Svces') 
                    SmartEmailId = 'a3I70000000Eo4ZEAS'; 
                    
                Job.Survey_Sent_date__c = date.today(); 
            }
             

            wbsendit.SendSmartEmail.SendSmartEmailRequest EmailRequest = new wbsendit.SendSmartEmail.SendSmartEmailRequest();
            
            EmailRequest.RootObject = jodID; //Id.valueOf(‘0039000002Ei5aE’); // E.g. the contact Id.
            
            if(SmartEmailID != null)
            {
                EmailRequest.SmartEmailId = SmartEmailID; //Id.valueOf(‘0039000002Ei5aE’); // The individual smart email template.
                
                List<wbsendit.SendSmartEmail.SendSmartEmailRequest> RequestList = new List<wbsendit.SendSmartEmail.SendSmartEmailRequest>();
                RequestList.add(EmailRequest);
                
                wbsendit.SendSmartEmail.sendEmail(RequestList);
                
                
                update JobList; 
                
                result = 'Success';
            }
            else
                result = 'Missing email template'; 
                      
            
            
            return result;
        }
        else
            return null;

    }
}