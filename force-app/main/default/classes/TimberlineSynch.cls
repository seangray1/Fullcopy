public with sharing class TimberlineSynch 
{
    private class TimberLineSynchException extends exception{}
    
    public static boolean isApexTest = false;
    public static HttpResponse testResponse = null;
    
    /** Denotes that this is in an @future context for the job sync function.
     *  When true, the job sync trigger should NOT attempt to syncrhonize jobs
     *  again */
    public static boolean jobSynching = false;
    
    //private static String AES_256_KEY_BASE_64 = 'b+jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';
    private static String AES_256_KEY_BASE_64 = GetSettings().AES_256_KEY_BASE_64__c;
        
    private static Blob initializationVector = Blob.valueOf('0000000000000000'); 

    /* Accounts fields */
    private static list<string> ACCOUNTFIELDS = new list<string>{'Timberline_Customer_Name__c', 'Name','AnnualRevenue','BillingCountry','BillingCity','Description','NumberOfEmployees','Website','Type','Phone','BillingStreet','BillingState','BillingPostalCode','BillingCity','Tax_Group_Timber__c', 'Timberline_BillingStreet1__c', 'Timberline_BillingStreet2__c'};
    private static Map<String, String> SFDCTOTIMBERLINEACCOUNTMAP = new Map<String, String>
    {
        'Timberline_Customer_Name__c' => 'Name', //Changed from Name to Timberline_Customer_Name__c
        'Company_Type' => 'Customer_Type', 
        'Phone' => 'Telephone',
        'Timberline_BillingStreet1__c'=> 'Address_1',
        'Timberline_BillingStreet2__c'=> 'Address_2',
        //'BillingStreet'=> 'Address_1',
        'BillingState'=> 'State',
        'BillingPostalCode'=> 'ZIP_Code',
        'Tax_Group_Timber__c' => 'Tax_Group',    //'Tax_Group',
        //'BillingCountry' => '',
        'BillingCity' => 'City'
    };
    private static String ACCOUNTIDFIELD = 'Timberline_Customer_Number__c';
    private static String ACCOUNTQUERYFIELDS = 'Timberline_Customer_Name__c, Name,AnnualRevenue,Description,NumberOfEmployees,Website,Timberline_Customer_Number__c,Type,Phone,BillingStreet,BillingState,BillingPostalCode,BillingCountry,BillingCity,Tax_Group_Timber__c,Timberline_BillingStreet1__c,Timberline_BillingStreet2__c';
    private static String ACCOUNTPATH = 'UpdateAccounts';
    
    
    /* Invoice fields */
    private static Set<string> INVOICE_FIELDS = new Set<string> {
        'Name',
        'Net_Due__c',
        'Total_Costs_Per_Contract__c',
        'Retainage_Held__c',
        'Retainage_Held_percent__c',
        'Retainage_Amount__c',
        'Memo__c',
        'Taxable_Amount__c',
        'Tax_Group__c',
        'Total_Tax__c',
        'Bill_to_Tax_Group__c',
        'Bill_to_Tax_Group__r.Timberline_Id__c',
        
        'Bill_To__r.Timberline_Customer_Number__c',
        'LastModifiedDate',
        'Due_Date__c',
        'Total_Credits__c',
        
        'Bill_to_Tax_Group__r.Tax1Name__c',
        'Bill_to_Tax_Group__r.Tax1Rate__c',
        'Bill_to_Tax_Group__r.Tax2Name__c',
        'Bill_to_Tax_Group__r.Tax2Rate__c',
        'Bill_to_Tax_Group__r.Tax3Name__c',
        'Bill_to_Tax_Group__r.Tax3Rate__c',
        'Bill_to_Tax_Group__r.Tax4Name__c',
        'Bill_to_Tax_Group__r.Tax4Rate__c',
        'Bill_to_Tax_Group__r.Tax5Name__c',
        'Bill_to_Tax_Group__r.Tax5Rate__c',
        'Bill_to_Tax_Group__r.Tax6Name__c',
        'Bill_to_Tax_Group__r.Tax6Rate__c',
        'Bill_to_Tax_Group__r.Tax7Name__c',
        'Bill_to_Tax_Group__r.Tax7Rate__c',
        'Bill_to_Tax_Group__r.Tax8Name__c',
        'Bill_to_Tax_Group__r.Tax8Rate__c',
        'Bill_to_Tax_Group__r.Tax9Name__c',
        'Bill_to_Tax_Group__r.Tax9Rate__c'
        /*,
        'TaxGroup1__c',
        'Tax1Rate__c',
        'TaxGroup2__c',
        'Tax2Rate__c',
        'TaxGroup3__c',
        'Tax3Rate__c',
        'TaxGroup4__c',
        'Tax4Rate__c',
        'TaxGroup5__c',
        'Tax5Rate__c',
        'TaxGroup6__c',
        'Tax6Rate__c',
        'TaxGroup7__c',
        'Tax7Rate__c',
        'TaxGroup8__c',
        'Tax8Rate__c',
        'TaxGroup9__c',
        'Tax9Rate__c'*/
        
    };
    private static Set<String> INVOICE_LI_FIELDS = new Set<String> {
        'Id',
        'Amount__c',
        'Description__c',
        'Taxable__c',
        'IsCredit__c',
        'Note__c'
    };
    private static String INVOICEIDFIELD = 'Timberline_Customer_Number__c';
    private static string INVOICEPATH = 'UpdateInvoices';

    
    
    /* Job fields */
    private static list<string> JOBFIELDS = new list<string>{'Name','Job_Name__c','GL_Account_Prefix__c','Project_Site_Address__c','Project_Site_Fax__c','Division__c','Project_Site_City__c','Project_Site_State__c','Project_Site_Zipcode__c','County__c','Work_Phone__c','Project_Manager_Timber__c','Superintendent_Ops_Timber__c','Account_Executive_1_Timber__c','Account_Executive_2_Timber__c','City_of_LA_Timber__c','Project_Type__c','Superintendent__c','Estimated_Amount__c', 'Gross_Profit__c', 'Status__c', 'Date_Time_Taken__c', 'Project_Site_Address_2__c'};
    private static Map<String, String> SFDCTOTIMBERLINEJOBMAP = new Map<String, String>
    {
        'Job_Number__c' => 'Job',
        'Job_Name__c' => 'Description',
        'GL_Account_Prefix__c' => 'Cost_Account_Prefix',
        'Project_Site_Address__c' => 'Address_1',
        'Project_Site_City__c'=> 'City',
        'Project_Site_State__c' => 'State',
        'Project_Site_Zipcode__c' => 'ZIP_Code',
        'County__c' => 'County',
        'Work_Phone__c' => 'Site_Phone',
        'Division__c' => 'Type',
        'Project_Manager_Timber__c' => 'Sales_Rep',
        //'Superintendent_Ops_Timber__c' => 'Project_Mgr',
        'Account_Executive_1_Timber__c' => 'Marketing_EE',
        'Account_Executive_2_Timber__c' => 'Marketing_EE_2',
        'City_of_LA_Timber__c' => 'City_of_LA',
        'Project_Site_Fax__c' => 'Fax_Phone',
        'Superintendent__c' => 'PROJECT_MGR'           //newly Added        
        //'Estimated_Amount__c' => 'SFEst',              //newly Added
        //'Timberline_GPM__c' => 'SFGPPercent',            //newly Added
        //'Status__c' => 'SFJobStat',                    //newly Added
        //'Date_Time_Taken__c' => 'SFLeadDate',          //newly Added
        //'Project_Site_Address_2__c' => 'Address_2'     //newly Added
    };
    private static String JOBIDFIELD = 'Job_Number__c';
    private static string JOBPATH = 'UpdateJobs';



    /* Forecast Fields */
    private static list<string> FORECASTFIELDS = new list<string>{'Id','Job_to_Date_Cost__c','Job_to_Date_dollars_Paid__c','Year_to_Date_Costs__c','Year_to_Date_Dollars_Paid__c','Quarter_to_Date_Costs__c','Quarter_to_date_dollars_paid__c','Month_to_Date_Costs__c','Month_to_Date_Paid__c','Last_Month_Costs__c','Last_Month_Dollars_Paid__c','Next_Month_costs__c','Next_Month_Dollars_Paid__c','Job_to_Date_Billed__c','Job_to_Date_Payments__c','Year_to_Date_qw__c','Quarter_to_date_work_illedQuarter_to_da__c','Month_to_Date_Billed__c','Last_Month_Work_Billed__c','Next_month_work_billed__c','Receivable_Balance__c'};
    private static Map<String, String> SFDCTOTIMBERLINEFORECASTMAP = new Map<String, String>
    {};
    private static Map<String, String> TIMBERLINETOSFDCFORECASTMAP = new Map<String, String>
    {
        'JTD_Cost'=> 'Job_to_Date_Cost__c',
        'JTD_Dollars_Paid'=> 'Job_to_Date_dollars_Paid__c',
        'YTD_Cost'=> 'Year_to_Date_Costs__c',
        'YTD_Dollars_Paid'=> 'Year_to_Date_Dollars_Paid__c',
        'QTD_Cost'=> 'Quarter_to_Date_Costs__c',
        'QTD_Dollars_Paid'=> 'Quarter_to_date_dollars_paid__c',
        'MTD_Cost'=> 'Month_to_Date_Costs__c',
        'MTD_Dollars_Paid'=> 'Month_to_Date_Paid__c',
        'LM_Cost'=> 'Last_Month_Costs__c',
        'LM_Dollars_Paid'=> 'Last_Month_Dollars_Paid__c',
        'NM_Cost'=> 'Next_Month_costs__c',
        'NM_Dollars_Paid'=> 'Next_Month_Dollars_Paid__c',
        'JTD_Work_Billed'=> 'Job_to_Date_Billed__c',
        'JTD_Payments'=> 'Job_to_Date_Payments__c',
        'YTD_Work_Billed'=> 'Year_to_Date_qw__c',
        'QTD_Work_Billed'=> 'Quarter_to_date_work_illedQuarter_to_da__c',
        'MTD_Work_Billed'=> 'Month_to_Date_Billed__c',
        'LM_Work_Billed'=> 'Last_Month_Work_Billed__c',
        'NM_Work_Billed'=> 'Next_month_work_billed__c',
        'Receivable_Balance' => 'Receivable_Balance__c'
    };
    private static String FORECASTIDFIELD = 'Job_Number__c';
    private static string FORECASTPATH = 'GetForecasts';
    private static String FORECASTSFIELD = 'Forecast_Last_Successful_Timber_Update__c';
    private static String FORECASTLFIELD = 'Forecast_Last_Timberland_Update__c';
    
    private static String TAXPATH = 'GetTax';
    
    /*private static MAP<String,String> TAXFIELDS = new Map<String,String>
    {
        'TaxGroup1__c'=>'Tax1Rate__c',
        'TaxGroup2__c'=>'Tax2Rate__c',
        'TaxGroup3__c'=>'Tax3Rate__c',
        'TaxGroup4__c'=>'Tax4Rate__c',
        'TaxGroup5__c'=>'Tax5Rate__c',
        'TaxGroup6__c'=>'Tax6Rate__c',
        'TaxGroup7__c'=>'Tax7Rate__c',
        'TaxGroup8__c'=>'Tax8Rate__c',
        'TaxGroup9__c'=>'Tax9Rate__c'
    };*/
    
    /* authenticate credentials  */
    public static String AUTHENTICATECREDENTIALS = 'CheckAuth';
    
    
    
    /* update fields */
    private static String SFIELD = 'Last_Successful_Timberland_Update__c';
    private static String LFIELD = 'Last_Timberland_Update__c';
    
    /****************************************************
    *
    *   synchAccount:
    *
    *   PARAMS:
    *           Set<id> accounts: Account ids that need
    *           to be sent to Timberline        
    *
    *   RETURN: NONE
    *
    *****************************************************/
    //Added: Try catch to log success and error-[MarkCarloMempin]
    @future (callout=true)
    public static void synchAccount(Set<id> accounts)
    {       
        /*SystemLogs__c systemlog = SystemLogs__c.getInstance('TimberlineSynch');//other options: login, prerellogin.pre
            if(systemlog==null){
            systemlog = new SystemLogs__c(Name='TimberlineSynch', Log_Error__c=true, Log_Success__c=true);
            }
        */    
        try{
            CT_Logging.setSeverity('Info');
                        
            String query = 'Select ' + TimberlineSynch.ACCOUNTQUERYFIELDS + ' from Account where id IN :accounts FOR UPDATE';
            
            // Query for the accounts
            List<Sobject> accts = Database.query(query);            
                       
            // Create list of Objects
            List<string> objects = createObjectJson(accts, TimberlineSynch.ACCOUNTFIELDS, TimberlineSynch.SFDCTOTIMBERLINEACCOUNTMAP, TimberlineSynch.ACCOUNTIDFIELD);
                      
            // Create request
            string request = createRequest(objects);
            
            System.debug('The request: ' + request);
            
            CT_Logging.addMessage('Debug', 'TimberlineSynch.synchAccount', 'Created request = ' + request);
            
            // Send request
            HttpResponse result = sentToTimberline(request, TimberlineSynch.ACCOUNTPATH);
            
            // Get the accounts one more time. Stupid Person Account
            query = 'Select Id, Last_Successful_Timberland_Update__c, Last_Timberland_Update__c, Timberline_Customer_Number__c from Account where id IN :accounts';
            
            // Query for the accounts
            List<Sobject> accts2 = Database.query(query);
            
            // Parse the response
            parseResponse(result,TimberlineSynch.ACCOUNTIDFIELD, accts2, TimberlineSynch.SFIELD, TimberlineSynch.LFIELD,null,false,false);
            
            CT_Logging.addMessage('Debug', 'TimberlineSynch.synchAccount', '== Responses Parsed ==');            
            
        }catch(Exception e){
            /*if(systemlog.Log_Success__c==true){
                Error_Success_Log__c log = new Error_Success_Log__c();
                //log.BatchId__c = '';
                log.ErrorMessage__c = 'log error' + e;
                //log.PrimaryRecordsIntegrated__c = '';
                
                insert log;
            }
            if(systemlog.Log_Error__c==true){
                Error_Success_Log__c log = new Error_Success_Log__c();
                //log.BatchId__c = '';
                log.ErrorMessage__c = 'log error' + e;
                //log.PrimaryRecordsIntegrated__c = '';
                
                insert log;
            }*/
            CT_Logging.addMessage('Error', 'TimberlineSynch.synchAccount', '== Error =='+e.getMessage());
        }
        CT_Logging.SaveLogs();
    }
    
    
    
    /****************************************************
    *
    *   synchInvoice:
    *
    *   PARAMS:
    *           Set<id> invoices: invoices ids that need
    *           to be sent to Timberline
    *
    *   RETURN: NONE
    *
    *****************************************************/
    //Added: Try catch to log success and error-[MarkCarloMempin]
    @future (callout=true)
    public static void synchInvoice(Set<id> invoiceIds, Id initiatingUserId)
    {
    
        /*SystemLogs__c systemlog = SystemLogs__c.getInstance('TimberlineSynch');//other options: login, prerellogin.pre
            if(systemlog==null){
            systemlog = new SystemLogs__c(Name='TimberlineSynch', Log_Error__c=true, Log_Success__c=true);
            }
        */
        try{
            CT_Logging.setSeverity('Info');
                        
            User initiatingUser = [SELECT Id, Email, FirstName, LastName,
                                          TUserName__c, TPassword__c
                                   FROM User
                                   WHERE Id = :UserInfo.getUserId()
                                   LIMIT 1];
            System.debug('TimberlineSynch.synchInvoice: Initiating user: '+initiatingUser);
            
            CT_Logging.addMessage('Debug', 'TimberlineSynch.synchInvoice', 'Initiating user: '+initiatingUser);
            
            // Generate string field lists
            String invoiceFields   = ADCUtil_Base.strJoin(',', TimberlineSynch.INVOICE_FIELDS, 'Id');
            String invoiceLIFields = ADCUtil_Base.strJoin(',', TimberlineSynch.INVOICE_LI_FIELDS,  'Id');
            
            // Generate the query for loading Invoices
            String query = 'SELECT '+invoiceFields+', '+
                                   '(SELECT '+invoiceLIFields+' '+
                                   'FROM Invoice_Line_Items__r '+
                                   'WHERE Amount__c != null) '+
                           'FROM Invoice__c WHERE Id IN :invoiceIds FOR UPDATE';
            System.debug('TimberlineSynch.synchInvoice: Invoice Query: '+query);
            
            CT_Logging.addMessage('Debug', 'TimberlineSynch.synchInvoice', 'Invoice Query: '+query);
            
            // Query for all of the records
            List<Invoice__c> invoices = Database.query(query);

            // Special mapping used for updating invoices that may have failed.
            // The key used in this map should be the value returned by the API as
            // the ID
            Map<String, Invoice__c> apiInvoiceMap = new Map<String, Invoice__c>();
            
            // Generate rows for invoices
            List<Map<String, Object>> requestObjects = new List<Map<String, Object>>();
            
            for (Invoice__c i : invoices) {
                
                Decimal TotalAmount = i.Total_Costs_Per_Contract__c + i.Total_Tax__c; // - i.Total_Credits__c (DO NOT SEND CREDITS TO TIMBERLINE)
                TotalAmount.setScale(2); // Round to two decimal places
                Decimal TxAmount = 0.0;
                
                // Generate the map for this invoice
                Map<String, Object> row = new Map<String, Object>();
                row.put('_recordtype',    'I');
                row.put('customer',       i.Bill_To__r.Timberline_Customer_Number__c);
                //row.put('contract',       ''); // ATI does not use contracts
                //row.put('draw',           '');
                row.put('invoice',        i.Name);
                row.put('invoice_date',   InvoiceControl.mapSFDCDateToInvoice(i.Due_Date__c, false));
                row.put('amount',         TotalAmount);
                row.put('retainage_held', i.Retainage_Amount__c);
                //row.put('reference',      '');
                row.put('description',    ((i.Memo__c != null) ? i.Memo__c.substring(0, Math.min(30, i.Memo__c.length())) : ''));
                row.put('due_date',       InvoiceControl.mapSFDCDateToInvoice(i.Due_Date__c, false));
                requestObjects.add(row);
                System.debug('TimberlineSynch.synchInvoice: I row: '+row);
                
                // Remember this invoice by the timberline key
                apiInvoiceMap.put(i.Name, i);
                
                // get the values
                Id TaxGroupId = i.Bill_to_Tax_Group__c;
                String TaxGroupName = i.Bill_to_Tax_Group__r.Timberline_Id__c;
                
                // Generate line items for each line item
                for (Invoice_Line_Item__c li : i.Invoice_Line_Items__r) {
                    if (li.IsCredit__c) continue; // DO NOT SEND CREDITS TO TIMBERLINE
                    if (li.Note__c) continue; // DO NOT SEND NOTES TO TIMBERLINE
                    
                    Decimal liAmount = li.Amount__c;
                    liAmount.setScale(2); // Round off!
                    
                    TxAmount += liAmount;
                    
                    row = new Map<String, Object>();
                    row.put('_recordtype',            'D');
                    row.put('amount_type',            '1');
                    //row.put('contract_item',          '');
                    
                    //row.put('extra',                  '');
                    //row.put('cost_code',              '');
                    row.put('tax_group',              TaxGroupName);
                    //row.put('tax_id',                 '');
                    row.put('exempt_status',          (li.Taxable__c?'Taxable':'Non-Taxable'));
                    //row.put('units',                  '');
                    row.put('amount',                 liAmount);
                    row.put('retainage',              (i.Retainage_Held_percent__c == null || li.Amount__c == null || li.IsCredit__c) ? 0 : (i.Retainage_Held_percent__c * 0.01) * li.Amount__c);
                    //row.put('accounting_date',        '');
                    //row.put('debit_account_accrual',  '');
                    //row.put('credit_account_accrual', '');
                    //row.put('credit_account_cash',    '');
                    requestObjects.add(row);
                    System.debug('TimberlineSynch.synchInvoice: D row: '+row);
                }
                
                Decimal LastTax = null;
                
                if (TaxGroupName != null && i.Taxable_amount__c != null && TaxGroupName != '' && i.Taxable_amount__c > 0.0) {
                    
                    if (i.Bill_to_Tax_Group__r.Tax1Name__c != null && i.Bill_to_Tax_Group__r.Tax1Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax1Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax1Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    if (i.Bill_to_Tax_Group__r.Tax2Name__c != null && i.Bill_to_Tax_Group__r.Tax2Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax2Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax2Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    if (i.Bill_to_Tax_Group__r.Tax3Name__c != null && i.Bill_to_Tax_Group__r.Tax3Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax3Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax3Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    if (i.Bill_to_Tax_Group__r.Tax4Name__c != null && i.Bill_to_Tax_Group__r.Tax4Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax4Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax4Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    if (i.Bill_to_Tax_Group__r.Tax5Name__c != null && i.Bill_to_Tax_Group__r.Tax5Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax5Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax5Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    if (i.Bill_to_Tax_Group__r.Tax6Name__c != null && i.Bill_to_Tax_Group__r.Tax6Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax6Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax6Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    if (i.Bill_to_Tax_Group__r.Tax7Name__c != null && i.Bill_to_Tax_Group__r.Tax7Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax7Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax7Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    if (i.Bill_to_Tax_Group__r.Tax8Name__c != null && i.Bill_to_Tax_Group__r.Tax8Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax8Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax8Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    if (i.Bill_to_Tax_Group__r.Tax9Name__c != null && i.Bill_to_Tax_Group__r.Tax9Rate__c > 0) {
                        LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax9Rate__c * 0.01);
                        LastTax.setScale(2);
                        TxAmount += LastTax;
                        
                        row = new Map<String, Object>();
                        row.put('_recordtype',            'D');
                        row.put('amount_type',            '9');
                        row.put('tax_id',                 i.Bill_to_Tax_Group__r.Tax9Name__c);
                        row.put('exempt_status',          'Non-Taxable');
                        row.put('amount',                 LastTax);
                        requestObjects.add(row);
                    }
                    
                    System.debug('TimberlineSynch.synchInvoice: D row: '+row);
                }
                
                // Fix the rounding issues, if any
                Decimal difference = TotalAmount - TxAmount;
                if (LastTax != null && difference != 0) {
                    LastTax += difference;
                    TxAmount += difference;
                    row.put('amount', LastTax);
                }
            }
            
            // Add header information to the request body
            Map<String, Object> requestBodyBody = new Map<String, Object>();
            
            requestBodyBody.put('user', new Map<String, String>{
                'email'    => initiatingUser.Email,
                'fullname' => initiatingUser.FirstName+' '+initiatingUser.LastName
            });
            
            requestBodyBody.put('objects', requestObjects);
            
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('auth', new Map<String, String>{
                'username' => initiatingUser.TUserName__c,
                'password' => initiatingUser.TPassword__c
            });
            
            requestBody.put('body', requestBodyBody);
            
            // Generate JSON for the request
            String requestBodyJSON = JSON.serialize(requestBody);
            System.debug('TimberlineSynch.synchInvoice: requestBody: '+requestBodyJSON);
            
            CT_Logging.addMessage('Debug', 'TimberlineSynch.synchInvoice', 'RequestBody: '+requestBodyJSON);
            
            requestBodyJSON = EncodingUtil.urlEncode(requestBodyJSON, 'UTF-8');
            
            // Send request
            HTTPResponse resultResponse = sentToTimberline(requestBodyJSON, TimberlineSynch.INVOICEPATH);
            
            // If there was an error, problems!
            Integer resultStatusCode = resultResponse.getStatusCode();
            if (resultStatusCode < 200 || 300 <= resultStatusCode) {
                
                // Log the error
                System.debug(Logginglevel.ERROR, 'TimberlineSynch.synchInvoice: Response Code: '+resultStatusCode);
                System.debug(Logginglevel.ERROR, 'TimberlineSynch.synchInvoice: Response Message: '+resultResponse.getStatus());
                
                CT_Logging.addMessage('Error', 'TimberlineSynch.synchInvoice', 'Response Code: '+resultStatusCode);
                CT_Logging.addMessage('Error', 'TimberlineSynch.synchInvoice', 'Response Message: '+resultResponse.getStatus());
                
                // Unset the "Send to Timberline" flags for everything
                for (Invoice__c inv : invoices) {
                    inv.Send_To_Timberline__c = false;
                }
                
                update invoices;
                return;
                
            }
            
            String resultBodyJSON = resultResponse.getBody();
            Map<String, Object> jMap = (Map<String, Object>) JSON.deserializeUntyped(resultBodyJSON);
            
            System.debug('TimberlineSynch.synchInvoice: Response: '+jMap);
            
            CT_Logging.addMessage('Debug', 'TimberlineSynch.synchInvoice', 'Response: '+jMap);
            
            // Get the backup response code that might be in the body
            String resultStatusMsg = ((String) jMap.get('status')).toLowerCase();
            if (resultStatusMsg != null && resultStatusMsg != 'ok') {
                
                System.debug(Logginglevel.ERROR, 'TimberlineSynch.synchInvoice: Response Message: '+String.valueOf(jMap.get('detail')));
                CT_Logging.addMessage('Error', 'TimberlineSynch.synchInvoice', 'Response Message: '+String.valueOf(jMap.get('detail')));
                    
                // Unset the "Send to Timberline" flags for everything
                for (Invoice__c inv : invoices) {
                    inv.Send_To_Timberline__c = false;
                }
                
                update invoices;
                return;
                
            }
            
            // Alright, no immediate API call errors.  Update all of the records
            // in the system to correctly reflect send status
            List<Object> resultRecords = (List<Object>) TimberlineSynch.getResponseBody(jMap);
            System.Debug(LoggingLevel.DEBUG, 'Invoice Response Records: ' + resultRecords);
            
            for (Object resultRecordObj : resultRecords) {
                
                System.Debug(LoggingLevel.DEBUG, 'Invoice Response Record: ' + resultRecordObj);
                
                Map<String, Object> resultRecord = (Map<String, Object>) resultRecordObj;
                String invoiceId = (String) resultRecord.get('id');
                String invoiceStatus = (String) resultRecord.get('status');
                
                Invoice__c sfdcRecord = apiInvoiceMap.get(invoiceId);
                
                if (invoiceStatus == 'ok') {
                    //sfdcRecord.Send_To_Timberline__c = false;
                    sfdcRecord.Send_To_Timberline__c = true;
                    sfdcRecord.Last_Successful_Timberline_Sync__c = DateTime.now();
                } else {
                    sfdcRecord.Send_To_Timberline__c = false;
                }
                
            }
            
            update apiInvoiceMap.values();
            
            CT_Logging.addMessage('Info', 'TimberlineSynch.synchInvoice', 'Execution Complete');
            
            //return;
        }catch(Exception e){
            /*if(systemlog.Log_Success__c==true){
                Error_Success_Log__c log = new Error_Success_Log__c();
                //log.BatchId__c = '';
                log.ErrorMessage__c = 'log error' + e;
                //log.PrimaryRecordsIntegrated__c = '';
                
                insert log;
            }
            if(systemlog.Log_Error__c==true){
                Error_Success_Log__c log = new Error_Success_Log__c();
                //log.BatchId__c = '';
                log.ErrorMessage__c = 'log error' + e;
                //log.PrimaryRecordsIntegrated__c = '';
                
                insert log;
            }*/
            CT_Logging.addMessage('Error', 'TimberlineSynch.synchInvoice', '== Error =='+e.getMessage());
        }
        CT_Logging.SaveLogs();
    }
    
    
    
    
    
    /****************************************************
    *
    *   synchJobs:
    *
    *   PARAMS: 
    *           Set<id> jobs: jobs ids that need
    *           to be sent to Timberline
    *
    *   RETURN: NONE
    *
    *****************************************************/
    //Added: Try catch to log success and error-[MarkCarloMempin]
    @future (callout=true)
    public static void synchJobs (Set<Id > jobs)
    {
    
        /*SystemLogs__c systemlog = SystemLogs__c.getInstance('TimberlineSynch');//other options: login, prerellogin.pre
            if(systemlog==null){
            systemlog = new SystemLogs__c(Name='TimberlineSynch', Log_Error__c=true, Log_Success__c=true);
            }
        */
        try{
            CT_Logging.setSeverity('Info');            
            
            // Prevent potentially resynching jobs
            TimberlineSynch.jobSynching = true;
            
            
            
            // Query for the jobs
            //List<Sobject> jbs = Database.query(query);
          
            // Create list of Objects
            //List<string> objects = createObjectJson(jbs, TimberlineSynch.JOBFIELDS, TimberlineSynch.SFDCTOTIMBERLINEJOBMAP ,TimberlineSynch.JOBIDFIELD);
                                
            // Create request
            //string request = createRequest(objects);
            
           // System.debug('The request: ' + request);
            //CT_Logging.addMessage('Debug', 'TimberlineSynch.synchJobs', 'Created request = ' + request);
            
            // Send request
            //HttpResponse result = sentToTimberline(request, TimberlineSynch.JOBPATH);
            
            // Parse the response
            //parseResponse(result, TimberlineSynch.JOBIDFIELD,jbs, TimberlineSynch.SFIELD, TimberlineSynch.LFIELD,null,false,false);
            
            CT_Logging.addMessage('Debug', 'TimberlineSynch.synchJobs', '== Responses Parsed ==');
            
            
        }catch(Exception e){
            /*if(systemlog.Log_Success__c==true){
                Error_Success_Log__c log = new Error_Success_Log__c();
                //log.BatchId__c = '';
                log.ErrorMessage__c = 'log error' + e;
                //log.PrimaryRecordsIntegrated__c = '';
                
                insert log;
            }
            if(systemlog.Log_Error__c==true){
                Error_Success_Log__c log = new Error_Success_Log__c();
                //log.BatchId__c = '';
                log.ErrorMessage__c = 'log error' + e;
                //log.PrimaryRecordsIntegrated__c = '';
                
                insert log;
            } */           
            CT_Logging.addMessage('Error', 'TimberlineSynch.synchJobs', '== Error =='+e.getMessage());
        }
        CT_Logging.SaveLogs();
    }
    
    
    /****************************************************
    *
    *   synchForecast:
    *
    *   PARAMS: 
    *           Set<id> jobs: jobs ids that need
    *           to be sent to Timberline to synch with
    *           Forecast Data
    *
    *   RETURN: NONE
    *
    *****************************************************/
    //Added: Try catch to log success and error-[MarkCarloMempin]
    @future (callout=true)
    public static void synchForecast (Set<Id > jobs)
    {
        /*
        SystemLogs__c systemlog = SystemLogs__c.getInstance('TimberlineSynch');//other options: login, prerellogin.pre
            if(systemlog==null){
            systemlog = new SystemLogs__c(Name='TimberlineSynch', Log_Error__c=true, Log_Success__c=true);
            }
        */    
        CT_Logging.setSeverity('Info');
        try{
            // Prevent potentially resynching jobs
            TimberlineSynch.jobSynching = true;
            
            synchForecastNotFuture(jobs);
        }catch(Exception e){
            /*if(systemlog.Log_Success__c==true){
                Error_Success_Log__c log = new Error_Success_Log__c();
                //log.BatchId__c = '';
                log.ErrorMessage__c = 'log error' + e;
                //log.PrimaryRecordsIntegrated__c = '';
                
                insert log;
            }
            if(systemlog.Log_Error__c==true){
                Error_Success_Log__c log = new Error_Success_Log__c();
                //log.BatchId__c = '';
                log.ErrorMessage__c = 'log error' + e;
                //log.PrimaryRecordsIntegrated__c = '';
                
                insert log;                
            }*/
            CT_Logging.addMessage('Error', 'TimberlineSynch.synchForecast', 'Error : ' + e.getMessage());
        }
        CT_Logging.SaveLogs();
    }
    
    public static void synchForecastNotFuture (Set<Id > jobs)
    {
        CT_Logging.setSeverity('Info');
        CT_Logging.addMessage('Info', 'TimberlineSynch.synchForecastNotFuture', 'Entered in to synchForecastNotFuture method');

        // Prevent potentially resynching jobs
        TimberlineSynch.jobSynching = true;
        
      
        
        // Query for the jobs
        //List<Sobject> jbs = Database.query(query);
        CT_Logging.addMessage('Info', 'TimberlineSynch.synchForecastNotFuture', 'Fetched all Job records');
        
        // Create list of Objects
        //List<string> objects = createObjectJson(jbs, TimberlineSynch.FORECASTFIELDS, TimberlineSynch.SFDCTOTIMBERLINEFORECASTMAP ,TimberlineSynch.FORECASTIDFIELD);
        CT_Logging.addMessage('Info', 'TimberlineSynch.synchForecastNotFuture', 'Created all JSON objects');
        
        // Create request
        //string request = createRequest(objects);
        
        //System.debug('The request: ' + request);
       // CT_Logging.addMessage('Debug', 'TimberlineSynch.synchForecastNotFuture', 'Created request = ' + request);
        
        // Send request
       // HttpResponse result = sentToTimberline(request, TimberlineSynch.FORECASTPATH);
        
        // Parse the response
       // parseResponse(result,TimberlineSynch.FORECASTIDFIELD, jbs, TimberlineSynch.FORECASTSFIELD, TimberlineSynch.FORECASTLFIELD,TimberlineSynch.TIMBERLINETOSFDCFORECASTMAP,false,true);
        
        CT_Logging.addMessage('Debug', 'TimberlineSynch.synchForecastNotFuture', '== Responses Parsed ==');
        CT_Logging.addMessage('Info', 'TimberlineSynch.synchForecastNotFuture', 'Execution Complete');
    }
    
    /****************************************************
    *
    *   synchTaxData:
    *
    *   PARAMS: 
    *           NONE
    *
    *   RETURN: List<Tax_Group__c> list of all the tax groups
    *                               In timberlnad
    *
    *****************************************************/
    public static List<Tax_Group__c> synchTaxData ()
    {
        CT_Logging.setSeverity('Info');
        
        List<Tax_Group__c> elementToReturn = null;
        
        try
        {
            // Create request
            string request = createRequest(null);
            
            System.debug('The request: ' + request);
            CT_Logging.addMessage('Info', 'TimberlineSynch.synchTaxData', 'The request: ' + request);
            
            // Send request
            HttpResponse result = sentToTimberline(request, TimberlineSynch.TAXPATH);
            
            System.debug('The result: ' + result);
            CT_Logging.addMessage('Info', 'TimberlineSynch.synchTaxData', 'The result: ' + result);
            
            if(result.getStatusCode() != 200)
            {
                CT_Logging.addMessage('Error', 'TimberlineSynch.synchTaxData', 'The external call failed. Code: ' + result.getStatusCode() + 'Message: ' + result.getStatus());
                throw new TimberLineSynchException('The external call failed. Code: ' + result.getStatusCode() + 'Message: ' + result.getStatus());
            } 
            // Parse the Json to a map
            Map<String,Object> jMap = ( Map<String,Object> ) JSON.deserializeUntyped( result.getBody() );
            
            // get all the necesary fields
            String status = String.valueOf(jMap.get( 'status' ));
            String code = String.valueOf(jMap.get( 'code' )) ;
            String detail = String.valueOf(jMap.get( 'detail' ));
            
            if(code == '2')
            {
                // get the user
                User runUs =  [select id,TUserName__c, TPassword__c, Invalid_Credentials__c from User where id = :UserInfo.getUserId()];
                
                // mark the credentials as invalid
                runUs.Invalid_Credentials__c = true;
                
                //update the user
                update runUs;
            }
            else if(code == '0')
            {   
                
                Map<String,Object> body = (Map<String, Object>) TimberlineSynch.getResponseBody(jMap);
                
                /*
                Blob privateKey = EncodingUtil.base64Decode(TimberlineSynch.AES_256_KEY_BASE_64);
        
                String b = (String) jMap.get( 'body' ); 
                
                System.debug('  b: ' +  b.length());
                
                String urlDecodeBody = EncodingUtil.urlDecode(b,'UTF-8');
                
                System.debug('  urlDecodeBody.size: ' +  urlDecodeBody.length());
                
                System.debug(' urlDecodeBody: ' + urlDecodeBody );
                
                Blob b64DecodeBody = EncodingUtil.base64Decode(urlDecodeBody);
          
                System.debug(' privateKey: ' + privateKey.size());
                System.debug(' TimberlineSynch.initializationVector: ' + TimberlineSynch.initializationVector.size());
                System.debug(' b64DecodeBody: ' + b64DecodeBody.size());            
                
                Blob unEncryptedBody = Crypto.decrypt('AES256', privateKey, TimberlineSynch.initializationVector, b64DecodeBody); 
                
                System.debug(' unEncryptedBody: ' + unEncryptedBody.toString());
                
                Map<String,Object> body = ( Map<String,Object> ) JSON.deserializeUntyped(unEncryptedBody.toString());
                */
                
                System.debug(' body: ' + body );
                
                elementToReturn = new List<Tax_Group__c>();
                
                // for all the elements
                for(Object obj :body.values())
                {
                    Tax_Group__c test = new Tax_Group__c();
                    
                    system.debug('obj: ' + obj );
                    
                    Map<String,Object> timberFields = ( Map<String,Object> ) obj;
                    
                    system.debug('timberFields: ' + timberFields );
                    
                    for(String field: timberFields.KeySet())
                    {
                        
                        // set the value in the object
                        test.put(field,timberFields.get(field));
                    }
                    
                    elementToReturn.add(test);
                }
            }
            System.debug('elementToReturn: ' + elementToReturn);
            CT_Logging.addMessage('Info', 'TimberlineSynch.synchTaxData', 'elementToReturn: ' + elementToReturn);
            CT_Logging.SaveLogs();
            return elementToReturn;
        }
        catch(Exception e)
        {
            CT_Logging.addMessage('Error', 'TimberlineSynch.synchTaxData', 'Error : ' + e.getMessage());
            CT_Logging.SaveLogs();
            System.debug(Logginglevel.ERROR,'TimberlineSynch:synchTaxData there was an error: ' + e.getMessage());
            return elementToReturn; 
        }
    
    }

    
    /****************************************************
    *
    *   createObjectJson: Method that will create the Json
    *                     Object to send to Timberline  
    *
    *   PARAMS: 
    *           List<Sobject> objs:
    *           List<String> fields:
    *           String fieldId: 
    *
    *
    *   RETURN: NONE
    *
    *****************************************************/
    public static List<string> createObjectJson(List<Sobject> objs, List<String> fields,  Map<String, String> fieldMap, String fieldId)
    {        
        List<string> objects = new List<String>();
        try
        {      
            CT_Logging.setSeverity('Info');
            
            // For all the Objects create the json request
            for(Sobject theObj: objs)
            {
                String json = '{"id":"' + theObj.get(fieldId) + '","tdata":{';
    
                Boolean first = false;
                
                // for each Object get the necesary fields
                for(string field :fields)
                {
                    // Get the name of field in Timberland
                    String timberField = fieldMap.get(field);
                    
                    // If its not map, then do not add it
                    if(timberField != null)
                    {
                        // If its not the first time add a comma
                        if(first)
                        {
                            json += ',';
                        }
                    
                        json += '"' + timberField + '":';
                    }
                    else
                    {
                        continue;
                    }
                    
                    system.debug('Field: ' + field);
                    
                    // get the value of the field               
                    Object value = theObj.get(field); 
                    
                    // if the value is null then quote it
                    if(value == null || value == '')
                    {
                        // add the 'null'
                        json += '""';     //Specs. says pass blank values if values = null
                    }
                    else
                    {
                        String encoded = '' + value;
                        encoded = encoded.escapeEcmaScript();
                        encoded = encoded.replace('"', '\\"').replace('\\\'', '\''); // Escape double-quotes, and un-escape single-quotes
                        
                        // convert value in String and then add the value
                        json += '"' + encoded + '"';
                    }
                    
                    first = true;               
                }
                
                // Close the Object Json
                json += '}}';
                
                // Add the object to the list
                objects.add(json);
            }
        }
        catch(Exception e)
        {
            CT_Logging.addMessage('Error', 'TimberlineSynch.synchAccount', '== Error =='+e.getMessage());
        }
        
        return objects;
    }
    
    public static boolean checkCredentials(String username, String password)
    {
        CT_Logging.setSeverity('Info');    
        try
        {
            // Create credentials json
            String request = '{"auth":{"username":"' + username + '","password":"' + password + '"},"body":{"objects":[]}}';
            EncodingUtil.urlEncode(request, 'UTF-8');
            
            // Sent to Timberland
            HTTPResponse response = sentToTimberline(request, TimberlineSynch.AUTHENTICATECREDENTIALS);
            
            system.debug('response: ' + response);
            
            // get the code from the response
            String code =  parseResponse(response, null, null, '', '',null, true,false);
            
            system.debug('code: ' + code);
            CT_Logging.addMessage('Debug', 'TimberlineSynch.checkCredentials', '==code: ' + code);
            CT_Logging.SaveLogs();            
            
            // get the code
            if(code == '0')
            {
                return true;
            }
            else
            {
                return false;
            }
            
        }
        catch(Exception e)
        {
            CT_Logging.addMessage('Error', 'TimberlineSynch.checkCredentials', '== Error =='+e.getMessage());
            CT_Logging.SaveLogs();
            system.debug(Logginglevel.ERROR,'TimberlineSynch.checkCredentials there was an error checking credentials. Message: ' + e.getMessage());
            return false;
        }        
    }
    /****************************************************
    *
    *   createRequest:
    *
    *   PARAMS: 
    *           List<string> obj:
    *
    *
    *   RETURN: NONE
    *
    *****************************************************/  
    private static String createRequest(List<string> objs)
    {
        try
        {
            // get the user information
            User runUs =  [select id,TUserName__c, TPassword__c, Invalid_Credentials__c from User where id = :UserInfo.getUserId()];
            
            // Create credentials json
            String request = '{"auth":{"username":"' + runUs.TUserName__c + '","password":"' + runUs.TPassword__c + '"},"body":{"objects":[';
            
            if(objs != null)
            {
                // Add Objects to json
                request += ADCUtil_Base.strJoin(',',objs) + ']}}';
            }
            else
            {
                // Close json
                request += ']}}';
            }
            
            system.debug('request: ' + request);
            return EncodingUtil.urlEncode(request, 'UTF-8');
        }
        catch(Exception e) { CT_Logging.addMessage('Error', 'TimberlineSynch.createRequest', '== Error =='+e.getMessage()); }
        //CT_Logging.SaveLogs();
        return null;
    }
    
    /*********************************************************************
    *
    *   sentToTimberline:
    *
    *   PARAMS: 
    *           String request: Request send to TimberLine
    *
    *           String Path: Path for the end point and object
    *
    *
    *   RETURN: NONE
    *
    ***********************************************************************/
    private static HTTPResponse sentToTimberline(String request, String Path)
    {
        // End Point
        //String endPoint = 'http://12.187.107.21/TimberlineAPI/' + Path;        
        try
        {
            String endPoint = GetSettings().Timberline_Endpoint__c + Path;
            
            // Create the http request
            HttpRequest req = new HttpRequest();
            req.setEndPoint(endPoint);
            req.setMethod('POST');
            req.setCompressed(false);
            req.setTimeout(60000);
    
            // get the key on a blob
            Blob privateKey = EncodingUtil.base64Decode(TimberlineSynch.AES_256_KEY_BASE_64.escapeEcmaScript());
            
            // set the request on a blob
            Blob b = Blob.valueOf(request); 
            
            // encrypt request
            Blob encryptedData = Crypto.encrypt('AES256', privateKey, TimberlineSynch.initializationVector, b); 
            
            // Encode base 64
            String b64Encrypted = EncodingUtil.base64Encode(encryptedData);
           
            // URL encode
            String b64EncryptedEncoded =  EncodingUtil.urlEncode(b64Encrypted,'UTF-8');
           
            // Set the request string
            String newRequest = 'request=' + b64EncryptedEncoded;
           
            // SET the Body if the request  
            req.setBody(newRequest);
            
            System.debug('TimberlineSynch.sentToTimberline: Raw Request Object: '+req);
            System.debug('TimberlineSynch.sentToTimberline: Raw Request Body: '+req.getBody());
            
            // send the request
            Http http = new Http();
            HTTPResponse res = null;
             
            if(!TimberlineSynch.isApexTest)
            {
                res = http.send(req);
            }
            else
            {
                res = TimberlineSynch.testResponse;
            }
            
            System.debug('Response: ' + res.getBody());
            return res;
        }
        catch(Exception e) { CT_Logging.addMessage('Error', 'TimberlineSynch.sentToTimberline', '== Error =='+e.getMessage()); }
        //CT_Logging.SaveLogs();
        return null;
    }
    
    /*********************************************************************
    *
    *   parseResponse:
    *
    *   PARAMS: 
    *           String response: Request send to TimberLine
    *
    *           List<Sobject> objs: Path for the end point and object
    *
    *           String objectId: Id field in Timberland
    *   
    *           String psField:     field in the object to update if the call was
    *                           Suscessful
    *           
    *           String peField: field in the object to update if the call was
    *                           Unsuscessful
    *
    *           MAP<String, String> TimberToSFMap:  Map of fields in Timberland 
    *                                               to SFDC fields
    *
    *           Boolean onlyCredentials:    Boolean that specifies we are only
    *                                       using credentials
    *
    *           Boolean OnlyForecast:   Boolean that specifies we are only
    *                                   using Forecast
    *
    *
    *   RETURN: NONE
    *
    ***********************************************************************/
    private static string parseResponse(HttpResponse response, String objectId, List<Sobject> objs, String psField, String peField, MAP<String, String> TimberToSFMap, Boolean onlyCredentials, Boolean OnlyForecast)
    {
        System.debug(' Enter TimberlineSynch.parseResponse ');
        
        try
        {
            CT_Logging.setSeverity('Info');
            if(response.getStatusCode() != 200)
            {
                throw new TimberLineSynchException('The external call failed. Code: ' + response.getStatusCode() + 'Message: ' + response.getStatus());
            } 
            
            // Parse the Json to a map
            Map<String,Object> jMap = ( Map<String,Object> ) JSON.deserializeUntyped( response.getBody() );
            
            // get all the necesary fields
            String status = String.valueOf(jMap.get( 'status' ));
            String code = String.valueOf(jMap.get( 'code' )) ;
            String detail = String.valueOf(jMap.get( 'detail' ));
            Map<String,Object> body = null; 
        
            // If we are just loading credentials then return the code
            if(onlyCredentials)
            {
                return code;
            }
            
            System.debug(' status: ' + status );
            System.debug(' code: ' + code  );
            System.debug(' detail: ' + detail  );

            
            // There was a problem with the credentials mark error credentials in users
            if(code == '2')
            {
                // get the user
                User runUs =  [select id,TUserName__c, TPassword__c, Invalid_Credentials__c from User where id = :UserInfo.getUserId()];
                
                // mark the credentials as invalid
                runUs.Invalid_Credentials__c = true;
                
                //update the user
                update runUs;
            }
            
            if(code == '0')
            {   
                body = (Map<String, Object>) TimberlineSynch.getResponseBody(jMap);
                /*
                Blob privateKey = EncodingUtil.base64Decode(TimberlineSynch.AES_256_KEY_BASE_64);
        
                String b = (String) jMap.get( 'body' ); 
                
                System.debug('  b: ' +  b.length());
                
                String urlDecodeBody = EncodingUtil.urlDecode(b,'UTF-8');
                
                System.debug('  urlDecodeBody.size: ' +  urlDecodeBody.length());
                
                System.debug(' urlDecodeBody: ' + urlDecodeBody );
                
                Blob b64DecodeBody = EncodingUtil.base64Decode(urlDecodeBody);
          
                System.debug(' privateKey: ' + privateKey.size());
                System.debug(' TimberlineSynch.initializationVector: ' + TimberlineSynch.initializationVector.size());
                System.debug(' b64DecodeBody: ' + b64DecodeBody.size());            
                
                Blob unEncryptedBody = Crypto.decrypt('AES256', privateKey, TimberlineSynch.initializationVector, b64DecodeBody); 
                
                System.debug(' unEncryptedBody: ' + unEncryptedBody.toString());
                
                body = ( Map<String,Object> ) JSON.deserializeUntyped(unEncryptedBody.toString());
                */
                
                System.debug(' body: ' + body );
                            
                for( Sobject obj :objs)
                {
                    String theObjectId = String.valueOF(obj.get(objectId));
                    
                    try
                    {
                        
                        system.debug('Updating object with Id' + theObjectId );
    
                        Boolean okCall = false;
    
                        if(OnlyForecast)
                        {
                            // get the map of fields from timber
                            Map<String,Object> timberFields = ( Map<String,Object> ) body.get( theObjectId);
                            
                            okCall = true;
                            
                            // for all the fields that came from timberline
                            for(String field: timberFields.KeySet())
                            {
                                // get the field map
                                String sfdcField = TimberToSFMap.get(field);
                                Object value = timberFields.get(field);
                                
                                system.debug('sfdcField: ' + sfdcField + '(' + field + ') = ' + value);
                                // make sure the field is mapped
                                if(sfdcField != null)
                                {
                                    // set the value in the object
                                    obj.put(sfdcField, value);
                                }
                                else
                                {
                                    if(field != 'JOB' )
                                    {
                                        okCall = false;
                                        system.debug('ERROR AT TimberlineSynch.parseResponse: The field: ' + field + ' is not correctly mapped.');
                                    }
                                }
                            }
                        }
                        else
                        {
                            system.debug('Result' + body.get( theObjectId) );
                            
                            if(body.get( theObjectId) == 'OK')
                            {
                                system.debug('Mark as true' );
                                
                                okCall = true;
                            }
                        }
                        
                        system.debug('peField: ' + peField );
                        system.debug('datetime.now() ' + datetime.now() );
                        
                        // Mark last synch
                        obj.put(peField,datetime.now());    
                        
                        // if the call is succesufull mark succesfull field
                        if(okCall)
                        {
                            // Mark last synch succesfull
                            obj.put(psField,datetime.now());
                        }
                    }
                    catch(Exception e)
                    {
                        CT_Logging.addMessage('Error', 'TimberlineSynch.parseResponse', '== Error =='+e.getMessage()); 
                        system.debug(Logginglevel.ERROR,'ERROR AT TimberlineSynch.parseResponse: There was an error trying to parse respond for Object with Id: ' + theObjectId + 'Message: ' + e.getMessage());
                        obj.put(peField,datetime.now());
                        continue;
                    }
                }
                system.debug('objs: ' + objs ); 
                Database.update(objs, false);
            }
            else
            {
                // The call fail so just update the last update date
                for( Sobject obj :objs)
                {       
                    // Mark last synch
                    obj.put(peField,datetime.now());    
                }
                
                Database.update(objs, false);
            }
            
            System.debug(' Exit TimberlineSynch.parseResponse ');
            return '';  
        }
        catch(Exception e)
        {
            CT_Logging.addMessage('Error', 'TimberlineSynch.parseResponse', '== Error =='+e.getMessage());
            System.debug(Logginglevel.ERROR,' ERROR AT TimberlineSynch.parseResponse ' + e.getMessage());
            return '';
        }
    } 
    
    public static Object getResponseBody( Map<String, Object> responseJSONMap ) 
    {        
        try
        {
            CT_Logging.setSeverity('Info');
            Blob privateKey = EncodingUtil.base64Decode(TimberlineSynch.AES_256_KEY_BASE_64);
            
            String b = (String) responseJSONMap.get( 'body' ); 
            System.debug('TimberlineSynch.getResponseBody: b: ' +  b.length());
            
            // I don't think that the body is URL encoded in this case...
            String urlDecodeBody = b;
            //String urlDecodeBody = EncodingUtil.urlDecode(b,'UTF-8');
            //System.debug('TimberlineSynch.getResponseBody: urlDecodeBody.size: ' +  urlDecodeBody.length());
            //System.debug('TimberlineSynch.getResponseBody: urlDecodeBody: ' + urlDecodeBody );
            
            Blob b64DecodeBody = EncodingUtil.base64Decode(urlDecodeBody);
            System.debug('TimberlineSynch.getResponseBody: privateKey size: ' + privateKey.size());
            System.debug('TimberlineSynch.getResponseBody: TimberlineSynch.initializationVector size: ' + TimberlineSynch.initializationVector.size());
            System.debug('TimberlineSynch.getResponseBody: Encrypted Binary (len='+b64DecodeBody.size()+'): ' + EncodingUtil.convertToHex(b64DecodeBody));
            
            Blob unEncryptedBody = Crypto.decrypt('AES256', privateKey, TimberlineSynch.initializationVector, b64DecodeBody);
            System.debug('TimberlineSynch.getResponseBody: unEncryptedBody: ' + unEncryptedBody.toString());
            
            Object body = (Object) JSON.deserializeUntyped(unEncryptedBody.toString());
            System.debug('TimberlineSynch.getResponseBody: body: ' + body );
            return body;
        }
        catch(Exception e) { CT_Logging.addMessage('Error', 'TimberlineSynch.getResponseBody', '== Error =='+e.getMessage()); }
        return null;
    }
    
        
        
    /***********************************************************************************************************************************************************************************************************************
    ************************************************************************************************************************************************************************************************************************
    ***
    ***         TEST CODE
    ***
    ************************************************************************************************************************************************************************************************************************
    ************************************************************************************************************************************************************************************************************************/
    private static testmethod void synchError() 
    {
        TestDataUtil.createCustomSettings_TriggerStatus();    
        // Test account
        Account testAccount = new Account();
        
        // Set the fields for
        testAccount.BillingStreet ='Test Street';
        testAccount.BillingCity = 'Los Angeles';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingPostalCode = '90405';
        testAccount.BillingState = 'CA';
        testAccount.Phone = '4242380858';
        testAccount.Type = 'Test Account';
        testAccount.Name = 'Test Account';
        testAccount.Timberline_Customer_Number__c = '67440';
        
        // Insert the account
        insert testAccount;
        
        system.debug('testAccount: ' + testAccount.Timberline_Customer_Number__c);
        
        Set<Id> accountSet = new Set<Id>();
        accountSet.add(testAccount.id);
        
        // Create a fake response
        HttpResponse accountOkResponse = new HttpResponse();
        accountOkResponse.setBody('{"status": "OK", "body": {"67440": "OK"}, "code": "0", "detail": "Account insert and Update successful"}');
        accountOkResponse.setStatusCode(502);
        accountOkResponse.setStatus('ERROR');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = accountOkResponse;
        
        TimberlineSynch.synchAccount(accountSet);
     
        
    }
    
    private static testmethod void synchAccountManual() 
    {
        TriggerStatus__c ts = new TriggerStatus__c(SetupOwnerId = Userinfo.getUserId());
        insert ts;
        
        // Test account
        Account testAccount = new Account();
        
        // Set the fields for
        testAccount.BillingStreet ='Test Street';
        testAccount.BillingCity = 'Los Angeles';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingPostalCode = '90405';
        testAccount.BillingState = 'CA';
        testAccount.Phone = '4242380858';
        testAccount.Type = 'Test Account';
        testAccount.Name = 'Test Account';
        testAccount.Timberline_Customer_Number__c = '67440';
        
        // Insert the account
        insert testAccount;
        
        system.debug('testAccount: ' + testAccount.Timberline_Customer_Number__c);
        
        Set<Id> accountSet = new Set<Id>();
        accountSet.add(testAccount.id);
        
        // Create a fake response
        HttpResponse accountOkResponse = new HttpResponse();
        accountOkResponse.setBody('{"status": "OK", "body": {"67440": "OK"}, "code": "0", "detail": "Account insert and Update successful"}');
        accountOkResponse.setStatusCode(200);
        accountOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = accountOkResponse;
        
        TimberlineSynch.synchAccount(accountSet);
        
        
    }
  
    private static testmethod void synchAccountManualWithError() 
    {
        TriggerStatus__c ts = new TriggerStatus__c(SetupOwnerId = Userinfo.getUserId());
        insert ts;
        
        // Test account
        Account testAccount = new Account();
        
        // Set the fields for
        testAccount.BillingStreet ='Test Street';
        testAccount.BillingCity = 'Los Angeles';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingPostalCode = '90405';
        testAccount.BillingState = 'CA';
        testAccount.Phone = '4242380858';
        testAccount.Type = 'Test Account';
        testAccount.Name = 'Test Account';
        testAccount.Timberline_Customer_Number__c = '67440';
        
        // Insert the account
        insert testAccount;
        
        system.debug('testAccount: ' + testAccount.Timberline_Customer_Number__c);
        
        Set<Id> accountSet = new Set<Id>();
        accountSet.add(testAccount.id);

        // Create a fake response
        HttpResponse accountOkResponse = new HttpResponse();
        accountOkResponse.setBody('{"status": "OK", "body": {"67440": "FAIL"}, "code": "0", "detail": "Account insert and Update successful"}');
        accountOkResponse.setStatusCode(200);
        accountOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = accountOkResponse;
        
        TimberlineSynch.synchAccount(accountSet);
        
    } 

    private static testmethod void synchAccountTrigger() 
    {
        TriggerStatus__c ts = new TriggerStatus__c(SetupOwnerId = Userinfo.getUserId());
        insert ts;
            
        // Test account
        Account testAccount = new Account();
        
        // Set the fields for
        testAccount.BillingStreet ='Test Street';
        testAccount.BillingCity = 'Los Angeles';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingPostalCode = '90405';
        testAccount.BillingState = 'CA';
        testAccount.Phone = '4242380858';
        testAccount.Type = 'Test Account';
        testAccount.Name = 'Test Account';
        testAccount.Timberline_Customer_Number__c = '67440';
        
        // Insert the account
        insert testAccount;
        
        system.debug('testAccount: ' + testAccount.Timberline_Customer_Number__c);
        
        Set<Id> accountSet = new Set<Id>();
        accountSet.add(testAccount.id);
        
        // Create a fake response
        HttpResponse accountOkResponse = new HttpResponse();
        accountOkResponse.setBody('{"status": "OK", "body": {"67440": "OK"}, "code": "0", "detail": "Account insert and Update successful"}');
        accountOkResponse.setStatusCode(200);
        accountOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = accountOkResponse;
        
        testAccount.Type = 'Test Account2';
        testAccount.Send_to_Timberline__c = true;
        update testAccount;

    }  
    
    private static testmethod void synchAccountOtherError() 
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        // Test account
        Account testAccount = new Account();
        
        // Set the fields for
        testAccount.BillingStreet ='Test Street';
        testAccount.BillingCity = 'Los Angeles';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingPostalCode = '90405';
        testAccount.BillingState = 'CA';
        testAccount.Phone = '4242380858';
        testAccount.Type = 'Test Account';
        testAccount.Name = 'Test Account';
        testAccount.Timberline_Customer_Number__c = '67440';
        
        // Insert the account
        insert testAccount;
        
        system.debug('testAccount: ' + testAccount.Timberline_Customer_Number__c);
        
        Set<Id> accountSet = new Set<Id>();
        accountSet.add(testAccount.id);
        
        // Create a fake response
        HttpResponse accountOkResponse = new HttpResponse();
        accountOkResponse.setBody('{"status": "ERROR", "body": "Error Parsing JSON", "code": "400", "detail": "Error Parsing JSON"}');
        accountOkResponse.setStatusCode(200);
        accountOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = accountOkResponse;
        
        testAccount.Type = 'Test Account2';
        testAccount.Send_to_Timberline__c = true;
        update testAccount;

    }
    
    private static testmethod void synchAccountBadCredentials() 
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
            
        // Test account
        Account testAccount = new Account();
        
        // Set the fields for
        testAccount.BillingStreet ='Test Street';
        testAccount.BillingCity = 'Los Angeles';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingState = 'CA';
        testAccount.BillingPostalCode = '90405';
        testAccount.BillingState = 'CA';
        testAccount.Phone = '4242380858';
        testAccount.Type = 'Test Account';
        testAccount.Name = 'Test Account';
        testAccount.Timberline_Customer_Number__c = '67440';
        
        // Insert the account
        insert testAccount;
        
        system.debug('testAccount: ' + testAccount.Timberline_Customer_Number__c);
        
        Set<Id> accountSet = new Set<Id>();
        accountSet.add(testAccount.id);
        
        // Create a fake response
        HttpResponse accountOkResponse = new HttpResponse();
        accountOkResponse.setBody('{"status": "ERROR", "body": "", "code": "2", "detail": ""}');
        accountOkResponse.setStatusCode(200);
        accountOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = accountOkResponse;
        
        TimberlineSynch.synchAccount(accountSet);
        
    }
    
    private static testmethod void synchJobOK() 
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
        
         // Test Job
        
        // Create a fake response
        HttpResponse jobOkResponse = new HttpResponse();
        jobOkResponse.setBody('{"status": "OK", "body": {"000-00-00026": "OK"}, "code": "0", "detail": "Job insert and Update successful"}');
        jobOkResponse.setStatusCode(200);
        jobOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = jobOkResponse;
        
        //TimberlineSynch.synchJobs(jobSet);
    } 
     private static testmethod void synchJobError() 
    {    
        TestDataUtil.createCustomSettings_TriggerStatus();
        
         // Test Job
       /* 
        
        // Set the fields for
        
        
        
        
        Set<Id> jobSet = new Set<Id>();
        jobSet.add(testJob.id);*/
        
        // Create a fake response
        HttpResponse jobOkResponse = new HttpResponse();
        jobOkResponse.setBody('{"status": "OK", "body": {"000-00-00026": "FAIL"}, "code": "0", "detail": "Job insert and Update successful"}');
        jobOkResponse.setStatusCode(200);
        jobOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = jobOkResponse;
        
        //TimberlineSynch.synchJobs(jobSet);
    }  
    
    private static testmethod void synchJobTrigger() 
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
        
         // Test Job
        
        
        // Create a fake response
        HttpResponse jobOkResponse = new HttpResponse();
        jobOkResponse.setBody('{"status": "OK", "body": {"000-00-00026": "OK"}, "code": "0", "detail": "Job insert and Update successful"}');
        jobOkResponse.setStatusCode(200);
        jobOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = jobOkResponse;
        
        /*testJob.Sync_to_Timberline__c = true;
        update testJob;*/
    } 
    
    private static testmethod void synchForecastTrigger() 
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
        
         // Test Job
        
        
        // Create a fake response
        HttpResponse jobOkResponse = new HttpResponse();
        jobOkResponse.setBody('{"status": "OK", "body": {"000-00-00026": {"LM_Work_Billed": 0.0, "NM_Cost": 0.0, "YTD_Cost": 0.0, "YTD_Dollars_Paid": 0.0, "MTD_Cost": 0.0, "JTD_Payments": 0.0, "LM_Dollars_Paid": 0.0, "NM_Work_Billed": 0.0, "QTD_Cost": 0.0, "LM_Cost": 0.0, "MTD_Work_Billed": 0.0, "QTD_Dollars_Paid": 0.0, "YTD_Work_Billed": 0.0, "JOB": "000-00-00002", "JTD_Dollars_Paid": 0.0, "JTD_Cost": 0.0, "QTD_Work_Billed": 0.0, "Receivable_Balance": 0.0, "MTD_Dollars_Paid": 0.0, "NM_Dollars_Paid": 0.0, "JTD_Work_Billed": 0.0}}, "code": "0", "detail": "Forecast Data was retrieve successfully"}');
        jobOkResponse.setStatusCode(200);
        jobOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = jobOkResponse;
        
        /*testJob.Update_Forecast__c = true;
        update testJob;*/
    }
    
    private static testmethod void synchForecastManual() 
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
        
         // Test Job
        
        
        //system.debug('testAccount: ' + testJob.Job_Number__c);
        
        Set<Id> jobSet = new Set<Id>();
        
        
        // Create a fake response
        HttpResponse jobOkResponse = new HttpResponse();
        jobOkResponse.setBody('{"status": "OK", "body": {"000-00-00026": {"LM_Work_Billed": 0.0, "NM_Cost": 0.0, "YTD_Cost": 0.0, "YTD_Dollars_Paid": 0.0, "MTD_Cost": 0.0, "JTD_Payments": 0.0, "LM_Dollars_Paid": 0.0, "NM_Work_Billed": 0.0, "QTD_Cost": 0.0, "LM_Cost": 0.0, "MTD_Work_Billed": 0.0, "QTD_Dollars_Paid": 0.0, "YTD_Work_Billed": 0.0, "JOB": "000-00-00002", "JTD_Dollars_Paid": 0.0, "JTD_Cost": 0.0, "QTD_Work_Billed": 0.0, "Receivable_Balance": 0.0, "MTD_Dollars_Paid": 0.0, "NM_Dollars_Paid": 0.0, "JTD_Work_Billed": 0.0}}, "code": "0", "detail": "Forecast Data was retrieve successfully"}');
        jobOkResponse.setStatusCode(200);
        jobOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = jobOkResponse;
        
        TimberlineSynch.synchForecast(jobSet);

    }   
    
    private static testmethod void synchTax() 
    {   
        TimberlineSynch.AES_256_KEY_BASE_64 = 'b+jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';
    
        // Create a fake response
        HttpResponse jobOkResponse = new HttpResponse();
        jobOkResponse.setBody('{"status": "OK", "body": {"AZ-BU": {"Tax_Rate__c": 6.652, "Timberline_Id__c": "AZ-BU"}, "AZ-SEY": {"Tax_Rate__c": 6.685, "Timberline_Id__c": "AZ-SEY"}, "AZ-BE": {"Tax_Rate__c": 7.172, "Timberline_Id__c": "AZ-BE"}, "AZ-BA": {"Tax_Rate__c": 4.735, "Timberline_Id__c": "AZ-BA"}, "AZ-BC": {"Tax_Rate__c": 5.71, "Timberline_Id__c": "AZ-BC"}, "AZ-DH": {"Tax_Rate__c": 6.035, "Timberline_Id__c": "AZ-DH"}, "AZ-BI": {"Tax_Rate__c": 6.197, "Timberline_Id__c": "AZ-BI"}, "AZ-BK": {"Tax_Rate__c": 4.735, "Timberline_Id__c": "AZ-BK"}, "AZ-MAR": {"Tax_Rate__c": 4.702, "Timberline_Id__c": "AZ-MAR"}, "AZ-SE": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-SE"}, "AZ-SC": {"Tax_Rate__c": 5.775, "Timberline_Id__c": "AZ-SC"}, "AZ-SA": {"Tax_Rate__c": 6.197, "Timberline_Id__c": "AZ-SA"}, "AZ-JE": {"Tax_Rate__c": 6.685, "Timberline_Id__c": "AZ-JE"}, "AZ-SO": {"Tax_Rate__c": 6.587, "Timberline_Id__c": "AZ-SO"}, "AZ-SL": {"Tax_Rate__c": 5.872, "Timberline_Id__c": "AZ-SL"}, "AZ-MAY": {"Tax_Rate__c": 4.735, "Timberline_Id__c": "AZ-MAY"}, "AZ-SJ": {"Tax_Rate__c": 5.872, "Timberline_Id__c": "AZ-SJ"}, "AZ-SK": {"Tax_Rate__c": 4.735, "Timberline_Id__c": "AZ-SK"}, "AZ-SH": {"Tax_Rate__c": 7.172, "Timberline_Id__c": "AZ-SH"}, "AZ-SV": {"Tax_Rate__c": 6.165, "Timberline_Id__c": "AZ-SV"}, "AZ-ST": {"Tax_Rate__c": 6.197, "Timberline_Id__c": "AZ-ST"}, "AZ-SU": {"Tax_Rate__c": 7.107, "Timberline_Id__c": "AZ-SU"}, "AZ-SR": {"Tax_Rate__c": 6.262, "Timberline_Id__c": "AZ-SR"}, "AZ-QCM": {"Tax_Rate__c": 7.465, "Timberline_Id__c": "AZ-QCM"}, "AZ-SP": {"Tax_Rate__c": 6.522, "Timberline_Id__c": "AZ-SP"}, "TX-GLD": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-GLD"}, "TX-CDC": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-CDC"}, "AZ-OVR": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-OVR"}, "AZ-ED": {"Tax_Rate__c": 6.522, "Timberline_Id__c": "AZ-ED"}, "AZ-EG": {"Tax_Rate__c": 4.897, "Timberline_Id__c": "AZ-EG"}, "AZ-MP": {"Tax_Rate__c": 4.978, "Timberline_Id__c": "AZ-MP"}, "AZ-MR": {"Tax_Rate__c": 7.237, "Timberline_Id__c": "AZ-MR"}, "AZ-EL": {"Tax_Rate__c": 7.887, "Timberline_Id__c": "AZ-EL"}, "AZ-EM": {"Tax_Rate__c": 6.652, "Timberline_Id__c": "AZ-EM"}, "AZ-MH": {"Tax_Rate__c": 6.262, "Timberline_Id__c": "AZ-MH"}, "AZ-MI": {"Tax_Rate__c": 6.522, "Timberline_Id__c": "AZ-MI"}, "TX-DDC": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-DDC"}, "AZ-MA": {"Tax_Rate__c": 7.172, "Timberline_Id__c": "AZ-MA"}, "AZ-ME": {"Tax_Rate__c": 5.84, "Timberline_Id__c": "AZ-ME"}, "NM-OS": {"Tax_Rate__c": 5.125, "Timberline_Id__c": "NM-OS"}, "AZ-HEB": {"Tax_Rate__c": 4.978, "Timberline_Id__c": "AZ-HEB"}, "AZ-QCP": {"Tax_Rate__c": 7.725, "Timberline_Id__c": "AZ-QCP"}, "CT-ALL": {"Tax_Rate__c": 6.35, "Timberline_Id__c": "CT-ALL"}, "TX-BED": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-BED"}, "TX-ED": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-ED"}, "Exempt": {"Tax_Rate__c": 0.0, "Timberline_Id__c": "Exempt"}, "LA-CAL": {"Tax_Rate__c": 8.5, "Timberline_Id__c": "LA-CAL"}, "AZ-HO": {"Tax_Rate__c": 6.522, "Timberline_Id__c": "AZ-HO"}, "AZ-HC": {"Tax_Rate__c": 5.547, "Timberline_Id__c": "AZ-HC"}, "AZ-HA": {"Tax_Rate__c": 6.847, "Timberline_Id__c": "AZ-HA"}, "TX-WEA": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-WEA"}, "AZ-HE": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-HE"}, "AZ-QU": {"Tax_Rate__c": 7.172, "Timberline_Id__c": "AZ-QU"}, "AZ-CV": {"Tax_Rate__c": 6.685, "Timberline_Id__c": "AZ-CV"}, "AZ-CW": {"Tax_Rate__c": 7.335, "Timberline_Id__c": "AZ-CW"}, "AZ-CR": {"Tax_Rate__c": 4.735, "Timberline_Id__c": "AZ-CR"}, "AZ-PIN": {"Tax_Rate__c": 4.897, "Timberline_Id__c": "AZ-PIN"}, "DC-DC": {"Tax_Rate__c": 6.0, "Timberline_Id__c": "DC-DC"}, "WA-SPK": {"Tax_Rate__c": 8.7, "Timberline_Id__c": "WA-SPK"}, "AZ-CY": {"Tax_Rate__c": 6.685, "Timberline_Id__c": "AZ-CY"}, "AZ-CG": {"Tax_Rate__c": 7.562, "Timberline_Id__c": "AZ-CG"}, "AZ-CD": {"Tax_Rate__c": 7.335, "Timberline_Id__c": "AZ-CD"}, "AZ-CE": {"Tax_Rate__c": 7.562, "Timberline_Id__c": "AZ-CE"}, "AZ-CC": {"Tax_Rate__c": 7.952, "Timberline_Id__c": "AZ-CC"}, "AZ-CA": {"Tax_Rate__c": 7.302, "Timberline_Id__c": "AZ-CA"}, "AZ-CO": {"Tax_Rate__c": 5.71, "Timberline_Id__c": "AZ-CO"}, "AZ-CL": {"Tax_Rate__c": 6.522, "Timberline_Id__c": "AZ-CL"}, "NY-ER": {"Tax_Rate__c": 8.75, "Timberline_Id__c": "NY-ER"}, "TX-FW": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-FW"}, "AZ-CH": {"Tax_Rate__c": 5.677, "Timberline_Id__c": "AZ-CH"}, "AZ-GRA": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-GRA"}, "AZ-PA": {"Tax_Rate__c": 6.928, "Timberline_Id__c": "AZ-PA"}, "AZ-GRE": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-GRE"}, "AZ-PE": {"Tax_Rate__c": 5.872, "Timberline_Id__c": "AZ-PE"}, "AZ-KI": {"Tax_Rate__c": 5.71, "Timberline_Id__c": "AZ-KI"}, "AZ-PK": {"Tax_Rate__c": 6.197, "Timberline_Id__c": "AZ-PK"}, "AZ-PI": {"Tax_Rate__c": 6.522, "Timberline_Id__c": "AZ-PI"}, "AZ-PH": {"Tax_Rate__c": 6.002, "Timberline_Id__c": "AZ-PH"}, "AZ-PN": {"Tax_Rate__c": 6.275, "Timberline_Id__c": "AZ-PN"}, "AZ-KA": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-KA"}, "AZ-AJO": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-AJO"}, "AZ-PR": {"Tax_Rate__c": 6.035, "Timberline_Id__c": "AZ-PR"}, "AZ-AJM": {"Tax_Rate__c": 6.132, "Timberline_Id__c": "AZ-AJM"}, "AZ-PV": {"Tax_Rate__c": 6.327, "Timberline_Id__c": "AZ-PV"}, "AZ-GRV": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-GRV"}, "AZ-PND": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-PND"}, "AZ-KR": {"Tax_Rate__c": 4.735, "Timberline_Id__c": "AZ-KR"}, "TX-GPR": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-GPR"}, "TX-RIC": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-RIC"}, "AZ-SM": {"Tax_Rate__c": 4.962, "Timberline_Id__c": "AZ-SM"}, "TX-RID": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-RID"}, "AZ-FR": {"Tax_Rate__c": 7.578, "Timberline_Id__c": "AZ-FR"}, "NJ-ST": {"Tax_Rate__c": 7.0, "Timberline_Id__c": "NJ-ST"}, "AZ-FH": {"Tax_Rate__c": 6.392, "Timberline_Id__c": "AZ-FH"}, "NM-AL": {"Tax_Rate__c": 7.0, "Timberline_Id__c": "NM-AL"}, "AZ-FM": {"Tax_Rate__c": 4.41, "Timberline_Id__c": "AZ-FM"}, "AZ-FL": {"Tax_Rate__c": 6.097, "Timberline_Id__c": "AZ-FL"}, "AZ-STC": {"Tax_Rate__c": 4.897, "Timberline_Id__c": "AZ-STC"}, "AZ-WE": {"Tax_Rate__c": 6.587, "Timberline_Id__c": "AZ-WE"}, "AZ-FE": {"Tax_Rate__c": 7.562, "Timberline_Id__c": "AZ-FE"}, "AZ-WI": {"Tax_Rate__c": 6.522, "Timberline_Id__c": "AZ-WI"}, "PA-ST": {"Tax_Rate__c": 6.0, "Timberline_Id__c": "PA-ST"}, "AZ-WM": {"Tax_Rate__c": 6.928, "Timberline_Id__c": "AZ-WM"}, "TX-AUS": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-AUS"}, "AZ-WG": {"Tax_Rate__c": 6.132, "Timberline_Id__c": "AZ-WG"}, "AZ-AJP": {"Tax_Rate__c": 6.392, "Timberline_Id__c": "AZ-AJP"}, "AZ-STW": {"Tax_Rate__c": 4.897, "Timberline_Id__c": "AZ-STW"}, "AZ-WW": {"Tax_Rate__c": 6.522, "Timberline_Id__c": "AZ-WW"}, "AZ-NO": {"Tax_Rate__c": 6.197, "Timberline_Id__c": "AZ-NO"}, "AZ-SS": {"Tax_Rate__c": 7.562, "Timberline_Id__c": "AZ-SS"}, "AZ-AZ": {"Tax_Rate__c": 4.962, "Timberline_Id__c": "AZ-AZ"}, "AZ-WAD": {"Tax_Rate__c": 4.702, "Timberline_Id__c": "AZ-WAD"}, "AZ-AV": {"Tax_Rate__c": 6.327, "Timberline_Id__c": "AZ-AV"}, "AZ-YO": {"Tax_Rate__c": 6.652, "Timberline_Id__c": "AZ-YO"}, "AZ-WNG": {"Tax_Rate__c": 7.172, "Timberline_Id__c": "AZ-WNG"}, "AZ-AR": {"Tax_Rate__c": 2.275, "Timberline_Id__c": "AZ-AR"}, "AZ-YU": {"Tax_Rate__c": 6.067, "Timberline_Id__c": "AZ-YU"}, "AZ-AN": {"Tax_Rate__c": 4.702, "Timberline_Id__c": "AZ-AN"}, "TX-HHC": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-HHC"}, "EZ-EH": {"Tax_Rate__c": 4.897, "Timberline_Id__c": "EZ-EH"}, "AZ-VL": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-VL"}, "AZ-VN": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-VN"}, "AZ-TUM": {"Tax_Rate__c": 4.897, "Timberline_Id__c": "AZ-TUM"}, "NY-NY": {"Tax_Rate__c": 8.875, "Timberline_Id__c": "NY-NY"}, "AZ-TON": {"Tax_Rate__c": 4.702, "Timberline_Id__c": "AZ-TON"}, "AZ-KE": {"Tax_Rate__c": 7.562, "Timberline_Id__c": "AZ-KE"}, "TX-MEL": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-MEL"}, "TX-CCC": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-CCC"}, "AZ-YAV": {"Tax_Rate__c": 4.735, "Timberline_Id__c": "AZ-YAV"}, "AZ-PRK": {"Tax_Rate__c": 4.978, "Timberline_Id__c": "AZ-PRK"}, "AZ-SEC": {"Tax_Rate__c": 6.928, "Timberline_Id__c": "AZ-SEC"}, "AZ-SF": {"Tax_Rate__c": 5.872, "Timberline_Id__c": "AZ-SF"}, "AZ-MOH": {"Tax_Rate__c": 4.41, "Timberline_Id__c": "AZ-MOH"}, "AZ-PL": {"Tax_Rate__c": 6.197, "Timberline_Id__c": "AZ-PL"}, "TX-McA": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-McA"}, "NY-TCI": {"Tax_Rate__c": 8.0, "Timberline_Id__c": "NY-TCI"}, "AZ-DO": {"Tax_Rate__c": 6.392, "Timberline_Id__c": "AZ-DO"}, "LA-ORL": {"Tax_Rate__c": 9.0, "Timberline_Id__c": "LA-ORL"}, "AZ-DL": {"Tax_Rate__c": 6.85, "Timberline_Id__c": "AZ-DL"}, "AZ-LS": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-LS"}, "AZ-PNL": {"Tax_Rate__c": 4.962, "Timberline_Id__c": "AZ-PNL"}, "AZ-LP": {"Tax_Rate__c": 7.822, "Timberline_Id__c": "AZ-LP"}, "AZ-DU": {"Tax_Rate__c": 5.872, "Timberline_Id__c": "AZ-DU"}, "AZ-SUN": {"Tax_Rate__c": 4.702, "Timberline_Id__c": "AZ-SUN"}, "AZ-LH": {"Tax_Rate__c": 5.71, "Timberline_Id__c": "AZ-LH"}, "AZ-LA": {"Tax_Rate__c": 4.702, "Timberline_Id__c": "AZ-LA"}, "TX-RC": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-RC"}, "WA-KWK": {"Tax_Rate__c": 8.3, "Timberline_Id__c": "WA-KWK"}, "TX-DTN": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-DTN"}, "TX-ARL": {"Tax_Rate__c": 8.0, "Timberline_Id__c": "TX-ARL"}, "AZ-PMA": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-PMA"}, "AZ-PT": {"Tax_Rate__c": 6.847, "Timberline_Id__c": "AZ-PT"}, "AZ-GU": {"Tax_Rate__c": 6.652, "Timberline_Id__c": "AZ-GU"}, "AZ-GI": {"Tax_Rate__c": 5.677, "Timberline_Id__c": "AZ-GI"}, "AZ-GO": {"Tax_Rate__c": 6.977, "Timberline_Id__c": "AZ-GO"}, "AZ-GL": {"Tax_Rate__c": 6.587, "Timberline_Id__c": "AZ-GL"}, "AZ-TN": {"Tax_Rate__c": 6.327, "Timberline_Id__c": "AZ-TN"}, "AZ-GB": {"Tax_Rate__c": 6.652, "Timberline_Id__c": "AZ-GB"}, "AZ-GC": {"Tax_Rate__c": 4.962, "Timberline_Id__c": "AZ-GC"}, "AZ-COH": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-COH"}, "AZ-PY": {"Tax_Rate__c": 6.25, "Timberline_Id__c": "AZ-PY"}, "AZ-GE": {"Tax_Rate__c": 6.197, "Timberline_Id__c": "AZ-GE"}, "AZ-TU": {"Tax_Rate__c": 5.872, "Timberline_Id__c": "AZ-TU"}, "LA-JEF": {"Tax_Rate__c": 8.75, "Timberline_Id__c": "LA-JEF"}, "AZ-OV": {"Tax_Rate__c": 7.172, "Timberline_Id__c": "AZ-OV"}, "Mexico": {"Tax_Rate__c": 15.0, "Timberline_Id__c": "Mexico"}, "TX-MIS": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-MIS"}, "AZ-NUT": {"Tax_Rate__c": 4.572, "Timberline_Id__c": "AZ-NUT"}, "AZ-TE": {"Tax_Rate__c": 5.872, "Timberline_Id__c": "AZ-TE"}, "TX-IRV": {"Tax_Rate__c": 8.25, "Timberline_Id__c": "TX-IRV"}, "AZ-WNP": {"Tax_Rate__c": 7.237, "Timberline_Id__c": "AZ-WNP"}, "AZ-TA": {"Tax_Rate__c": 5.872, "Timberline_Id__c": "AZ-TA"}, "AZ-TO": {"Tax_Rate__c": 6.197, "Timberline_Id__c": "AZ-TO"}, "AZ-RM": {"Tax_Rate__c": 4.735, "Timberline_Id__c": "AZ-RM"}, "AZ-TH": {"Tax_Rate__c": 6.847, "Timberline_Id__c": "AZ-TH"}}, "code": "0", "detail": "TAX Data was retrieve successfully"}');
        jobOkResponse.setStatusCode(200);
        jobOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = jobOkResponse;
        
        List<Tax_Group__c> taxes = TimberlineSynch.synchTaxData();
    }
    /*
    private static testmethod void synchTaxInvalidCredentials() 
    {
        // Create a fake response
        HttpResponse jobOkResponse = new HttpResponse();
        jobOkResponse.setBody('');
        jobOkResponse.setStatusCode(200);
        jobOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = jobOkResponse;
        
        List<Tax_Group__c> taxes = TimberlineSynch.synchTaxData();
    }
    */
    private static testmethod void synchTaxError() 
    {        
        TimberlineSynch.AES_256_KEY_BASE_64 = 'b+jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';
    
        // Create a fake response
        HttpResponse jobOkResponse = new HttpResponse();
        jobOkResponse.setBody('');
        jobOkResponse.setStatusCode(502);
        jobOkResponse.setStatus('ERROR');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = jobOkResponse;
        
        List<Tax_Group__c> taxes = TimberlineSynch.synchTaxData();
    }
   
    private static testmethod void checkCredentialsError() 
    {       
        // Create a fake response
        HttpResponse credentialsResponse = new HttpResponse();
        credentialsResponse.setBody('');
        credentialsResponse.setStatusCode(502);
        credentialsResponse.setStatus('ERROR');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = credentialsResponse;
        
        TimberlineSynch.checkCredentials('test', 'test');
    }
    
    private static testmethod void checkCredentials() 
    {
        // Create a fake response
        HttpResponse credentialsResponse = new HttpResponse();
        credentialsResponse.setBody('{"status": "OK", "body": "Credentials are OK", "code": "0", "detail": "Credentials are OK"}');
        credentialsResponse.setStatusCode(200);
        credentialsResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = credentialsResponse;
        
        TimberlineSynch.checkCredentials('test', 'test');
    }   
    private static testmethod void synchInvoice() 
    {
        
    }
    
    public Static Timber_Settings__c GetSettings()
    {
        Timber_Settings__c mySettings;
        Timber_Settings__c orgSettings;
        Timber_Settings__c proSettings;
        Timber_Settings__c theSettings; 
        
        try
        { 
            //See if User have User level Custom setting values
            mySettings = Timber_Settings__c.getValues(UserInfo.getUserId());
            if(mySettings == null) 
            {
                //Else See if User have Profile level Custom setting values
                proSettings = Timber_Settings__c.getValues(UserInfo.getProfileId());            
                if(proSettings == null)
                {
                    //Else See if User have Org. level Custom setting values
                    orgSettings = Timber_Settings__c.getOrgDefaults();
                    theSettings = orgSettings;
                }
                else
                {
                     theSettings = proSettings;
                }
            }        
            else
            {
                theSettings = mySettings;
            }        
        }
        catch (Exception e) { System.debug('Error : ' + e.getMessage()); }
        return theSettings;
    }      

    // Error at getResponseBody
    private static testmethod void synchInvoiceTest() 
    {
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TestDataUtil.createCustomSettings_TriggerStatus();
        Tax_Group__c taxGrp = new Tax_Group__c(           
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup'   
        );
        insert taxGrp;
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'USA',
            BillingStreet = 'TestBStreet',
            BillingState = 'CA',
            BillingPostalCode = '1234',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'USA',
            ShippingState = 'CA',
            ShippingStreet = 'TestSStreet',            
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'

        );
        insert acct;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acct.Id,
            Phone = '1234'
        );    
        insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id,
            Retainage_Held_percent__c=1
            
        );
        insert inv;

        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = true,
            Taxable__c = true
            
        );
        insert invLineItem1;
        Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 0,
            Order__c = 1
        );    
        insert invLineItem2; 
        
        Timber_Settings__c ts = new Timber_Settings__c();
        ts.AES_256_KEY_BASE_64__c = 'jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';   
        ts.Timberline_Endpoint__c = 'http://12.187.107.21/TimberlineAPI';  
        insert ts; 
                
        Set<Id> invoiceSet = new Set<Id>();
        invoiceSet.add(inv.id);        
   
         // Set mock callout class 
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        TimberlineSynch.AES_256_KEY_BASE_64 = 'b+jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';
        
                
        // Create a fake response
        HttpResponse invoiceOkResponse = new HttpResponse();
        invoiceOkResponse.setBody('{"status": "OK", "body": {"67440": "OK"}, "code": "0", "detail": "Invoice insert and Update successful"}');
        invoiceOkResponse.setStatusCode(200);
        invoiceOkResponse.setStatus('OK');  
        
        // set the fake response
        TimberlineSynch.testResponse = invoiceOkResponse;
        
        TimberlineSynch.synchInvoice(invoiceSet, UserInfo.getUserId());
        
    }

    // Error at getResponseBody
    private static testmethod void InvoiceAPITest() 
    {
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TestDataUtil.createCustomSettings_TriggerStatus();
        Tax_Group__c taxGrp = new Tax_Group__c(           
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup',  
            Tax1Name__c = 'TestTaxName',
            Tax1Rate__c = 5,
            Tax2Name__c ='testTaxName2',
            Tax2Rate__c = 5,
            Tax3Name__c = 'testTaxName3',
            Tax3Rate__c = 5,
            Tax4Name__c = 'testTaxName4',
            Tax4Rate__c = 5,
            Tax5Name__c = 'testTaxName5',
            Tax5Rate__c = 5,
            Tax6Name__c = 'testTaxName6',
            Tax6Rate__c = 5,
            Tax7Name__c = 'testTaxName7',
            Tax7Rate__c = 5,
            Tax8Name__c = 'testTaxName8',
            Tax8Rate__c = 5,
            Tax9Name__c = 'testTaxName9',
            Tax9Rate__c = 5
        );
        insert taxGrp;
   
        Account acct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
            																   'BillingStreet' => 'Street \\\\ 12',
                                                          					   'BillingCity' => 'San Francisco',
                                                          					   'BillingCountry' => 'USA',
                                                          					   'BillingPostalCode' => '1234',
                                                          					   'BillingState' => 'CA',
                              					                               'RecordTypeId' => tBusiness.Id,
                                                                               'Status__c' => 'Active',                        
                                                                               'ShippingCity' => 'SFO',
                                                                               'ShippingCountry' => 'USA',
                                                                               'ShippingState' => 'CA',
                                                                               'ShippingStreet' => 'TestSStreet',
                                                                               'Company_Type__c' => 'Agent/ Brokerage',
                                                          					   'Industry' => 'Apparel'})[0];
                
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acct.Id,
            Phone = '1234'
        );    
        insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id,
            Retainage_Held_percent__c=1,
            Bill_to_Tax_Group__c = taxGrp.Id
            
        );
        insert inv;

        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = False,
            Taxable__c = true
            
        );
        insert invLineItem1;
        Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 0,
            Order__c = 1
        );    
        insert invLineItem2; 
        
        Test.StartTest();
        List<InvoiceExport.Invoice> invoices = InvoiceExport.getInvoice(new List<Id>{inv.id});
        Test.StopTest();
        
        System.AssertEquals(1, invoices.size());
        //System.AssertEquals(1, invoices[0].InvoiceLines.size());
       // System.AssertEquals(0, invoices[0].TaxLines.size());
        
    }
    
    // Error code (over 300)
    private static testmethod void synchInvoiceTest2() 
    {
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TriggerStatus__c tStat = new TriggerStatus__c(
            AccountGenerateCustomerNumber__c = true,
            AccountSyncToTimberline__c = true,
            Forecast_Sync_to_Timberline__c = true,
            InvoiceAutomaticInvoiceNumber__c = true,
            InvoiceSyncToTimberline__c= true,
            InvoiceLineItemAutoCreation__c= true,
            InvoiceLineItemAutomaticNaming__c= true,
            InvoiceLineItemAutomaticOrder__c= true,
            InvoiceTaxGroupSetUp__c= true,
            JobCopyPMToOwner__c= true,
            JobOpportunitySync__c= true,
            JobSetJobNumber__c= true,
            JobSyncToTimberline__c= true,
            LeadPMLeadSync__c= true,
            OpportunityJobSync__c= true,
            PMLeadCalculateJobNumber__c= true,
            PMLeadConversion__c= true,
            PMLeadLeadSync__c= true,
            TaskTaskSync__c= true,
            TaxGroupRefreshFromTimberline__c= true,
            TaxGroupSetName__c= true
        );
        insert tStat; 
        Tax_Group__c taxGrp = new Tax_Group__c(           
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup'   
        );
        insert taxGrp;
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'USA',
            BillingState = 'CA',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '1234',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'

        );
        insert acct;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acct.Id,
            Phone = '1234'
        );    
        insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id,
            Retainage_Held_percent__c=1
            
        );
        insert inv;

        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = true,
            Taxable__c = true
            
        );
        insert invLineItem1;
        Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 0,
            Order__c = 1
        );    
        insert invLineItem2; 
        
        Timber_Settings__c ts = new Timber_Settings__c();
        ts.AES_256_KEY_BASE_64__c = 'jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';   
        ts.Timberline_Endpoint__c = 'http://12.187.107.21/TimberlineAPI';  
        insert ts; 
                
        Set<Id> invoiceSet = new Set<Id>();
        invoiceSet.add(inv.id);        
   
         // Set mock callout class 
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        TimberlineSynch.AES_256_KEY_BASE_64 = 'b+jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';
        
        // Create a fake response
        HttpResponse invoiceOkResponse2 = new HttpResponse();
        invoiceOkResponse2.setBody('{"status": "ERROR", "body": {"67440": "FAIL"}, "code": "0", "detail": "Error"}');
        invoiceOkResponse2.setStatusCode(404);
        invoiceOkResponse2.setStatus('ERROR'); 
        
        // set the fake response
        TimberlineSynch.testResponse = invoiceOkResponse2;
        
        TimberlineSynch.synchInvoice(invoiceSet, UserInfo.getUserId());
        
    }
    
    // Error on status (status does not equal OK)
    private static testmethod void synchInvoiceTest3() 
    {
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TestDataUtil.createCustomSettings_TriggerStatus();
        Tax_Group__c taxGrp = new Tax_Group__c(           
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup'   
        );
        insert taxGrp;
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'SFO',
            BillingCountry = 'USA',
            BillingPostalCode = '123',
            BillingState = 'CA',
            BillingStreet = 'TestBStreet',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'

        );
        insert acct;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acct.Id,
            Phone = '1234'
        );    
        insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id,
            Retainage_Held_percent__c=1
            
        );
        insert inv;

        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = true,
            Taxable__c = true
            
        );
        insert invLineItem1;
        Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 0,
            Order__c = 1
        );    
        insert invLineItem2; 
        
        Timber_Settings__c ts = new Timber_Settings__c();
        ts.AES_256_KEY_BASE_64__c = 'jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';   
        ts.Timberline_Endpoint__c = 'http://12.187.107.21/TimberlineAPI';  
        insert ts; 
                
        Set<Id> invoiceSet = new Set<Id>();
        invoiceSet.add(inv.id);        
   
         // Set mock callout class 
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        TimberlineSynch.AES_256_KEY_BASE_64 = 'b+jo5+nfitbmixhwOlsNYNu0xCTKORvtF00q71d9cDw=';
        
        // Create a fake response
        HttpResponse invoiceOkResponse2 = new HttpResponse();
        invoiceOkResponse2.setBody('{"status": "ERROR", "body": {"67440": "FAIL"}, "code": "0", "detail": "Error"}');
        invoiceOkResponse2.setStatusCode(200);
        invoiceOkResponse2.setStatus('ERROR'); 
        
        // set the fake response
        TimberlineSynch.testResponse = invoiceOkResponse2;
        
        TimberlineSynch.synchInvoice(invoiceSet, UserInfo.getUserId());
        
    }
    
    // Error case
    private static testmethod void synchInvoiceTest_Error_InvoiceEmptyFieldAndNoJob() 
    {
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TestDataUtil.createCustomSettings_TriggerStatus();
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'USA',
            BillingState = 'CA',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '123',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acct;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acct.Id,
            Phone = '1234'
        );    
        insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id 
        );
        insert inv;

        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = true,
            Taxable__c = true
        );
        insert invLineItem1;
        Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 0,
            Order__c = 1
        );    
        insert invLineItem2;       
                
        Set<Id> invoiceSet = new Set<Id>();
        invoiceSet.add(inv.id);        
        
        // Create a fake response
        HttpResponse invoiceOkResponse = new HttpResponse();
        invoiceOkResponse.setBody('{"status": "OK", "body": {"67440": "OK"}, "code": "0", "detail": "Invoice insert and Update successful"}');
        invoiceOkResponse.setStatusCode(200);
        invoiceOkResponse.setStatus('OK');
        
        // mark the test as test
        TimberlineSynch.isApexTest = true;
        
        // set the fake response
        TimberlineSynch.testResponse = invoiceOkResponse;
        
        TimberlineSynch.synchInvoice(invoiceSet, UserInfo.getUserId());
        
        
    }


}