({
	doInit : function(component, event, helper) {

            var action = component.get("c.executeJob");
            action.setParams({"JobId": component.get("v.recordId")});
            // Configure response handler
            action.setCallback(this, function(response) {
                var state = response.getState();
                debugger;
                if(component.isValid() && state === "SUCCESS") {
                    if(response.getReturnValue() == "Success"){
                        component.set("v.returnMsg", response.getReturnValue()); 
                    } 
                    else if(response.getReturnValue() == "Not Authorized") {
                    	component.set("v.returnMsg", "You are not authorized to send survey. Please contact your administrator.");
                	}
                    else {
                        component.set("v.returnMsg", "There was an error while syncing. Pls retry again or contact your Administrator");
                    }
                } 
            });

        
        $A.enqueueAction(action);
   	},

})     
        /*
         * else {
                console.log("Error: " + $A.get("$Label.c.LT_ErrorOnPage");  
            }
            */