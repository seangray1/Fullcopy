public without sharing class InvoiceLineItemControl 
{
	public static Boolean IsRunning = false;
	/**************************************************************************
	* Sets the invoice Line Item name 
	*
	* @param invoices:
	*         A list of invoices Line item, presumably from a before insert/update call,
	*         i.e., they must be editable but need not have IDs
	*/
	public static void setInvoiceName(List<Invoice_Line_Item__c> invoices){
    	System.debug(Logginglevel.WARN, 'InvoiceLineItemControl: Running automatic Name generation');
    	
    	// For all the new line Items create the name
    	for(Invoice_Line_Item__c item :invoices){
    		System.debug(Logginglevel.WARN, 'name 1: ' + item.Name );
    		
    		// if PickListName__c is other set the value to the second value
    		if(item.PickListName__c != 'Other'){
    			item.Name = item.PickListName__c;
    		}else{
    			item.Name = item.Other__c;
    		}
    		System.debug(Logginglevel.WARN, 'name 2: ' + item.Name );
    	}
    }
    
    /**************************************************************************
	* Sets the invoice Line Item order 
	*
	* @param invoices:
	*         A list of invoices Line item, presumably from a before insert/update call,
	*         i.e., they must be editable but need not have IDs
	*/
    public static void setOrder( Map<Id, Invoice_Line_Item__c> oldInvoiceLineItemsMap, List<Invoice_Line_Item__c> newInvoiceLineItems ){
        IsRunning = true;
        Set<Id> invoiceIds = new Set<Id>();
        for( Invoice_Line_Item__c ili : newInvoiceLineItems ){
        	Invoice_Line_Item__c oldILI = oldInvoiceLineItemsMap.get( ili.Id );
            if( ili.Order__c != oldILI.Order__c ){
                invoiceIds.add( ili.Invoice__c ); 
            }                        
        }
        List<Invoice_Line_Item__c> itemsToUpdate = new List<Invoice_Line_Item__c>();
        if( !invoiceIds.isEmpty() ){
        	Map<Id, Invoice__c> invoicesMap = new Map<Id, Invoice__c>([ SELECT Id, ( SELECT Id, Order__c 
            	                                                                     FROM Invoice_Line_Items__r ORDER BY Order__c ASC )
                	                                                    FROM Invoice__c WHERE Id IN: invoiceIds ]);
            for( Invoice_Line_Item__c ili : newInvoiceLineItems ){
        	Invoice_Line_Item__c oldILI = oldInvoiceLineItemsMap.get( ili.Id );
                if( ili.Order__c != oldILI.Order__c ){
                    itemsToUpdate.addAll( setOrder( ili, oldILI, invoicesMap.get( ili.Invoice__c ).Invoice_Line_Items__r ) ); 
                }                        
            }
        }
        
        if( !itemsToUpdate.isEmpty() ){
            update itemsToUpdate;
        }

    }
    
    private static List<Invoice_Line_Item__c> setOrder(Invoice_Line_Item__c newInvoice, 
                                                       Invoice_Line_Item__c oldInvoice, 
                                                       List<Invoice_Line_Item__c> invLineItems){	    				           
        List<Invoice_Line_Item__c> itemsToUpdate = new List<Invoice_Line_Item__c>();        
        for(Invoice_Line_Item__c item : invLineItems){
            // Checking for the order Invoice is on Correct Order and swaps if its different  
            if(newInvoice.Order__c > oldInvoice.Order__c){
                if(item.Order__c >= oldInvoice.Order__c && item.Order__c <= newInvoice.Order__c){
                    // Make the simple switch
                    if(item.Order__c == oldInvoice.Order__c){
                        item.Order__c = newInvoice.Order__c ;
                    }else{
                        item.Order__c = item.Order__c - 1;
                        itemsToUpdate.add(item);
                    }
                }
            }
            else{
                if(item.Order__c >=  newInvoice.Order__c && item.Order__c <= oldInvoice.Order__c){
                    // Make the simple switch
                    if(item.Order__c == oldInvoice.Order__c){
                        item.Order__c = newInvoice.Order__c ;
                    }else{
                        item.Order__c = item.Order__c + 1;
                        itemsToUpdate.add(item);
                    }
                }
            }		
        }
		return itemsToUpdate;                
    }
    
}