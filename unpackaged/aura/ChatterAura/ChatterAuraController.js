({
    // Handle component initialization
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('RecordId is ' + recordId);
        var action = component.get("c.ChatterJobId");
        action.setParams({"recordId": recordId});
             action.setCallback(this, function(response){
             var state = response.getState();
             console.log('State ' + state); 
             if (state === "SUCCESS") {          
           var JobRecord = response.getReturnValue();
           console.log('Job Record is ' + JobRecord);
                     component.set("v.jobId",JobRecord.ATI_Job__c);
                     console.log('Job Id is ' + "v.jobId");
             }
            })
            $A.enqueueAction(action);
    },
    refreshView : function(component, event, helper) {
        console.log('working');
    $A.get('e.force:refreshView').fire();
    alert('working');
    },
})