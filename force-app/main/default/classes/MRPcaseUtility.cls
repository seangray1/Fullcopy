public with sharing class MRPcaseUtility {
    public static void updateNames(List<MRP_Case__c> newMRP) 
    {
        for (MRP_Case__c mrp : newMRP) 
        {
            
            if (mrp.activity__c== 'Job Issue') 
            {
                if (mrp.job__c != null) 
                {
                    id mrpId = mrp.Job__c;
              		List<ATI_Job__c> job = new List<ATI_Job__c>([Select Id, Account__c, Lead_Source__c, Office2__c, Project_Manager__c from ATI_Job__c where Id =: mrpId]);
                    system.debug('job Id is ' + job);
               		List<office__c> off = new List<office__c>([Select Id, name from office__c Where name =: job[0].office2__c]);
                    system.debug('Office Id is ' + off);
              		mrp.Account__c = job[0].account__c;
                    //if(job[0].lead_source__c != null)
                    //{
                        mrp.TPA__c = job[0].lead_source__c;
                        mrp.Office__c = job[0].office2__c;
                        mrp.User__c = job[0].Project_Manager__c;
                    	
                    	List<office__c> offs = new List<office__c>([Select Id, name from office__c Where id =: mrp.office__c]);
                        //claim number?
                        mrp.Name = offs[0].name + '-' + mrp.Activity__c + '-' + system.now();

                    //}
                    //List<Account> acct = new List<account>([Select Id from Account where Id =:job[0].account__c]);           
                }
            }
            
           /* if (mrp.activity__c== 'On Hold Request') 
            {
                if (mrp.job__c != null) 
                {
                    
                    
                
              		List<ATI_Job__c> job = new List<ATI_Job__c>([Select Id, Account__c, Lead_Source__c, Office__c from ATI_Job__c where Id =: mrpId]);
                    system.debug('job Id is ' + job);
               		List<office__c> off = new List<office__c>([Select Id, name from office__c Where name =: job[0].office__c]);
                    system.debug('Office Id is ' + off);
              		mrp.Account__c = job[0].account__c;
                    mrp.Name = off[0].name + ' ' + mrp.Activity__c + ' ' + system.now();
                    if(job[0].lead_source__c != null)
                    {
                        mrp.TPA__c = job[0].lead_source__c;
                        mrp.Office__c = off[0].id;
                        
                    }
                    //List<Account> acct = new List<account>([Select Id from Account where Id =:job[0].account__c]);
                    
                        
                    
                    
                        
                }
            }*/
            else {
                if(mrp.Office__c != null){
            List<office__c> offs = new List<office__c>([Select Id, name from office__c Where id =: mrp.office__c]);
             mrp.Name = offs[0].name + '-' + mrp.Activity__c + '-' + system.now();
            } 
        
        }
        }

    }
}