({
	myAction : function(component, event, helper) {
        debugger;
	},
    
    confirm : function(component, event) {
        debugger;
		var action = component.get("c.getsObject");
        
        action.setParams({"ObjectId": component.get("v.recordId")});
      
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(component.isValid() && state == "SUCCESS"){
                
                var elem = response.getReturnValue();
                var redirectURL = "/apex/SubmitForApproval?id=" + component.get("v.recordId");  //elem.Id
                redirectURL += "&lock=0";
                
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