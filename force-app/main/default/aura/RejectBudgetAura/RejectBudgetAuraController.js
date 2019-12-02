/**
 * @File Name          : RejectBudgetAuraController.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/6/2019, 7:59:02 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/7/2019   Sean Gray     Initial Version
**/
({
    refreshView: function(component, event) {
        // refresh the view
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    cancelView: function(component, event) {
        // refresh the view
        //$A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
})