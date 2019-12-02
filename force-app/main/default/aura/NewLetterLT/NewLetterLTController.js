({
	doInit : function(component, event, helper) {
        var action = component.get("c.getJob");
        action.setParams({"jobId": component.get("v.recordId")});
        // Configure response handler
        debugger;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var elem = response.getReturnValue();
                var redirectURL = "/apex/ATICreateLetter?retURL="+ component.get("v.recordId");
                redirectURL += "&RecordType=01270000000UQ0V"
                
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