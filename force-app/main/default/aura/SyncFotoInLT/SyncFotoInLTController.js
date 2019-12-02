({
	doInit : function(component, event, helper) {
        var action = component.get("c.executeJob");
        action.setParams({"oppoId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            debugger;
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.returnMsg", response.getReturnValue());  
            } else {
                component.set("v.returnMsg", $A.get("$Label.c.LT_ErrorOnPage"));  
            }
        });

		$A.enqueueAction(action);

    },

})