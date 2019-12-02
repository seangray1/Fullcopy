({
	doInit : function(component, event, helper) {
        var action = component.get("c.getInv");
        action.setParams({"InvId": component.get("v.recordId")});
        // Configure response handler
        debugger;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var elem = response.getReturnValue();
                var redirectURL = "/apex/ATICreateWaiver?retURL="+ component.get("v.recordId");
                redirectURL += "&RecordType=01270000000UQ0Y"
                
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