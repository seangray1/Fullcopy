({
	doInit : function(component, event, helper) {
        var action = component.get("c.getWorkOrder");
        action.setParams({"woId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var elem = response.getReturnValue();
                var redirectURL = "/apex/CKSW_ATI_VF01_NewWOShift?WorkOrderId=" + elem.Id;
                redirectURL += "&UserId=" + elem.Assigned_To__c;
                redirectURL += "&JobId=" + elem.ATI_Job__c;
                redirectURL += "&Start=" + elem.Requested_Start_Date_Time__c;
                redirectURL += "&Finish=dtFinish"
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": redirectURL
                });
                urlEvent.fire();
            } else {
                component.set("v.hasErrors", true);
                
            }
        });

		$A.enqueueAction(action);

    },

})