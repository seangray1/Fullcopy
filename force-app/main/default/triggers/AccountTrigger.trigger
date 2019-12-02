trigger AccountTrigger on Account (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    TriggerStatus__c cfg = TriggerConfig.raw;
    private static boolean isRunningNumber = false;
    private static boolean isRunningSynch = false;
    
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (Account a : Trigger.New) {
            String street = a.BillingStreet;
            if (street == null) continue;
            system.debug('trigger runs ');
            if (street.contains('\\\\')) {
                system.debug('trigger IF ');
                List<String> streets = street.split('\\\\');
                if (streets.size() > 1){
                
                    street = streets[0] + '\n' + streets[2];
                    a.BillingStreet = street;
                    system.debug('street1 = ' + streets[0]);
                    system.debug('street2 = ' + streets[2]);
                    system.debug('street = ' + street);
                    system.debug('billingstreet = ' + a.billingstreet);
               } else{
                 if(streets.isEmpty()){
                     a.BillingStreet = '';
                     street='';
                 }else{
                     street = streets[0];
                     a.BillingStreet = street;
                     system.debug('street = ' + street);
                     system.debug('billingstreet = ' + a.billingstreet);
                 }
                }
            }
            
            if (street == null || street == '') {
   
                a.Timberline_BillingStreet1__c = null;
                a.Timberline_BillingStreet2__c = null;
            }
            else {
                List<String> lines = street.split('\\n');
                a.Timberline_BillingStreet1__c = lines[0];
                if (lines.size() > 1)
                    a.Timberline_BillingStreet2__c = lines[1];
                else
                    a.Timberline_BillingStreet2__c = null;
            }
        }
    }
    
    //////////////////////////////////////////////////////
    // TIMBERLINE CUSTOMER NUMBER
    if (!isRunningNumber && cfg!=null && cfg.AccountGenerateCustomerNumber__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) 
    {
        isRunningNumber = true;
        AccountControl.setCustomerNumber(Trigger.new);
    }
    
    //////////////////////////////////////////////////////
    // TIMBERLINE ACCOUNT SYNC
    if (!isRunningSynch && cfg!=null &&  cfg.AccountSyncToTimberline__c && Trigger.isBefore && Trigger.isUpdate)
    {   
        isRunningSynch = true;
        
        // List of Id Accounts to send to Timberline 
        Set<Id> sendToTimberline = new Set<Id>();
        
        system.debug('Trying to Synch Accounts');
            
        // Only send accounts that chaned necesaries fields
        for(Account newAccount : Trigger.new)
        {
            // Get the old value
            Account oldValue = Trigger.oldMap.get(newAccount.id);
            
            //TODO: add Primary Contact  
            if( newAccount.Name != oldValue.Name || 
                newAccount.Type != oldValue.Type ||
                newAccount.Timberline_Customer_Number__c != oldValue.Timberline_Customer_Number__c ||
                newAccount.Phone != oldValue.Phone ||   
                newAccount.BillingStreet != oldValue.BillingStreet ||
                newAccount.BillingState != oldValue.BillingState ||
                newAccount.BillingPostalCode != oldValue.BillingPostalCode ||   
                newAccount.BillingCountry != oldValue.BillingCountry || 
                newAccount.BillingCity != oldValue.BillingCity ||
                newAccount.Tax_Group__c != oldValue.Tax_Group__c)
            {
                // There was a change so we need to send it to Timberline
                sendToTimberline.add(newAccount.id);
            }
            // Also check to see if the manual flag is set, in that case send, and check the flag as off
            else if(newAccount.Send_to_Timberline__c )
            {   
                newAccount.Send_to_Timberline__c = false;
                
                // add the account to the set
                sendToTimberline.add(newAccount.id);
            }
        }
   
        // Send all the elements
        if(sendToTimberline.size() > 0 && !System.isFuture())
        {
            TimberlineSynch.synchAccount(sendToTimberline);
        }
    }
    
    
    if( trigger.isInsert && trigger.isAfter ){
        AccountTriggerUtility.afterAccountInsert( trigger.new );
    }
    
    if( trigger.isUpdate && trigger.isAfter ){
        AccountTriggerUtility.afterAccountUpdate( trigger.oldMap, trigger.new );
    }
    
}