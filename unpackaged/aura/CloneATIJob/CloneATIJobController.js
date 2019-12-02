({
	cloneATIJOB : function(component, event, helper) { 
             var recordId = component.get("v.recordId");
         var cloneRelatedJobs = component.get("v.cloneRelatedJobs");
        console.log(cloneRelatedJobs);
             var action = component.get("c.CloneSObject");
             action.setParams({"recordID": recordId});
             action.setCallback(this, function(response){
             var state = response.getState(); 
             if (state === "SUCCESS") {          
           var JobRecord = response.getReturnValue(); 
          // console.log('Job Record Year of Strucute' + JobRecord.Year_Structure_Built__c);
           //console.log('Job Record Year of Strucute' + JobRecord.CloseDate__c);
           //console.log('Job Record Year of Strucute' + JobRecord.Date_of_Loss__c);
                 	component.set("v.name",JobRecord.name);
                    component.set("v.jobName",JobRecord.Job_Name__c);
                    if (!$A.util.isUndefinedOrNull(JobRecord.Account__c)) component.set("v.Account",JobRecord.Account__c);
                   	component.set("v.jobNumber",JobRecord.Job_Number__c);
                    if (!$A.util.isUndefinedOrNull(JobRecord.Contact__r)) component.set("v.Contact",JobRecord.Contact__c); 
                    if (!$A.util.isUndefinedOrNull(JobRecord.Taken_By__c)) component.set("v.TakenBy",JobRecord.Taken_By__c);
                    if (!$A.util.isUndefinedOrNull(JobRecord.Customer__c)) component.set("v.Customer",JobRecord.Customer__c);                     
                    component.set("v.leadSource",JobRecord.Lead_Source__c);
                 if(cloneRelatedJobs == 'true'){
                     component.set("v.parentJob",JobRecord.Id);
                     component.set("v.yearStructureBuilt",JobRecord.Year_Structure_Built__c);
                    component.set("v.dateOfLoss",JobRecord.Date_of_Loss__c);
                 }
                 
                    
                    
                    component.set("v.description",JobRecord.Description__c);
                    component.set("v.jobClass",JobRecord.Job_Class__c);
                    component.set("v.probability",JobRecord.Probability__c);           
                    component.set("v.projectSiteContactName",JobRecord.Project_Site_Contact_Name__c);              
                  //  if (!$A.util.isUndefinedOrNull(JobRecord.Project_Manager__r)) component.set("v.projectManager",JobRecord.Project_Manager__c);
                  //  if (!$A.util.isUndefinedOrNull(JobRecord.Branch_Manager__r)) component.set("v.branchManager",JobRecord.Branch_Manager__c);
                    component.set("v.projectSiteAccount",JobRecord.Project_Site_Contact_Account__c);
                    if (!$A.util.isUndefinedOrNull(JobRecord.Office2__r)) component.set("v.office",JobRecord.Office2__c);                               
                    component.set("v.stage","Qualification");
                    component.set("v.projectType",JobRecord.Project_type__c);
                    if (!$A.util.isUndefinedOrNull(JobRecord.Referred_by__r)) component.set("v.referredBy",JobRecord.Referred_by__c);                
                    component.set("v.closedDate",JobRecord.CloseDate__c);
                    component.set("v.county",JobRecord.County__c);
                    component.set("v.contactInformation",JobRecord.Contact_Information__c);
                    component.set("v.cityofLA",JobRecord.City_of_LA__c);
                    component.set("v.projectSiteAddress",JobRecord.Project_Site_Address__c);
                    component.set("v.projectSiteAddress2",JobRecord.Project_Site_Address_2__c);
                    component.set("v.projectSiteCity",JobRecord.Project_Site_City__c);
                    component.set("v.projectSiteState",JobRecord.Project_Site_State__c);
                    component.set("v.projectSiteZipCode",JobRecord.Project_Site_Zipcode__c);
                    
                    component.set("v.projectSiteContactEmail",JobRecord.Project_Site_Contact_Email__c);
                    component.set("v.noEmailAvailable",JobRecord.no_Email_Available__c);
                    component.set("v.policy",JobRecord.Policy__c);
                    component.set("v.deductible",JobRecord.Deductible__c);
                    component.set("v.claim",JobRecord.Claim__c);
                    component.set("v.contPOClientJob",JobRecord.Cont_P_O_Client_Job__c);
                    component.set("v.PO",JobRecord.PO__c);
                    component.set("v.sendPrelim",JobRecord.Send_prelim__c);
                   // console.log('The year is  ' + "v.yearStructureBuilt");
                    //var yearss = component.get("v.yearStructureBuilt");
                   // console.log('The year is  ' + yearss);
                                                         
                    helper.queryJobValues(component, event, helper);                    

             }
             else{
                    var errors = response.getError();
                    component.set("v.custMessage", errors[0].message);
             }                  
             });
             $A.enqueueAction(action);
          
	},
})