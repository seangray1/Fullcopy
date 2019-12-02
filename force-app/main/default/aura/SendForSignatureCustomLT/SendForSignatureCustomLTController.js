({
	doInit : function(component, event, helper) {
		var action = component.get("c.getEchoSignAgreements"); 
        action.setParams({"jobId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var rtnValue = response.getReturnValue(); 
                debugger;
                // If there are zero templates, alert user and do nothing
				if( rtnValue.length == 0) { 
                     component.set("v.returnMsg", $A.get("$Label.c.LT_NoAgreementTemplate"));  
                // If there is ONE template, there is no need to choose one. Navigate user forward 
                } else if(rtnValue.length == 1) { 
					var redirectURL = "/apex/echosign_dev1__AgreementTemplateProcess?masterId=" + component.get("v.recordId");
                    redirectURL += "&TemplateId=" + rtnValue[0].Id; 
                   
                
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": redirectURL
                    });
                    urlEvent.fire();
					
                // If there are more than one, Let the user choose which template to user 
                } else { 

                    // Declare HTML string for popup   
                    var agreementListHtml = "<h1>"+ $A.get("$Label.c.LT_ChooseAgreementTemplate") + "</h1><br />"; 
    
                    // Build HTML to show in modal. 
                    for (var i=0; i< rtnValue.length; i++) { 
                        agreementListHtml += '&nbsp;&nbsp;&nbsp;<h3><a href="/apex/echosign_dev1__AgreementTemplateProcess?masterId=' + component.get("v.recordId") + '&TemplateId=' + rtnValue[i].Id + '" title="' + rtnValue[i].Id + '" target="_blank">' + rtnValue[i].Name + '</a></h3>'; 
    
                        if( i< rtnValue.length ) { 
                            agreementListHtml += '<br />'; 
                        }	// </if 
    
                    }	// </for 
                    component.set("v.returnMsg", agreementListHtml); 
                }

            } else {
                component.set("v.returnMsg", $A.get("$Label.c.LT_ErrorOnPage"));  
            }
        });

		$A.enqueueAction(action);
	}
})