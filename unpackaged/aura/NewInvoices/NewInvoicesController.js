({
	doInit : function(component, event, helper) {
	
        var urlEvent = $A.get("e.force:navigateToURL");
        var id = component.get("v.recordId");
    urlEvent.setParams({
        "url":"/apex/ATIInvoicePage?id="+id
    });
    urlEvent.fire();
	}
})