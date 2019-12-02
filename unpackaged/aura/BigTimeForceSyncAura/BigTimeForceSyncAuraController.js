/**
 * @File Name          : BigTimeForceSyncAuraController.js
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/1/2019, 6:58:56 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/1/2019   Sean Gray     Initial Version
**/
({
    refreshView: function(component, event) {
        // refresh the view
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
})