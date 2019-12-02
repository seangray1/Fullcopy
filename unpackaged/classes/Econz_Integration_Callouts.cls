// Check Project Manager has a PK Defined. If not get that and Update User Record.
// Create Task using 'addTaskForManager' and update Last Integrated Time
// Get the Task # and Store on the ATI Job.
// renameTask (oldName, newName)- When the name is changed on Update
// updateTaskDetails(taskName, DetailedTaskWithAddress) // When the custom fields are changed
// updateTaskManager(taskName, UserBean) // When the project manager is changed
// updateTaskStartEnd When the Stage is Complete
global class Econz_Integration_Callouts {
 public static boolean isECONZCalloutsProcessed = false;
    //Athith Comments    
    //Added Start date instead of Data time approved  
    public static dateTime startdate = null; 
    public static void manageEConzCallouts( Map<Id, ATI_Job__c> oldMap, list<ATI_Job__c> newValues){
        Id devRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
        Id notApprovedRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('New Job (Not Approved)').getRecordTypeId();
        for(ATI_Job__c Job: newValues){
            startdate = Job.date_time_approved__c;
            system.debug('---startdate---'+startdate );
            //Athith Comments  
            //When the ATI_Job__c record type is changed from “New Job (Not Approved)” to “Job (Approved)” instead of ATI_Job__c stage becomes closed won, a task should be created in ECONZ.
            if( Job.RecordTypeID != oldMap.get(Job.Id).RecordTypeID &&  Job.RecordTypeID == devRecordTypeId && Job.ECONZ_Task_Created__c == false){
                //startdate = system.now();
                system.debug('===1==='+startdate);
                Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'addTask',null,startdate);
            }
            if(Job.RecordTypeID == devRecordTypeId){
                if( Job.Stage__c != oldMap.get(Job.Id).Stage__c && (Job.Stage__c == 'Work Complete' || Job.Stage__c == 'Billing Complete')){
                    system.debug('===2===');
                    //Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'updateTaskDates',null,startdate);
                    Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'updateTaskDetails',oldMap.get(Job.Id).Name,startdate);
                }
                
                
                if(Job.Project_Manager_New__c != oldMap.get(Job.Id).Project_Manager_New__c){
                    system.debug('===4===');
                    Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'updateTaskManager',null,startdate);
                }
                
                if( (Job.Job_Name__c != null && Job.Job_Name__c != oldMap.get(Job.Id).Job_Name__c ) ||
                   (Job.Job_Number__c != null && Job.Job_Number__c != oldMap.get(Job.Id).Job_Number__c)){
                       system.debug('===5===');
                       Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'renameTask',oldMap.get(Job.Id).Name,startdate);
                   }
                if( (Job.Project_Site_Address_2__c != null && Job.Project_Site_Address_2__c != oldMap.get(Job.Id).Project_Site_Address_2__c ) ||
                   (Job.Project_Site_Address__c != null && Job.Project_Site_Address__c != oldMap.get(Job.Id).Project_Site_Address__c ) ||
                   (Job.Project_Site_City__c != null && Job.Project_Site_City__c != oldMap.get(Job.Id).Project_Site_City__c ) ||
                   (Job.Project_Site_State__c != null && Job.Project_Site_State__c != oldMap.get(Job.Id).Project_Site_State__c ) ||
                   (Job.Office2__c != null && Job.Office2__c != oldMap.get(Job.Id).Office2__c ) ||
                   (Job.Division__c != null && Job.Division__c != oldMap.get(Job.Id).Division__c ) ||
                   (Job.Project_Manager__c != null && Job.Project_Manager__c != oldMap.get(Job.Id).Project_Manager__c ) ||
                   (Job.Project_Site_Zipcode__c != null && Job.Project_Site_Zipcode__c != oldMap.get(Job.Id).Project_Site_Zipcode__c) ){
                       system.debug('===6===');
                       Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'updateTaskDetails',oldMap.get(Job.Id).Name,startdate);
                   }
                if(Job.Econz_Manual_Sync__c && !oldMap.get(Job.Id).Econz_Manual_Sync__c){
                    system.debug('===7===');
                    Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'',oldMap.get(Job.Id).Name,startdate);
                }
                //Athith Comments
                //when stage = “Won” and it was previously marked as stage = “Work Complete” or stage = “Billing Complete”, the ECONZ task start date should be re-synced as the current date, and the ECONZ task end date should be cleared.             
                if(Job.Stage__c != oldMap.get(Job.Id).Stage__c && (oldMap.get(Job.Id).Stage__c == 'Work Complete' || oldMap.get(Job.Id).Stage__c == 'Billing Complete') && Job.Stage__c == 'Won')
                {
                    system.debug('===8===');
                    startdate = system.now();
                    Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'updateTaskDetails',null,startdate);
                }
                //Athith Comments   
                //when stage = “Lost”, the ECONZ task end date should be marked as the current date               
                if(Job.Stage__c != oldMap.get(Job.Id).Stage__c && Job.Stage__c == 'Lost')
                {
                    system.debug('===9===');
                    Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'updateTaskDates',null,startdate);
                }
            }
        }
    } 
    
    public static void updateOldName( Map<Id, ATI_Job__c> oldMap, list<ATI_Job__c> newValues){
        for(ATI_Job__c Job : newValues){
            if(Job.Name != oldMap.get(Job.Id).Name)
                Job.Job_Prev_Name__c = oldMap.get(Job.Id).Name;
        }
    }
    
    // Invoked from Button
    webservice static string invokeIntegration(Id JobId) {
        ATI_Job__c Job = getJobRecord(JobId);
        startdate = Job.Date_Time_Approved__c;
        return integrateEconz(JobId,'button',startdate);
    }
    
    // Future Class invoked from Trigger.
    // Added the custom startdate parameter to pass the dynamic start date and to avoid the start date missing functionalities
    @future(callout = true)
    public static void ECONZ_Future_Call(Id JobId, string action, string OldName, dateTime startdate) {
        
        system.debug('########'+JobId);
        system.debug('&&&&'+action );
        system.debug('$$$$$'+OldName);
        system.debug('%%%%%'+startdate);
        integrateEconz(JobId,action,startdate);
        
    }
    
    public static string integrateEconz(Id JobId, String action, dateTime startdate){
        // Query ATI_Job__c
        system.debug('action-----'+action);
        ATI_Job__c Job = getJobRecord(JobId);
        string PM_Key;
        string msg = '';
        system.debug('===startdate==='+startdate);
        //Id devRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
        if(Job !=null){
        if(startdate != null){
            if( Job.Project_Manager_New__c != null)
                PM_Key = Job.Project_Manager_New__r.EConz_Primary_Key__c;
            if(PM_Key == null)
                PM_Key = [SELECT IsSandbox FROM Organization].isSandbox ? '14449' : '87411';
            // 
            if (Job.ECONZ_Task_Created__c) {
                if(action == 'renameTask'){
                    Job = renameTask(Job, Job.Job_Prev_Name__c);
                    Job = updateTaskDetails(Job,PM_Key, startdate);
                }
                if(action == 'button' || action == 'updateTaskManager'){
                    Job = updateTaskManager(Job);
                }
                if (action == 'updateTaskDates' || action == 'addTask'){
                    Job = updateTaskDates(Job, startdate);
                }
                if(action == 'addTask' || action == 'addTask' || action == 'button' || action == 'updateTaskDetails'){
                    Job = updateTaskDetails(Job,PM_Key, startdate);
                }
            }
            else {
                system.debug('addTaskElseCondition');
                Job = addTask(Job, startdate);
            }
        }
        else{
            
            Job.ECONZ_Integration_Error__c = true;
            Job.ECONZ_Error_Message__c = 'Start Date is Missing';
        }
        system.debug('integrateEconz');
        update Job;
        system.debug('integrateEconz'+Job.ECONZ_Task_Created__c);
        if(Job.Project_Manager_New__c != null){// commented by Nanda on 01/19/2018 && PM_Key == null && Job.Project_Manager_New__r.EConz_Primary_Key__c != null){
            updateUserPK(Job);
        }
        
        if (Job.ECONZ_Error_Message__c != null)
            msg = Job.ECONZ_Error_Message__c;
        else
            msg =  'Success';
        }
        return msg;
    }
    
    public static ATI_Job__c addTask(ATI_Job__c Job, dateTime startdate) {
        // Check for Project Manager PK. If exists continue. Otherwise Fetch it from Econz
        string PM_Key, reqXML;
        if(Job.Project_Manager_New__c != null){
            if (String.isEmpty(Job.Project_Manager_New__r.EConz_Primary_Key__c)) {
                PM_Key = getManagerPrimaryKey(Job);
                system.debug('PM_Key-----'+PM_Key);
                if(String.isempty(PM_Key)){
                    system.debug('PM_Key-----'+PM_Key);
                    PM_Key = createUser(Job);
                    system.debug('PM_Key-----'+PM_Key);
                }
            }
            else {
                PM_Key = Job.Project_Manager_New__r.EConz_Primary_Key__c;
                system.debug('PM_Key----'+PM_Key);
            }
        }
        if(PM_Key == null){
            PM_Key = [SELECT IsSandbox FROM Organization].isSandbox ? '14449' : '87411';
        }
        if (PM_Key != null) {
            system.debug('PM_Key----'+PM_Key);
            reqXML = buildAddTaskRequestXML(Job , 'addTaskForManager', PM_Key, startdate);
            system.debug('reqXML-----'+reqXML);
            system.debug('Call from addTaskForManager');
            invokeCallAndUpdateResults(reqXML, Job, 'addTaskForManager');
            if (Job.Project_Manager_New__c != null && String.isEmpty(Job.Project_Manager_New__r.EConz_Primary_Key__c)) {
                Job.Project_Manager_New__r.EConz_Primary_Key__c = PM_Key;
                system.debug('EConz_Primary_Key__c---'+Job.Project_Manager_New__r.EConz_Primary_Key__c);
            }
        }
        update Job;
        return Job;
    }
    
    private static void updateUserPK(ATI_Job__c Job){
        User usr = [SELECT Id, Email FROM User WHERE Id = :Job.Project_Manager_New__c];
        usr.EConz_Primary_Key__c = Job.Project_Manager_New__r.EConz_Primary_Key__c;
        update usr;
        
        
    }
    
    public static ATI_Job__c renameTask(ATI_Job__c Job, string OldName) {
        
        string reqXML = buildRenameTaskRequestXML(Job, OldName);
        system.debug('reqXML----'+reqXML);
        system.debug('Call from renameTask');
        invokeCallAndUpdateResults(reqXML, Job, 'renameTask');
        return Job;
    }
    
    public static ATI_Job__c updateTaskDates(ATI_Job__c Job, dateTime startdate) {
        
        string reqXML = buildUpdateTaskRequestXML(Job, startdate);
        system.debug('Call from updateTaskStartEnd');
        invokeCallAndUpdateResults(reqXML, Job, 'updateTaskStartEnd');
        return Job;
    }
    
    public static string getManagerPrimaryKey(ATI_Job__c Job) {
        
        string loginId = Job.Project_Manager_New__r.Email.split('@')[0];
        System.debug(loginId);
        string reqXML = buildGetUserDetailByLogin(loginId);
        system.debug('invoke HTTPRequest from getUserDetailByLoginID');
        Map<string, dom.Document> returnMap = invokeHTTPRequest(reqXML, 'getUserDetailByLoginID');
        dom.Document doc;
        string statusCode;
        for (string a : returnMap.keyset()) {
            statusCode = a;
            doc = returnMap.get(statusCode);
            break;
        }
        //system.debug(doc.toXmlString());
        if (statusCode == '200') {
            Dom.XMLNode rootNode = doc.getRootElement();
            string usrPrimaryKey = walkThrough(rootNode, new set<string> {'primaryKey'});
            System.debug(usrPrimaryKey);
            return usrPrimaryKey.replaceAll('\\s+', '');
        }
        return null;
    }
    
    public static ATI_Job__c updateTaskManager(ATI_Job__c Job) {
        // Check for Project Manager PK. If exists continue. Otherwise Fetch it from Econz
        string PM_Key, reqXML;
        if(Job.Project_Manager_New__c != null){
            if (String.isEmpty(Job.Project_Manager_New__r.EConz_Primary_Key__c)) {
                PM_Key = getManagerPrimaryKey(Job);
                system.debug('PM_Key111----'+PM_Key);
                if(String.isempty(PM_Key)){
                    PM_Key = createUser(Job);
                }
            }
            else {
                PM_Key = Job.Project_Manager_New__r.EConz_Primary_Key__c;
            }
        }
        if(PM_Key == null){
            PM_Key = [SELECT IsSandbox FROM Organization].isSandbox ? '14449' : '87411';
        }
        if (PM_Key != null) {
            reqXML = buildUpdateManagerRequestXML(Job, PM_Key);
            system.debug('Call from updateTaskManager');
            invokeCallAndUpdateResults(reqXML, Job, 'updateTaskManager');
            if (Job.Project_Manager_New__c != null && String.isEmpty(Job.Project_Manager_New__r.EConz_Primary_Key__c)) {
                Job.Project_Manager_New__r.EConz_Primary_Key__c = PM_Key;
            }
        }
        
        return Job;
    }
    
    public static ATI_Job__c updateTaskDetails(ATI_Job__c Job,String PM_Key, dateTime startdate) {
        string reqXML = buildAddTaskRequestXML(Job, 'updateTaskDetails', PM_Key, startdate);
        system.debug('Call from updateTaskDetails');
        invokeCallAndUpdateResults(reqXML, Job, 'updateTaskDetails');
        return Job;
    }
    
    public static string createUser(ATI_Job__c Job) {
        string reqXML = buildCreateUserRequestXML(Job);
        system.debug('invoke HTTPRequest from createUser');
        Map<string, dom.Document> returnMap = invokeHTTPRequest(reqXML, 'createUser');
        dom.Document doc;
        string statusCode;
        for (string a : returnMap.keyset()) {
            statusCode = a;
            doc = returnMap.get(statusCode);
            break;
        }
        system.debug(doc.toXmlString());
        if (statusCode == '200') {
            Dom.XMLNode rootNode = doc.getRootElement();
            string usrPrimaryKey = walkThrough(rootNode, new set<string> {'primaryKey'});
            System.debug(usrPrimaryKey);
            return usrPrimaryKey.replaceAll('\\s+', '');
        }
        return null;
    }
    
    private static ATI_Job__c invokeCallAndUpdateResults(string reqXML, ATI_Job__c Job, string method) {
        system.debug('method------'+method);
        system.debug(reqXML);
        Map<string, dom.Document> returnMap = invokeHTTPRequest(reqXML, method);
        dom.Document doc;
        string statusCode;
        for (string a : returnMap.keyset()) {
            statusCode = a;
            doc = returnMap.get(statusCode);
            break;
        }
        //system.debug(doc.toXmlString());
        system.debug(statusCode);
        if (statusCode == '200') {
            boolean isError = doc.toXmlString().contains('ErrorBean') ? true : false;
            system.debug(isError);
            if (!isError) {
                Job = updateSuccessDetails(Job);
                system.debug('----Err'+ isError);
                system.debug(method);
                if (method == 'addTaskForManager'){
                    Job.ECONZ_Task_Created__c = true;
                    system.debug(Job.ECONZ_Task_Created__c);
                }
                
            }
            else {
                system.debug('enterElse');
                Job = updateErrorDetails(Job, doc);
            }
        }
        else {
            // Not Integration Error but other error (network or et)
            Job.ECONZ_Integration_Error__c = true;
            Job.ECONZ_Error_Message__c = statusCode;
        }
        
        return Job;
    }
    
    private static Map<string, dom.Document> invokeHTTPRequest(string reqXML, string method) {
        System.debug('reqXML:'+reqXML);
        System.debug('method:'+method);
        string EndPoint;
        Map<string,EconzIntegration__c> mapCredentials = EconzIntegration__c.getAll();
        System.debug('mapCredentials:'+mapCredentials);
        if([SELECT IsSandbox FROM Organization].isSandbox){
            if(mapCredentials != null && mapCredentials.get('Test') != null){
                EndPoint = mapCredentials.get('Test').EndPointURL__c;
            }
        }
        else{
            if(mapCredentials != null && mapCredentials.get('Prod') != null){
                EndPoint = mapCredentials.get('Prod').EndPointURL__c;
            }
        }
        
        Map<string, dom.Document> returnMap = new Map<string, dom.Document> ();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(EndPoint);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        req.setHeader('SOAPAction', method);
        req.setBody(reqXML);
        req.setTimeout(120000);
        Http http = new Http();
        System.debug(method);
        HTTPResponse res = http.send(req);
      //  System.debug('res.getBody:'+res.getBody());
        System.debug('res.getStatusCode:'+res.getStatusCode());

        if (res.getStatusCode() == 200) {
            Dom.Document doc = res.getBodyDocument();
            system.debug('Response:'  +doc.toXmlString()); 
            returnMap.put(string.valueof(res.getStatusCode()), doc);  
        }
        else
            returnMap.put('StatusCode:' + res.getStatusCode() + ' Status:' + res.getStatus(), null);
        return returnMap;
    }
    
    public static ATI_Job__c getJobRecord(Id JobId) {
        List<ATI_Job__c> Job = [SELECT Id, Name, Stage__c, Recordtype.id, Project_Manager_New__r.Email, Project_Manager_New__r.Name, Project_Manager__r.Name, Division__c, Office__c, Job_Start_Date__c, Date_Time_Approved__c, Job_Prev_Name__c,
                           Project_Site_Address_2__c, Project_Site_Address__c, Project_Site_City__c, Project_Site_State__c, Completion_Date__c, Project_Manager_New__r.EConz_Primary_Key__c,
                           Project_Site_Zipcode__c, ECONZ_Error_Message__c, ECONZ_Integration_Error__c, ECONZ_Last_Callout_Time__c, ECONZ_Task_Created__c
                           FROM ATI_Job__c WHERE Id = :JobId];
        if(Job.size() > 0){
              return Job[0];
        }
        else{
              return null;
        }
    }
    
    private static ATI_Job__c updateErrorDetails(ATI_Job__c Job, Dom.Document doc) {
        Dom.XMLNode rootNode = doc.getRootElement();
        system.debug('rootNode-----'+rootNode);
        string ErrorMessage = walkThrough(rootNode, new set<string> { 'property', 'key' });
        system.debug('----Error Message---'+ ErrorMessage);
        if(ErrorMessage == ' name error.used'){
            Job.ECONZ_Task_Created__c = true;
            Job.ECONZ_Last_Callout_Time__c = system.now();
            Job.ECONZ_Integration_Error__c = false;
            Job.ECONZ_Error_Message__c = null;
        }
        if(ErrorMessage == ' task error.notFound'){
            Job = addTask(Job,Job.date_time_approved__c);
        }
        else{
            Job.ECONZ_Integration_Error__c = true;
            if(ErrorMessage == ' manager error.notFound')
            {
                Job.ECONZ_Error_Message__c = 'Project Manager is not an Econz Operations Manager';
            }
            else
            {
                Job.ECONZ_Error_Message__c = ErrorMessage;
            }
        }
        system.debug(ErrorMessage);
        return Job;
    }
    
    private static ATI_Job__c updateSuccessDetails(ATI_Job__c Job) {
        Job.ECONZ_Last_Callout_Time__c = system.now();
        Job.ECONZ_Integration_Error__c = false;
        Job.ECONZ_Error_Message__c = null;
        return Job;
    }
    
    private static string buildAddTaskRequestXML(ATI_Job__c Job, string method, string PM_Key, dateTime startdate) {
        system.debug('AddTaskManager----------'+method);
        string strReq = getHeaderXML();
        //Added by Athith : To check the startdate have value
        system.debug('@@@startdate'+startdate);
        Datetime stDate;
        If(startdate != null)
        {
            stDate = startdate;
        }
        else
        {
            stDate = Job.date_time_approved__c;
        }
        
        Date d;
        Datetime myDT;
        if(Job.Completion_Date__c != null){
            d = Job.Completion_Date__c.addDays(30);
            myDT = datetime.newInstance(d.year(), d.month(), d.day());
        }
        strReq = strReq + '<soapenv:Body><tim:' + method + ' soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        strReq = strReq + getUserBean();
        if (method == 'addTaskForManager')
            strReq = strReq + '<managerID xsi:type="xsd:string">' + PM_Key + '</managerID>' + '<task xsi:type="tim:DetailedTaskWithAddressAndTime">';
        else
            strReq = strReq + '<taskName xsi:type="xsd:string"><![CDATA[' + Job.Name + ']]></taskName><taskDetails xsi:type="tim:DetailedTaskWithAddressAndTime">';
        strReq = strReq +
            '<taskName xsi:type="xsd:string"><![CDATA[' + Job.Name + ']]></taskName>' +
            '<teamName xsi:type="xsd:string"></teamName>' +
            '<customFieldArray xsi:type="tim:ArrayOfCustomField" soapenc:arrayType="tim:CustomField[4]">' +
            '<customField xsi:type="tim:CustomField">' +
            '<name xsi:type="string">Office</name>' +
            '<value xsi:type="string"><![CDATA[' + Job.Office__c + ']]></value>' +
            '</customField>' +
            '<customField xsi:type="tim:CustomField">' +
            '<name xsi:type="string">Division</name>' +
            '<value xsi:type="string"><![CDATA[' + Job.Division__c + ']]></value>' +
            '</customField>' +
            '<customField xsi:type="tim:CustomField">' +
            '<name xsi:type="string">Project Director</name>' +
            '<value xsi:type="string"><![CDATA[' + Job.Project_Manager__r.Name + ']]></value>' +
            '</customField>' +
            '<customField xsi:type="tim:CustomField">' +
            '<name xsi:type="string">Stage</name>' +
            '<value xsi:type="string"><![CDATA[' + Job.Stage__c + ']]></value>' +
            '</customField>' +
            '<customField xsi:type="tim:CustomField">' +
            '<name xsi:type="string">Salesforce record ID</name>' +
            '<value xsi:type="string">' + Job.Id + '</value>' +
            '</customField>' +           
            '</customFieldArray>' +
            '<address1 xsi:type="xsd:string"><![CDATA[' + Job.Project_Site_Address__c + ']]></address1>' +
            '<address2 xsi:type="xsd:string"><![CDATA[' + Job.Project_Site_Address_2__c + ']]></address2>' +
            '<city xsi:type="xsd:string"><![CDATA[' + Job.Project_Site_City__c + ']]></city>' +
            '<state xsi:type="xsd:string"><![CDATA[' + Job.Project_Site_State__c + ']]></state>' +
            '<postCode xsi:type="xsd:string">' + Job.Project_Site_Zipcode__c + '</postCode>' +
            '<country xsi:type="xsd:string">US</country>';
        //strReq = strReq + '<start xsi:type="xsd:dateTime">' + startdate.format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT') + '</start>';
        strReq = strReq + '<start xsi:type="xsd:dateTime">' + stDate.format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT') + '</start>';
        if (myDT != null){
            strReq = strReq + '<end xsi:type="xsd:dateTime">' + myDT.addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT') + '</end>';
        }
        strReq = (method == 'addTaskForManager') ? strReq + '</task>' : strReq + '</taskDetails>';
        strReq = strReq + '</tim:' + method + '>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        system.debug('@@@strReq'+strReq);
        return strReq;
    }
    
    private static string buildUpdateTaskRequestXML(ATI_Job__c Job, dateTime startdate) {
        system.debug('===startdate==='+startdate);
        system.debug('===Job Stage==='+Job.Stage__c);      
        Datetime myDT;
        if(Job.Completion_Date__c != null){
            Date d = Job.Completion_Date__c.addDays(30);
            myDT = datetime.newInstance(d.year(), d.month(), d.day());
            system.debug('myDT -> 1'+myDT );
        }
        //Athith Comments        
        //When ATI_Job__c stage is Won then Overide the End date to be null        
        if(Job.Stage__c == 'Won')
        {
            myDT = null;
            system.debug('myDT -> 2'+myDT );
        }
        string strReq = getHeaderXML();
        strReq = strReq + '<soapenv:Body><tim:updateTaskStartEnd soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        strReq = strReq + getUserBean();
        strReq = strReq + '<taskName xsi:type="xsd:string"><![CDATA[' + Job.Name + ']]></taskName>' +
            '<start xsi:type="xsd:dateTime">' + startdate.format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT') + '</start>';
        //Athith Comments        
        //When ATI_Job__c stage is Won then Overide the End date to be Current Date
        if (Job.Stage__c == 'Lost'){
            myDT = system.now();
            system.debug('myDT -> 3'+myDT );
            strReq = strReq +'<end xsi:type="xsd:dateTime">' + myDT.format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT') + '</end>';
        }
        else if (myDT != null){
            system.debug('myDT -> 4'+myDT );        
            strReq = strReq +'<end xsi:type="xsd:dateTime">' + myDT.addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT') + '</end>';
        }
        else{
            system.debug('myDT -> 5'+myDT ); 
            //strReq = strReq +'<end xsi:type="xsd:dateTime"></end>';
        }
        strReq = strReq +'</tim:updateTaskStartEnd>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        system.debug('===strReq==='+strReq);
        return strReq;
    }
    
    private static string buildCreateUserRequestXML(ATI_Job__c Job) {
        string loginId = Job.Project_Manager_New__r.Email.split('@')[0];
        string strReq = getHeaderXML();
        strReq = strReq + '<soapenv:Body><tim:createUser soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        strReq = strReq + getUserBean();
        strReq = strReq + ' <user xsi:type="tim:UserBean" xmlns:tim="http://nads.econz.co.nz/timecard1/">'+
            '<updateIndex xsi:type="xsd:int">12</updateIndex>'+
            '<deleted xsi:type="xsd:boolean">false</deleted>'+
            '<loginID xsi:type="xsd:string">'+loginId + '</loginID>'+
            '<name xsi:type="xsd:string">'+Job.Project_Manager_New__r.Name + '</name>'+
            '<timezone xsi:type="xsd:string">US/Pacific</timezone>'+
            '<userTypePK xsi:type="xsd:string">9</userTypePK>'+
            '<emailAddress xsi:type="xsd:string">'+Job.Project_Manager_New__r.Email + '</emailAddress>'+
            '</user>'+
            '<password xsi:type="xsd:string">temp123</password>'+
            '</tim:createUser>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return strReq;
    }
    
    private static string buildGetUserDetailByLogin(string LoginId) {
        string strReq = getHeaderXML();
        strReq = strReq + '<soapenv:Body><tim:getUserDetailByLoginID soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        strReq = strReq + getUserBean();
        strReq = strReq + '<loginID xsi:type="xsd:string">' + LoginId + '</loginID>' +
            '</tim:getUserDetailByLoginID>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        system.debug('strReq----'+strReq);
        return strReq;
    }
    
    private static string buildRenameTaskRequestXML(ATI_Job__c Job, string OldName) {
        string strReq = getHeaderXML();
        strReq = strReq + '<soapenv:Body><tim:renameTask soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        strReq = strReq + getUserBean();
        strReq = strReq + '<oldTaskName xsi:type="xsd:string"><![CDATA[' + OldName + ']]></oldTaskName>' +
            '<newTaskName xsi:type="xsd:string"><![CDATA[' + Job.Name + ']]></newTaskName>' +
            '</tim:renameTask>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return strReq;
    }
    
    private static string buildUpdateManagerRequestXML(ATI_Job__c Job, string PM_Key) {
        string strReq = getHeaderXML();
        strReq = strReq + '<soapenv:Body><tim:updateTaskManager soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        strReq = strReq + getUserBean();
        strReq = strReq + '<taskName xsi:type="xsd:string"><![CDATA[' + Job.Name + ']]></taskName>' +
            '<managerID xsi:type="xsd:string">' + PM_Key + '</managerID>' +
            '</tim:updateTaskManager>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return strReq;
    }
    
    private static string getHeaderXML() {
        return '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tim="http://nads.econz.co.nz/timecard1/"><soapenv:Header/>';
    }
    
    private static string getUserBean() {
        string userId,password;
        Map<string,EconzIntegration__c> mapCredentials = EconzIntegration__c.getAll();
        if([SELECT IsSandbox FROM Organization].isSandbox){
            if(mapCredentials != null && mapCredentials.get('Test') != null){
                userId = mapCredentials.get('Test').UserID__c;
                password = mapCredentials.get('Test').Password__c;
            }
        }
        else{
            if(mapCredentials != null && mapCredentials.get('Prod') != null){
                userId = mapCredentials.get('Prod').UserID__c;
                password = mapCredentials.get('Prod').Password__c;
            }
        }
        
        string strUserBean = '<userID xsi:type="soap:UserIDBean" xmlns:soap="http://soap2.nads.econz.co.nz">' +
            '<password xsi:type="xsd:string">'+password+'</password>' +
            '<userName xsi:type="xsd:string">'+userId+'</userName>' +
            '<version xsi:type="soap:NADSWebserviceVersion">TIMECARD_VERSION_1</version>' +
            '</userID>';
        system.debug('strUserBean----'+strUserBean);
        return strUserBean;
    }
    
    public static String walkThrough(DOM.XMLNode node, Set<String> setAttributeValues) {
        String result = ''; // = '\n';
        if (node.getNodeType() == DOM.XMLNodeType.COMMENT) {
            return 'Attribute (' + node.getText() + ')';
        }
        if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
            return 'Value (' + node.getText() + ')';
        }
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            //if(node.getName() == 'property' || node.getName() == 'key'){
            if (setAttributeValues.contains(node.getName())) {
                if (node.getText().trim() != '') {
                    result += ' ' + node.getText().trim();
                }
            }
            for (Dom.XMLNode child : node.getChildElements()) {
                result += walkThrough(child, setAttributeValues);
            }
            system.debug('result-----------'+result);
            return result;
        }
        return ''; //should never reach here 
    }
}