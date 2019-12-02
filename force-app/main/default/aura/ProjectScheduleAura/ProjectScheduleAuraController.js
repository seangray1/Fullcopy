/**
 * @File Name          : ProjectScheduleAuraController.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 9/7/2019, 7:58:06 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/7/2019   Sean Gray     Initial Version
**/
({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url":"/lightning/n/New_Project?job__id=" + recordId
    });
    urlEvent.fire();
	}
})