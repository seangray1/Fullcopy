/**
 * @File Name          : PMAssignmentAuraController.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/4/2019, 8:27:35 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/4/2019   Sean Gray     Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var jobId = component.get("v.recordId");
        //alert('Device is ' + device);
        if(device === 'DESKTOP'){
            
        var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url":"/lightning/n/PM_Assignment?job__id="+jobId
    });
    urlEvent.fire();
    // }if(device === 'PHONE'){
    //     var flow = component.find("flowData");
    //     var inputVariables = [{ name : "recordId", type : "String", value: component.get("v.recordId")  }];
    //     flow.startFlow("Alert_PD_and_RM", inputVariables);
    // }
}
        },
        //alert("You are using a " + device);
        
    //     
    refreshView: function(component, event) {
        // refresh the view
        $A.get('e.force:refreshView').fire();
    },
})