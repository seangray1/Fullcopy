({
	queryJobValues : function(component, event, helper) {
        var name = component.get("v.name"); 
        var jobName = component.get("v.jobName");
        var Account = component.get("v.Account");
        var Contact = component.get("v.Contact");
        var ParentJobId = component.get("v.parentJob");
        var Customer = component.get("v.Customer");
        var jobNumber = component.get("v.jobNumber");
        var leadSource = component.get("v.leadSource");
        var description = component.get("v.description");
        var jobClass = component.get("v.jobClass");
        var projectSiteContactName = component.get("v.projectSiteContactName");
        var projectManager = component.get("v.projectManager");
        var branchManager = component.get("v.branchManager");
        var projectSiteAccount = component.get("v.projectSiteAccount");
        var probability = component.get("v.probability");
        var office = component.get("v.office");
        var stage = component.get("v.stage");
        var takenBy = component.get("v.TakenBy");
        var projectType = component.get("v.projectType");
        var referredBy = component.get("v.referredBy");
        var closedDate = component.get("v.closedDate");
        var county = component.get("v.county");
        var cityofLA = component.get("v.cityofLA");
        var projectSiteAddress = component.get("v.projectSiteAddress");
        var projectSiteAddress2 = component.get("v.projectSiteAddress2");
        var projectSiteCity = component.get("v.projectSiteCity");
        var projectSiteState = component.get("v.projectSiteState");
        var projectSiteZipCode = component.get("v.projectSiteZipCode");
        var yearStructureBuilt = component.get("v.yearStructureBuilt");
        var contactInformation = component.get("v.contactInformation");
        var dateOfLoss = component.get("v.dateOfLoss");
        var projectSiteContactEmail = component.get("v.projectSiteContactEmail");
        var noEmailAvailable = component.get("v.noEmailAvailable");
        var policy = component.get("v.policy");
        var deductible = component.get("v.deductible");
        var claim = component.get("v.claim");
        var contPOClientJob = component.get("v.contPOClientJob");
        var PO = component.get("v.PO");
        var sendPrelim = component.get("v.sendPrelim");
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();

        
        var createJobEvent = $A.get("e.force:createRecord");
	    createJobEvent.setParams({
               "entityApiName": "ATI_Job__c",
               "defaultFieldValues": {
                       'Name' : jobName,
                       'Job_Name__c' : jobName,
                       'Job_Number__c' : jobNumber,
                       'Account__c' : Account,
                       'Contact__c' : Contact,
                       'IsCloned__c' : true,
                       'Taken_By__c' : takenBy,
                       'Customer__c' : Customer,
                       'Parent_Job__c' : ParentJobId,
                       'Lead_Source__c' : leadSource,
                       'Description__c' : description,
                       'Job_Class__c' : jobClass,
                       'Project_Site_Contact_Name__c' : projectSiteContactName,
                       'Project_Manager__c' : projectManager,
                       'Branch_Manager__c' : branchManager,
                       'Project_Site_Contact_Account__c' : projectSiteAccount,
                       'Office2__c' : office,
                       'Stage__c' : stage,
                       'Project_type__c' : projectType,
                       'Referred_by__c' : referredBy,
                       'CloseDate__c' : closedDate,
                       'County__c' : county,
                       'City_of_LA__c' : cityofLA,
                       'Probability__c' : probability,
                       'Project_Site_Address__c' : projectSiteAddress,
                       'Project_Site_Address_2__c' : projectSiteAddress2,
                       'Project_Site_City__c' : projectSiteCity,
                       'Project_Site_State__c' : projectSiteState,
                       'Project_Site_Zipcode__c' : projectSiteZipCode,
                       'Year_Structure_Built__c' : yearStructureBuilt,
                       'Date_of_Loss__c' : dateOfLoss,
                       'Project_Site_Contact_Email__c' : projectSiteContactEmail,
                       'No_Email_Available__c' : noEmailAvailable,
                       'Policy__c' : policy,
                       'Deductible__c' : deductible,
                       'Claim__c' : claim,
                       'Cont_P_O_Client_Job__c' : contPOClientJob,
                       'PO__c' : PO,
                       'Send_prelim__c' : sendPrelim
    	        }
	    });
        createJobEvent.fire();
    },
 
})