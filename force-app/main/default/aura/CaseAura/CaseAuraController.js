/**
 * @File Name          : CaseAuraController.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/28/2019, 12:37:51 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/28/2019   Sean Gray     Initial Version
**/
({
    refreshView: function(component, event) {
        // refresh the view
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    closeView: function(component, event) {
        // refresh the view
        //$A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
})