({
	doInit : function(component, event, helper) {
        var action = component.get("c.getWaiver");
        action.setParams({"waiverId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                debugger;
				var elem = response.getReturnValue();
                
                if((	elem.Waiver_Or_Letter_Type__c == "Unconditional Final Waiver" || 
					 	elem.Waiver_Or_Letter_Type__c == "Unconditional Progress Waiver") 
                   		&& !elem.Approved_By_Id__c){ 
					component.set("v.hasErrors", true); 
				} else {
                                        
					var congaURL = elem.Conga_URL__c

                    window.open(congaURL, '_blank', 'height=200, width=500');
                 	$A.get("e.force:closeQuickAction").fire();
                }
            } else {
                component.set("v.hasErrors", true);
                
            }
        });

		$A.enqueueAction(action);

    },		
})