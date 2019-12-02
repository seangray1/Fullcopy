({
	doInit : function(component, event, helper) {
        var disableButton = component.find("button");
        disableButton.set("v.disabled", true); 
        
        var recordId = component.get("v.recordId")
        var action = component.get("c.getsObject");
        action.setParams({"objectId": recordId});
        
        var returnid=null;
        
        // Configure response handler
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            debugger;
            
            if(component.isValid() && state === "SUCCESS") {
               var elem = response.getReturnValue();					
                debugger;

              /*  var editRecordEvent = $A.get("e.force:editRecord");
    			editRecordEvent.setParams({
       			"recordId": elem.Id
  				});
   				editRecordEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                */
                
              var redirectURL = "/"+ elem.Id;
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": redirectURL
                });
                urlEvent.fire();   
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
                debugger;
            } else {
                component.set("v.hasErrors", true);
            }
            
        });

		$A.enqueueAction(action);

    },

})