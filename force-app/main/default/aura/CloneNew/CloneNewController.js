({
    
   gotoCloneLT:function(component,event,helper){
    var avt = $A.get("e.force:navigateToComponent"); 
    
    avt.setParams({
    componentDef:"c:CloneATIJob",
        componentAttributes: {
                recordId : component.get("v.recordId"),
                cloneRelatedJobs : 'false'
            }
    });
		//$A.enqueueAction(avt);

avt.fire();
       

},


    gotoCloneATILT:function(component,event,helper){
    var evt = $A.get("e.force:navigateToComponent"); 
    
    evt.setParams({
    componentDef:"c:CloneATIJob",
        componentAttributes: {
                recordId : component.get("v.recordId"),
                cloneRelatedJobs : 'true'
            }
    });
		//$A.enqueueAction(evt);
evt.fire();
        
}
})