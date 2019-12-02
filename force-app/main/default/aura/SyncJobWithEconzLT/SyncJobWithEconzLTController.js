({
	doInit : function(component, event, helper) {

            var action = component.get("c.executeJob");
            action.setParams({"oppoId": component.get("v.recordId")});
            // Configure response handler
            action.setCallback(this, function(response) {
                var state = response.getState();
                debugger;
                if(component.isValid() && state === "SUCCESS") {
                    if(response.getReturnValue() == "Success"){
                        component.set("v.returnMsg", response.getReturnValue()); 
                    }
                    else if(response.getReturnValue() == 'Project Manager is not an Econz Operations Manager'){
                         component.set("v.returnMsg", 'Project Manager is not an Econz Operations Manager');
                    }
                    //component.set("v.returnMsg", response.getReturnValue());  
                    else if(component.get("v.RecordType.Name") != 'Job (Approved)') {
                    	component.set("v.returnMsg", "Only approved jobs are synced with EConz.");
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