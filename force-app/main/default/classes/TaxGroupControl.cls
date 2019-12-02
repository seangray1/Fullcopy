//version 1.0
//created on - 07/01/2016
//Util class for tax group control operations
public class TaxGroupControl 
{    
    /** List of email addresses who should receive notice when tax group 
     *  refresh is initiated and when it completes.  Note that all recipients'
     *  email addresses will be included in the "TO" line of the email */
    public static List<String> REFRESH_NOTIFICATION_RECIPIENTS = new List<String> 
    {
        'jeff.dorner@amer-tech.com'
    };
    
    /**************************************************************************
     * Checks if tax groups need to be refreshed based on triggering records
     *
     * @param records:
     *         A list of records assumed to be in a trigger.new context.  If
     *         any of the records have the Refresh_Tax_Groups__c flag set, the
     *         Tax groups will all be refreshed and the flag will be unset.
     */
    public static void taxGroupRefreshTrigger(List<Tax_Group__c> records) 
    {    
        // Nothing useful can be done with an empty record set
        if(records != null && !records.isEmpty()) 
        {
            // Find any records that are specified as refreshing Tax Group.  Update
            // any records to uncheck the reflresh flag so that the tax groups
            // don't continuously update
            boolean refresh = false;
            for (Tax_Group__c r : records) 
            {    
                if (r.Refresh_Tax_Groups__c) 
                {
                    r.Refresh_Tax_Groups__c = false;
                    refresh = true;
                }
                
            }
            
            // Refresh only if necessary
            if (refresh) 
            {    
                // Generate a reference code for this refresh (used for notifications)
                String ref = String.valueOf(DateTime.now().getTime());
                
                // Notify email recipients
                refreshBeginNotification(ref);
                
                // Asynchronously refresh tax groups
                taxGroupRefresh(ref);
            }
        }
    }
    
    /**************************************************************************
     * Refreshes Tax Group data from Timberline.
     *
     * Makes a callout to Timberline to retrieve tax group information so that
     * it can be loaded into Salesforce.
     *
     */
    @future (callout=true)
    public static void taxGroupRefresh( String ref ) 
    {    
        // Information that will be included in the complete notification
        Boolean isSuccess = true;
        String notificationMsg = null;
        
        // Load new tax group data into this value
        List<Tax_Group__c> newTaxGroupData = new List<Tax_Group__c>();
        
        try 
        {    
            // Capture errors related to tax group retrieval
            try 
            {    
                // Get Tax Group records
                newTaxGroupData = getTaxGroupsFromTimberline();
            } 
            catch (Exception e) 
            {    
                System.debug(Logginglevel.WARN, 'TaxGroupControl.taxGroupRefresh: An error occurred retrieving data from Timberline\n'+e.getStackTraceString());
                throw e;   
            }
            
            // Capture errors related to Tax Group DML operations
            try {
                
                // If we have tax group data from Timberline, upsert it
                if (newTaxGroupData == null || newTaxGroupData.isEmpty()) 
                {    
                    // No Tax Group info
                    newTaxGroupData = new List<Tax_Group__c>();
                    System.debug(Logginglevel.WARN, 'TaxGroupControl.taxGroupRefresh: No Tax Group data to upsert.');
                    
                } 
                else 
                {    
                    // Tax Group info, upsert the data matching on Timberline ID
                    System.debug(Logginglevel.INFO, 'TaxGroupControl.taxGroupRefresh: Upserting '+newTaxGroupData.size()+' Tax Group records');
                    if( !newTaxGroupData.isEmpty())
                    {
                        upsert newTaxGroupData Timberline_Id__c;
                    }
                    
                }
                
                // Everything completed successfully.  Prepare the notification
                // variables for the follow-up notice.
                isSuccess = true;
                notificationMsg = 'Upserted '+newTaxGroupData.size()+' Tax Group records';
                
            } catch (Exception e) {
                
                System.debug(Logginglevel.WARN, 'TaxGroupControl.taxGroupRefresh: An error occurred upserting data into Salesforce\n'+e.getStackTraceString());
                throw e;
                
            }
            
        } catch (Exception e) {
            System.debug('Error while refreshing tax group data ' + e);
            // We need to set up a string value for the email notification so
            // that the admin is alerted to the failure.
            isSuccess = false;
            notificationMsg = 'Failed refresh Tax Group data:\n'+e.getStackTraceString();
            
        }
        
        // Notify administrators of the result of the process
        refreshCompleteNotification(ref, isSuccess, notificationMsg);
        
    }
    
    
    
    /**************************************************************************
     * Retrieves tax group information from Timberline
     *
     * Makes the appropriate API call to the timberline Middle Tier to retrieve
     * tax group data.  Interprets the response to this callout and turns the
     * information into actual Tax Group records.
     *
     * TODO: Should this include a date parameter?  The overall record count
     * (~1.2k) seems small enough, especially given the size of each record,
     * that doing a full refresh would be safest
     */
    public static List<Tax_Group__c> getTaxGroupsFromTimberline() {
        // TODO: Callout to Timberline!
        // TODO: Yes, it's just that easy
        return TimberlineSynch.synchTaxData();
    }
    
    
    
    /**************************************************************************
     * Sends a notification email to the notification recipients which states
     * that the Tax Group refresh has begun.
     *
     * @param ref
     *         A "unique" identifier for this asyncrhonous call.  It will be
     *         included in the email subject and can help with email threading
     *         or associating the two notifications together.
     */
    public static void refreshBeginNotification(String ref) {
        
        // Make sure that we have notification recipients.  If not, end
        if (REFRESH_NOTIFICATION_RECIPIENTS == null || REFRESH_NOTIFICATION_RECIPIENTS.isEmpty()) {
            System.debug(Logginglevel.INFO, 'TaxGroupControl.refreshBeginNotification: Skipping notification because there are no recipients defined');
            return;
        }
        
        try {
        
            // Generate the email to send
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(REFRESH_NOTIFICATION_RECIPIENTS);
            mail.setReplyTo('noreply@atirestoration.my.salesforce.com');
            mail.setSenderDisplayName('Salesforce Notifier');
            mail.setSubject('A Tax Group refresh has been requested (ref: '+ref+')');
            mail.setPlainTextBody(UserInfo.getFirstName()+' '+UserInfo.getLastName()+' ('+UserInfo.getUserId()+')'
                                  + ' has initiated a refresh of Tax Group data in Salesforce.\n'
                                  + 'This process will query Timberline for updated Tax Group data and update'
                                  + ' the information in Salesforce.  No further action is required, this is'
                                  + ' simply a notification.\n'
                                  + 'You will receive a second notification when the process is complete.\n\n'
                                  + 'Regards, Salesforce Notifier');
            
            // Send the email
            Messaging.sendEmail(new Messaging.Email[] {mail});
            
        } catch (Exception e) {
            
            // Something failed sending a notification.  Honestly, this is far
            // from the end of the world.  Log+Suppress!
            System.debug(Logginglevel.WARN, 'TaxGroupControl.refreshBeginNotification: Notification send failed! '+e.getMessage()+'\n'+e.getStackTraceString());
            
        }
        
    }
    
    
    
    /**************************************************************************
     * Sends a notification email to the notification recipients which states
     * that the Tax Group refresh has begun.
     *
     * @param ref
     *         A "unique" identifier for this asyncrhonous call.  It will be
     *         included in the email subject and can help with email threading
     *         or associating the two notifications together.
     * @param isSuccess
     *         True if the process completed successfully, false otherwise.
     * @param notice
     *         Information about the completed event.  In the case of a success
     *         this should contain spot-check type information such as the
     *         number of records updated or added.  In the event of an error,
     *         this should return helpful information.  It is assumed that the
     *         audience of this email is Salesforce admins, so things like
     *         stack traces should be acceptible.
     */
    private static void refreshCompleteNotification(String ref, boolean isSuccess, String notice) {
        
        // Make sure that we have notification recipients.  If not, end
        if (REFRESH_NOTIFICATION_RECIPIENTS == null || REFRESH_NOTIFICATION_RECIPIENTS.isEmpty()) {
            System.debug(Logginglevel.INFO, 'TaxGroupControl.refreshCompleteNotification: Skipping notification because there are no recipients defined');
            return;
        }
        
        // Reduce odds of NPE.  A null notice should simply display nothing.
        if (notice == null) {
            notice = '';
        }
        
        try {
        
            // Generate the email to send
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(REFRESH_NOTIFICATION_RECIPIENTS);
            mail.setReplyTo('noreply@atirestoration.my.salesforce.com');
            mail.setSenderDisplayName('Salesforce Notifier');
            mail.setSubject('Tax Group refresh '+((isSuccess)?'succeeded!':'failed')+' (ref: '+ref+')');
            
            // Notification body is different 
            mail.setPlainTextBody(' The Tax Group refresh initiated by '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+' ('+UserInfo.getUserId()+')'
                                  + 'completed.\n'
                                  + 'STATUS: '+((isSuccess)?'Succeeded':'Failed')+'\n'
                                  + 'ADDITIONAL INFORMATION:\n'
                                  + notice+'\n\n'
                                  + 'Regards, Salesforce Notifier');
            
            // Send the email
            Messaging.sendEmail(new Messaging.Email[] {mail});
            
        } catch (Exception e) {
            
            // Something failed sending a notification.  Honestly, this is far
            // from the end of the world.  Log+Suppress!
            System.debug(Logginglevel.WARN, 'TaxGroupControl.refreshCompleteNotification: Notification send failed! '+e.getMessage()+'\n'+e.getStackTraceString());
            
        }
        
    }
    
    @isTest
    private static void testTaxGroupControl() {   
                
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
     
        Tax_Group__c taxGrp = new Tax_Group__c(           
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup',
            Refresh_Tax_Groups__c = true 
        );
        insert taxGrp;
    }
   
}