/*
* Helper class for the CustomerSurvey Trigger - s.jeyarammoorthy - 6/28/2016
*/
public without sharing class CustomerSurveyFieldUpdate {

    public static TriggerStatus__c cfg = TriggerConfig.raw;
    /**
    * @param survey A collection of Customer_Survey__c records for insert
    */
    public static void CustomerSurveyFieldUpdate(list<Customer_Survey__c> surveys){
        Set<Id> jobIds = new Set<Id>(); 
        for(Customer_Survey__c suv: surveys){
            if(suv.ATI_Job__c != null){ 
                jobIds.add(suv.ATI_Job__c);
            }
        }
        Map<Id, ATI_Job__c> jobsMap = new Map<Id, ATI_Job__c>();
        if(!jobIds.isEmpty()){
            jobsMap = new Map<Id, ATI_Job__c>([SELECT id, Name, ownerID, Office2__c, Project_Site_Contact_Name__c, 
                                                      Project_Manager_new__c, Project_Manager__r.ManagerId, 
                                                      Structure_Superintendent__c, Operations_Manager__c, Branch_Manager__c 
                                               FROM ATI_Job__c 
                                               WHERE id IN:jobIds]);
        }
        //for loop for each ATI_Job__c to get the Office
        Set<Id> officeIds = new Set<Id>();
        for(ATI_Job__c job: jobsMap.values()){
            if(job.Office2__c != null){
               officeIds.add(job.Office2__c);
            }
        }
        Map<Id, Office__c> officesMap = new Map<Id, Office__c>();
        if(!officeIds.isEmpty()){
            officesMap = new Map<id, Office__c>([SELECT Id, Name, Survey_Recipient__c, Branch_Manager__c, Regional_Manager__c, Customer_Service__c, 
                                                        EVP_1__c, EVP_2__c, Office_Manager__c, Construction_Office_Manager__c 
                                                 FROM Office__c WHERE Id IN :officeIds ]);
        }
        for(Customer_Survey__c suv: surveys){
            //check to see if the jobIds exists
            ATI_Job__c job = jobsMap.get(suv.ATI_Job__c);
            if(job != null){
                suv.Project_Manager__c = job.Project_Manager__c;
                suv.Project_Manager_new__c = job.Project_Manager_new__c;
                suv.Operations_Manager__c = job.Operations_Manager__c;
                suv.Superintendent__c = job.Structure_Superintendent__c;
                suv.manager__c = job.Project_Manager__r.ManagerId;
                suv.Project_Site_Contact_Lookup__c = job.Project_Site_Contact_Name__c;
                //suv.Branch_Manager__c = job.Branch_Manager__c;
                //check if the id is found
                office__c off = officesMap.get(job.Office2__c);
                if(off != null){
                    suv.Regional_Manager__c = off.Regional_Manager__c;
                    suv.EVP_1__c = off.EVP_1__c;
                    suv.EVP_2__c = off.EVP_2__c;
                    suv.Office_Manager__c = off.Office_Manager__c;
                    suv.Survey_Recipient__c = off.Survey_Recipient__c;
                    suv.Construction_Office_Manager__c = off.Construction_Office_Manager__c;
                    suv.Customer_Service__c = off.Customer_Service__c;
                    suv.Branch_Manager__c = job.Branch_Manager__c;
                    if(off.name != 'HQ' && off.name != 'Anaheim'){
                        suv.Branch_Manager__c = off.Branch_Manager__c;
                    }                   
                }
            }
        }//for loop for each customer survey and assign them to customer survey.
    }
}