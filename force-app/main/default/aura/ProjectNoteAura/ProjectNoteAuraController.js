/**
 * @File Name          : ProjectNoteAuraController.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/25/2019, 1:59:13 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/8/2019   Sean Gray     Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var jobId = component.get("v.recordId");
        //alert('Device is ' + device);
        if(device === 'DESKTOP'){
            
        var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url":"/lightning/n/Project_Note?job__id="+jobId
    });
    urlEvent.fire();
    // }if(device === 'PHONE'){
    //     var flow = component.find("flowData");
    //     var inputVariables = [{ name : "recordId", type : "String", value: component.get("v.recordId")  }];
    //     flow.startFlow("Project_Note", inputVariables);
    // }
}
        },
        //alert("You are using a " + device);
        
    //     
    refreshView: function(component, event) {
        // refresh the view
        $A.get('e.force:refreshView').fire();
    },
    // statuschange: function(component, event) {
    //     var urlEvent = $A.get("e.force:navigateToSObject");
    //     urlEvent.setParams({
    //         "recordId": component.get("v.recordId"),
    //         "isredirect": "true"
    //     });
    //     urlEvent.fire();
    
    // },
    // doInit1 : function(component, event, helper){
    //     var flow = component.find("Project_Note");
    //     // In that component, start your flow. Reference the flow's API Name.
    //     flow.startFlow("myFlow");

    // },
})