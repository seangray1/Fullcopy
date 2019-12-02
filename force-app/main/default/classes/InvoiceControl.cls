public without sharing class InvoiceControl {
    
    private static Map<String,String> JobToInvoiceTaxMap = new Map<String,String>{'Account__r.Tax_Group__r.Tax1Name__c' => 'TaxGroup1__c'};
        public static Map<String, String> TAX_GROUP_TO_INVOICE_TAX_FIELD_MAP = new Map<String, String> {
            'Name'        => 'Tax_Group__c',
                'Tax1Name__c' => 'TaxGroup1__c',
                'Tax1Rate__c' => 'Tax1Rate__c',
                'Tax2Name__c' => 'TaxGroup2__c',
                'Tax2Rate__c' => 'Tax2Rate__c',
                'Tax3Name__c' => 'TaxGroup3__c',
                'Tax3Rate__c' => 'Tax3Rate__c',
                'Tax4Name__c' => 'TaxGroup4__c',
                'Tax4Rate__c' => 'Tax4Rate__c',
                //'Tax5Name__c' => 'TaxGroup5__c',
                'Tax5Rate__c' => 'Tax5Rate__c',
                //'Tax6Name__c' => 'TaxGroup6__c',
                'Tax6Rate__c' => 'Tax6Rate__c',
                //'Tax7Name__c' => 'TaxGroup7__c',
                'Tax7Rate__c' => 'Tax7Rate__c',
                //'Tax8Name__c' => 'TaxGroup8__c',
                'Tax8Rate__c' => 'Tax8Rate__c',
                //'Tax9Name__c' => 'TaxGroup9__c',
                'Tax9Rate__c' => 'Tax9Rate__c'
                };
                    
                    /**************************************************************************
* Sets the invoice number (and thus, the name) of invoices
*
* @param invoices:
*         A list of invoices, presumably from a before insert/update call,
*         i.e., they must be editable but need not have IDs, that should
*         potentially have their invoice numbers set.  Only invoices
*         matching the entry criteria will actually have invoice numbers
*         set.
*/
                    public static void setInvoiceNumbers(List<Invoice__c> invoices) {
                        
                        // Validate preconditions
                        if (invoices == null || invoices.isEmpty()) {
                            System.debug(Logginglevel.INFO, 'InvoiceControl.setInvoiceNumbers: Argument contains no invoices to process');
                            return;
                        }
                        
                        // Ignore all invoices that don't have jobs and sort invoices by job
                        // number
                        Map<Id, List<Invoice__c>> invoiceJobBuckets = new Map<Id, List<Invoice__c>>();
                        for (Invoice__c i : invoices) {
                            if (i.ATI_Job__c != null) {
                                if (! invoiceJobBuckets.containsKey(i.ATI_Job__c)) {
                                    invoiceJobBuckets.put(i.ATI_Job__c, new List<Invoice__c>{i});
                                } else {
                                    invoiceJobBuckets.get(i.ATI_Job__c).add(i);
                                }
                            }
                        }
                        
                        // No buckets = no invoices = no work
                        if (invoiceJobBuckets.isEmpty()) {
                            System.debug(Logginglevel.INFO, 'InvoiceControl.setInvoiceNumbers: No valid invoices to process');
                            return;
                        }
                        
                        // Define a mapping between Job ID and job number
                        Map<Id, String> jobNumbers = new Map<Id, String>();
                        
                        // Determine the current incremental value for each job
                        AggregateResult[] maxResults = [SELECT ATI_Job__c,  ATI_Job__r.Job_Number__c jn, 
                                                        MAX(Invoice_Number_Incremental__c)m
                                                        FROM Invoice__c
                                                        WHERE ATI_Job__c IN :invoiceJobBuckets.keySet()
                                                        GROUP BY ATI_Job__c,  ATI_Job__r.Job_Number__c];
                        
                        // Generate a mapping from job ID to nexts incremental
                        Map<Id, Integer> invoiceIncrementals = new Map<Id, Integer>();
                        for (AggregateResult ar : maxResults) {
                            
                            // Retrieve the current incremental value
                            Decimal incRaw = (Decimal) ar.get('m');
                            Integer inc = (Integer) ((incRaw == null) ? 0 : incRaw.round());
                            
                            // Get the job information
                            Id jobId = (Id) ar.get('ATI_Job__c');
                            invoiceIncrementals.put(jobId, inc);
                            
                            String jobNumber = (String) ar.get('jn');
                            jobNumbers.put(jobId, jobNumber);
                            
                        }
                        
                        // Go through each of the invoices that may not have numbers yet
                        Set<Id> jobIdsForFirstInvoices = new Set<Id>();
                        for (Id jobId : invoiceJobBuckets.keySet()) {
                            if (! jobNumbers.keySet().contains(jobId)) {
                                jobIdsForFirstInvoices.add(jobId);
                            }
                        }
                        
                        // Get information for the first invoices per job
                        if (! jobIdsForFirstInvoices.isEmpty()) {
                            
                            // Get job numbers for all of the first invoices per job
                            List<ATI_Job__c> jobs = [SELECT Id, Job_Number__c FROM ATI_Job__c WHERE Id IN :jobIdsForFirstInvoices];
                            
                            // Retain the information for the first invoice per job
                            for (ATI_Job__c j : jobs) {
                                invoiceIncrementals.put(j.Id, 0);
                                jobNumbers.put(j.Id, j.Job_Number__c);
                            }
                            
                        }
                        
                        // Go through each of the input jobs
                        for (Id jobId : invoiceJobBuckets.keySet()) {
                            
                            // Normalize job data from the aggregate result
                            Integer inc = invoiceIncrementals.get(jobId);
                            String jobNumber = jobNumbers.get(jobId);
                            
                            System.debug('InvoiceControl.setInvoiceNumbers: Handling Job '+jobNumber+' ['+jobId+']. Current incremental: '+inc);
                            
                            // Go through each of the invoices related to this job
                            for (Invoice__c i : invoiceJobBuckets.get(jobId)) {
                                
                                // Check if the invoice needs an incremental value
                                if (i.Invoice_Number_Incremental__c == null) {
                                    inc += 1;
                                    i.Invoice_Number_Incremental__c = inc;
                                }
                                
                                // Get the integer value of the invoice incremental (while this
                                // may sometimes be redundant, it is safer to do it every time)
                                Integer invInc = (Integer) i.Invoice_Number_Incremental__c.round();
                                
                                System.debug('InvoiceControl.setInvoiceNumbers: Handling invoice ['+i.Id+'] for job ['+jobId+']. Current incremental: '+invInc);
                                
                                // If a job number was not available, add an error
                                if (jobNumber == null) {
                                    i.addError('Both "Job Number" fields must be populated on the associated Job before this record can be saved.'+
                                               '  Please fix the Job then re-save this invoice.');
                                }
                                
                                // Set the invoice name based on the job number (no hyphens)
                                // and the invoice incremental
                                String invoiceNumber = jobNumber.replace('-','');
                                invoiceNumber = invoiceNumber + '-' + ADCUtil_Base.forceStringLength((''+invInc), 3, '0', false);
                                
                                System.debug('InvoiceControl.setInvoiceNumbers: Invoice number for invoice ['+i.Id+'] calculated: '+invoiceNumber);
                                
                                // Set the invoice name to the new invoice number
                                i.Name = invoiceNumber;
                                
                            }
                            
                        }
                        
                    }
    
    /**************************************************************************
* Set Tax Group.    Method that will query all the tax group data from the
*                   account and then set the information on the invoice object
* 
* @param newRecords:
*         A list of invoices in the "before" context.  All invoices does not
*         have IDs
*/
    public static void setTaxGroup(List<Invoice__c> invoices, Map<Id, Invoice__c> oldInvoices)
    {
        //return;
        System.debug('InvoiceControl.setTaxGroup: Invoices: '+ invoices);
        
        // Determine which invoices need tax info updated
        List<Invoice__c> newRecords = new List<Invoice__c>();
        Set<Id> billingAccountIds = new Set<Id>();
        
        // Different process for going through the invoices if this is insert
        // or if it is update
        if (oldInvoices != null)
        {
            for(Invoice__c ni : invoices)
            {
                // Get information about the old value of the invoice
                Invoice__c oi = oldInvoices.get(ni.Id);
                
                // Determine if the invoice needs a refresh.
                // 1) If there is data in Bill To and the tax group information is
                //    current missing OR
                // 2) The Bill To information has changed
                if ((ni.Bill_To__c != null && ni.Tax_Group__c == null) || (ni.Bill_To__c != oi.Bill_to__c))
                {
                    System.debug('InvoiceControl.setTaxGroup: Invoice ['+ni.Id+'] with Account ['+ni.Bill_To__c+'] will receive new tax data');
                    newRecords.add(ni);
                    if (ni.Bill_To__c != null)
                    {
                        billingAccountIds.add(ni.Bill_To__c);
                    }
                }
                
            }
        }
        else
        {
            for(Invoice__c ni : invoices)
            {
                if (ni.Bill_To__c != null)
                {
                    System.debug('InvoiceControl.setTaxGroup: New Invoice with Account ['+ni.Bill_To__c+'] will receive new tax data');
                    newRecords.add(ni);
                    billingAccountIds.add(ni.Bill_To__c);
                }
            }
        }
        
        // If no invoices need a refresh, we are done
        if (newRecords.isEmpty())
        {
            System.debug('InvoiceControl.setTaxGroup: No candidate invoices found.  Aborting function.');
            return;
        }
        
        // Localize the field mapping
        Map<String, String> fieldMap = InvoiceControl.TAX_GROUP_TO_INVOICE_TAX_FIELD_MAP;
        
        // Get the Jobs and the tax group
        Map<Id, Account> taxAccounts;
        taxAccounts = new Map<Id, Account> (
            [SELECT Id, Tax_Group__c,
             Tax_Group__r.Name, Tax_Group__r.Tax_Rate__c,
             Tax_Group__r.Tax1Name__c, Tax_Group__r.Tax1Rate__c,
             Tax_Group__r.Tax2Name__c, Tax_Group__r.Tax2Rate__c,
             Tax_Group__r.Tax3Name__c, Tax_Group__r.Tax3Rate__c,
             Tax_Group__r.Tax4Name__c, Tax_Group__r.Tax4Rate__c,
             Tax_Group__r.Tax5Name__c, Tax_Group__r.Tax5Rate__c,
             Tax_Group__r.Tax6Name__c, Tax_Group__r.Tax6Rate__c,
             Tax_Group__r.Tax7Name__c, Tax_Group__r.Tax7Rate__c,
             Tax_Group__r.Tax8Name__c, Tax_Group__r.Tax8Rate__c,
             Tax_Group__r.Tax9Name__c,  Tax_Group__r.Tax9Rate__c
             FROM Account
             WHERE Id IN :billingAccountIds]
        );
        
        System.debug('InvoiceControl.setTaxGroup: Found the following tax accounts: '+taxAccounts.keySet());
        
        // Copy tax data from the appropriate tax groups into all of the
        // candidate invoices.
        for(Invoice__c i : newRecords)
        {
            System.debug('InvoiceControl.setTaxGroup: Attempting to get tax data for Invoice ['+i.Id+'].');
            
            // Get the relevant account
            Account taxAccount = taxAccounts.get(i.Bill_To__c);
            if (taxAccount != null)
            {
                System.debug('InvoiceControl.setTaxGroup: Found tax Account ['+taxAccount.Id+'].');
                
                // Get the relevant tax group information
                Tax_Group__c taxInfo = taxAccount.Tax_Group__r;
                if (taxInfo != null)
                {
                    System.debug('InvoiceControl.setTaxGroup: Pulling Tax Data ['+taxInfo.Id+'] into Invoice ['+i.Id+'].');
                    
                    // Copy all of the tax group info to the tax group
                    for (String sourceField : fieldMap.keySet())
                    {
                        String targetField = fieldMap.get(sourceField);
                        i.put(targetField, taxInfo.get(sourceField));
                    }
                    
                }
                else
                {
                    System.debug('InvoiceControl.setTaxGroup: No tax group found.  Emptying tax rate information.');
                    
                    // Empty out the tax data
                    for (String targetField : fieldMap.values())
                    {
                        i.put(targetField, null);
                    }
                    
                } // END Check if Tax Group was found on Tax Account
                
            }
            else
            {
                System.debug('InvoiceControl.setTaxGroup: No Tax Account found.  Emptying tax rate information');
                
                // Empty out the tax data
                for (String targetField : fieldMap.values())
                {
                    i.put(targetField, null);
                }
                
            } // END Check if Tax Account found
            
        } // END loop through invoices
        
    }
    
    
    /**************************************************************************
* Syncs Invoices to Timberline.  This assumes that 
* 
* @param newRecords:
*         A list of invoices in the "before" context.  All invoices must
*         have IDs since those IDs will be used in an @future callout.
*/
    public static void SyncToTimberline(Map<Id, Invoice__c> newRecords, 
                                        Map<Id, Invoice__c> oldRecords) {
                                            
                                            System.debug('InvoiceControl.SyncToTimberline: Invoices: '+newRecords.values());
                                            
                                            // Find all of the invoices that need to be sent to Timberline
                                            Map<Id, Invoice__c> invoicesToSync = new Map<Id, Invoice__c>();
                                            for (Invoice__c newR : newRecords.values()) {
                                                
                                                // Get the old record
                                                Invoice__c oldR = oldRecords.get(newR.Id);
                                                
                                                // Check if the record meets entry criteria
                                                if (newR.Send_To_Timberline__c == true && oldR.Send_To_Timberline__c == false) {
                                                    invoicesToSync.put(newR.Id, newR);
                                                }
                                                
                                            }
                                            
                                            // If there are no invoices that need syncing, abort
                                            if (invoicesToSync.isEmpty()) {
                                                System.debug(LoggingLevel.INFO, 'InvoiceControl.SyncToTimberline: No invoices to sync');
                                                return;
                                            }
                                            
                                            // Synchronize the reocrds.
                                            System.debug('InvoiceControl.SyncToTimberline: Syncronizing the following invoices: '+invoicesToSync.keySet());
                                            TimberlineSynch.synchInvoice(invoicesToSync.keySet(), UserInfo.getUserId());
                                            
                                        }
    
    
    
    /**************************************************************************
* Generates a Job Number that can be used as an invoice line item Job
* Number
*/
    public static String mapSFDCJobNumberToInvoice(String jobNumber) {
        
        System.debug('InvoiceControl.mapSFDCJobNumberToInvoice: Initial Job Number: '+jobNumber);
        
        // If the job number is null, it cannot be used
        if (jobNumber == null) {
            System.debug(Logginglevel.WARN, 'InvoiceControl.mapSFDCJobNumberToInvoice: Provided job number is null. Retuning empty string.');
            return '';
        }
        
        // Remove hyphens from job number
        String compactJN = jobNumber.replace('-', '');
        System.debug('InvoiceControl.mapSFDCJobNumberToInvoice: Compact Job Number: '+compactJN);
        
        // If the job number is less than 5 characters, forget it
        if (compactJN.length() < 5) {
            return jobNumber;
        }
        
        // Retrieve the last 5 characters of the job number
        String shortJN = compactJN.substring(compactJN.length()-5);
        System.debug('InvoiceControl.mapSFDCJobNumberToInvoice: Short Job Number: '+shortJN);
        
        // Hypenate, making the format xx-xxx
        String finalJN = shortJN.substring(0,2) + '-' + shortJN.substring(2,5);
        System.debug('InvoiceControl.mapSFDCJobNumberToInvoice: Final Job Number: '+finalJN);
        
        return finalJN;
        
    }
    
    
    
    /**************************************************************************
* Formats the date as necessary for Timberline, allowing for either the
* short year (2 character) or long year (4 character)
*/
    public static String mapSFDCDateToInvoice(Date d, Boolean useShortYear) {
        
        System.debug('InvoiceControl.mapSFDCDateToInvoice: Rendering '+((useShortYear)?'short':'long')+' Timberline date format of '+d);
        
        if (d == null) {
            System.debug(Logginglevel.WARN, 'InvoiceControl.mapSFDCDateToInvoice: Provided date is null. Retuning empty string.');
            return '';
        }
        
        String dateFormat = 'MMddyyyy';
        if (useShortYear) {
            dateFormat = 'MMddyy';
        }
        System.debug('InvoiceControl.mapSFDCDateToInvoice: Date Format: '+dateFormat);
        
        DateTime dt = DateTime.newInstance(d.year(),d.month(),d.day(),0,0,0);
        String finalDate = dt.format(dateFormat);
        System.debug('InvoiceControl.mapSFDCDateToInvoice: Formatted Date: '+finalDate);
        
        return finalDate;
        
    }
    
    
    /**************************************************************************
* Convenience wrapper allowing for DateTime rather than date
*/
    public static string mapSFDCDateToInvoice(DateTime dt, Boolean useShortYear) {
        
        if (dt == null) {
            System.debug(Logginglevel.WARN, 'InvoiceControl.mapSFDCDateToInvoice: Provided datetime is null. Retuning empty string.');
            return '';
        }
        
        return mapSFDCDateToInvoice(dt.date(), useShortYear);
    }
}