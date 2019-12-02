({
	doInit : function(component, event, helper) {
	
        var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url":"https://atirestoration.tfaforms.net/4643743"
    });
    urlEvent.fire();
	}
})