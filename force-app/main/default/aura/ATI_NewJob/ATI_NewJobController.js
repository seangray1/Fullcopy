({
	doInit : function(component, event, helper) {
	
        var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url":"/apex/ATI_Job_NewJobBeta"
    });
    urlEvent.fire();
	}
})