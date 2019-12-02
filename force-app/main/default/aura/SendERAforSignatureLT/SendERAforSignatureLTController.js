({
	doInit : function(component, event, helper) {
        var action = component.get("c.getContract");
        action.setParams({"contractId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
				var elem = response.getReturnValue();
                var signURL = elem.Echo_Sign_URL__c ;
                
                if (	elem.Status == "Approved" || 
						elem.Status == "Activated" ){ 

                    window.open(signURL);
                 	$A.get("e.force:closeQuickAction").fire();
                } else {
                    component.set("v.hasErrors", true);
                }
            } else {
                component.set("v.hasErrors", true);
                
            }
        });

		$A.enqueueAction(action);

    },		
})