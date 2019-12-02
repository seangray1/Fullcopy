public with sharing class JobAccountAndJobContact {

    public static void UpdateJobAccountandJobContact(map<Id,ATI_Job__c> mapOldJob, list<ATI_Job__c> mapNewJob){
        
        set<ID>ProjectContactID = new set<Id>();        
        Set<ID> updateContactIds = new Set<ID>();
                
        for(ATI_Job__c p : mapNewJob){
            ID jobId = p.id;
            
            ATI_Job__c oldJob = mapOldJob.get(p.id);
            if (oldJob == null)
            {
                continue;
            }
            
            if(oldJob.Project_site_contact_name__c != p.Project_site_contact_name__c && p.Project_site_contact_name__c != null){        
                updateContactIds.add(p.Id);
            }else if(oldJob.Project_Site_Contact_Account__c != p.Project_Site_Contact_Account__c && p.Project_Site_Contact_Account__c != null){
                updateContactIds.add(p.Id);
            }else if(oldJob.Account__c != p.Account__c && p.Account__c != null){
                updateContactIds.add(p.Id);
            }else if(oldJob.Contact__c != p.Contact__c && p.Contact__c != null){
                updateContactIds.add(p.Id);
            }else if(oldJob.Owner__c != p.Owner__c && p.Owner__c != null && p.Owner__r.ispersonAccount == false){
                updateContactIDs.add(p.Id);
            }
        }
        
        if( !updateContactIds.isEmpty() ){
            List<ATI_Job__c> jobs = [ SELECT ID, Contact__c, Contact__r.AccountID, Account__c, Project_site_contact_name__c, 
                                      Project_Site_Contact_Account__c, Owner__c,
                                      (SELECT ID, Contact__c 
                                       FROM Job_Contacts__r), 
                                      (SELECT ID, Account__c 
                                       FROM Job_Accounts__r) 
                                      FROM ATI_Job__c 
                                      WHERE ID IN :updateContactIds];
            List<Job_Contact__c> addJobContacts = new List<Job_Contact__c>();
            List<Job_Account__c> addJobAccounts = new List<Job_Account__c>();
            
            for (ATI_Job__c job : jobs){    
                // Check and change
                // check Contact existed
                
                boolean contactExist = false;
                boolean projectContactExist = false;
                boolean accountExist = false;
                boolean contactAccountExist = false;
                boolean projectAccountExist = false;
                boolean customerAccountExist = false;
                
                boolean ContactSameAsPS = false;
                boolean ContactAccountSameAsPS = false;
                boolean AccountSameAsProjectSite = false;
                boolean AccountSameAsCustomer = false;
                boolean SameAsPrimaryAccount = false;
                boolean ProjectSiteSameAsCustomer = false;
                
                if( job.Contact__c == job.Project_site_contact_name__c){
                    ContactSameAsPS = true;
                } 
                system.debug('This is ContactSameAsPS:::::::::::::::'+ ContactSameAsPS);
                
                if(job.Account__c == job.Project_Site_Contact_Account__c){
                    AccountSameAsProjectSite = true;
                } else if(job.Account__c == job.Owner__c){
                    AccountSameAsCustomer = true;
                } else if(job.Account__c == job.Contact__r.AccountID){
                    SameAsPrimaryAccount = true;
                }
                if(job.Contact__r.accountID == job.Project_Site_Contact_Account__c){
                    ContactAccountSameAsPS = true;
                }
                system.debug('This is SameAsPrimaryAccount:::::::::::::::'+ SameAsPrimaryAccount);
                
                if (job.project_site_contact_account__c == job.Owner__c){
                    ProjectSiteSameAsCustomer = true;
                }
                system.debug('This is ProjectSiteSameAsCustomer:::::::::::::::'+ ProjectSiteSameAsCustomer);
                
                //check for job contact for existing
                for(Job_Contact__c con : job.job_contacts__r ){
                    if (con.contact__c == job.Contact__c && job.Contact__c != null){
                        contactExist = true;
                        system.debug('This is ContactExist:::::::::::::::'+ contactExist);
                    }
                    
                    if (con.contact__c == job.Project_site_contact_name__c &&  
                        job.Contact__c != job.Project_site_contact_name__c){
                            projectContactExist = true;
                            system.debug('This is projectContactExist:::::::::::::::'+ projectContactExist);
                        }
                    if (contactExist && projectContactExist){
                        break;
                    }
                }
                
                //check for job account for existing
                for( Job_Account__c acct : job.job_accounts__r ){
                    if (acct.account__c == job.Account__c && job.Account__c != null){
                        accountExist = true;
                        system.debug('This is accountExist:::::::::::::::'+ accountExist);
                    } 
                    if (acct.account__c == job.Project_Site_Contact_Account__c &&  job.Project_Site_Contact_Account__c != null &&
                        job.Account__c != job.Project_Site_Contact_Account__c){
                            projectAccountExist = true;
                            system.debug('This is projectAccountExist:::::::::::::::'+ projectAccountExist);
                        }
                    if(acct.account__c == job.Owner__c && job.Owner__c != null &&
                       (job.Account__c != job.Owner__c || job.Project_Site_Contact_Account__c != job.Owner__c)){
                           customerAccountExist = true;
                           system.debug('This is customerAccountExist:::::::::::::::'+ customerAccountExist);
                       } 
                    
                    if (accountExist && projectAccountExist && customerAccountExist){
                        break;
                    }
                }
                
                //add job contacts
                if (!contactExist && job.contact__c != null){
                    Job_Contact__c jobContact = new Job_Contact__c();
                    Job_Account__c jobAccount = new Job_Account__c();
                    jobContact.ATI_Job__c = job.Id;
                    jobContact.Contact__c = job.Contact__c;
                    jobContact.Job_Acct__c = job.Contact__r.AccountID;
                    addJobContacts.add(jobContact);
                    //if the contact account is different from primary account, add to job account.
                    if(!SameAsPrimaryAccount && job.Contact__c != null){
                        jobAccount.ATI_Job__c = job.Id;
                        jobAccount.Account__c = job.Contact__r.AccountID;
                        addJobAccounts.add(JobAccount);
                    }
                    
                }
                if (!projectContactExist && !ContactSameAsPS && job.Project_site_contact_name__c != null){
                    Job_Contact__c jobContact = new Job_Contact__c();
                    jobContact.ATI_Job__c = job.Id;
                    jobContact.Contact__c = job.Project_site_contact_name__c;
                    addJobContacts.add(jobContact);      
                }
                
                //add job accounts
                if (!accountExist && job.Account__c != null){
                    Job_Account__c jobAccount = new Job_Account__c();
                    jobAccount.ATI_Job__c = job.Id;
                    jobAccount.account__c = job.Account__c;
                    addJobAccounts.add(jobAccount);
                }
                
                if (!projectAccountExist && !AccountSameAsProjectSite && !ContactAccountSameAsPS && job.Project_Site_Contact_Account__c != null){
                    Job_Account__c jobAccount = new Job_Account__c();
                    jobAccount.ATI_Job__c = job.Id;
                    jobAccount.Account__c = job.Project_Site_Contact_Account__c;
                    addJobAccounts.add(jobAccount);      
                }
                
                if (!customerAccountExist && !ProjectSiteSameAsCustomer && !AccountSameAsCustomer && job.Owner__c != null){
                    Job_Account__c jobAccount = new Job_Account__c();
                    jobAccount.ATI_Job__c = job.Id;
                    jobAccount.Account__c = job.Owner__c;
                    addJobAccounts.add(jobAccount);      
                }
                
                // Check Project Contact is exsted.
            }
            if ( !addJobContacts.isEmpty() ){
                insert addJobContacts;
            }
            if( !addJobAccounts.isEmpty() ){
                insert addJobAccounts;
            }
        }
        
    }
}