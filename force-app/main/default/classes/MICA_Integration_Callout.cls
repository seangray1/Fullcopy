/**
 * @File Name          : MICA_Integration_Callout.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : sean.gray@atirestoration.com
 * @Last Modified On   : 11/21/2019, 2:19:02 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/23/2019, 11:17:46 AM   sean.gray@atirestoration.com     Initial Version
**/
Global class MICA_Integration_Callout {
    //3rd Step
    public static String EstimateTypeMethod = '';
    public static Boolean WaterLossClass = false;
    public static string classNumber = '';
    public static string categoryNumber = '';
    public static string ProjectId;
    public static string ReviewId;
    public static string ProjectGuid;
    public static Boolean Flag;

    

    public static ATI_Job__c getJobRecord(Id JobId) {
        system.debug('Before getJobRecord if statement');
        If(WaterLossClass){
        List<ATI_Job__c> Job = [SELECT Id, Name, Office2__c, claim__c, policy__c, Contact__r.name, Contact__r.FirstName, Contact__r.LastName, 
        job_Start_Date__c, Project_Site_Address__c, Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c, Project_Manager_FirstName__c, 
        Project_Manager_LastName__c, division__c, MICA_Integration__c, ProjectGuid__c,ProjectId__c, class__c, category__c, project_manager__c, 
        account__c, MICA_Last_Successful_Sync__c, ReviewId__c, QA_Assist_Estimate__c, job_name__c, job_number_No_Dashes__c, Mica_error_message__c
                           FROM ATI_Job__c WHERE Id = :JobId];
        if(Job.size() > 0){
              return Job[0];
        }
        else{
              return null;
        }
        }
        If(!WaterLossClass){
        List<ATI_Job__c> Job = [SELECT Id, Name, Office2__c, claim__c, policy__c, Contact__r.name, Contact__r.FirstName, Contact__r.LastName, 
        job_Start_Date__c, Project_Site_Address__c, Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c, division__c, Project_Manager_FirstName__c,
         Project_Manager_LastName__c, category__c, class__c, MICA_Integration__c, ProjectGuid__c, ProjectId__c, project_manager__c, account__c,
          MICA_Last_Successful_Sync__c, ReviewId__c, QA_Assist_Estimate__c, job_name__c, job_number__c, job_number_No_Dashes__c, Mica_error_message__c
                           FROM ATI_Job__c WHERE Id = :JobId];    
        if(Job.size() > 0){
              return Job[0];
        }
        else{
              return null;
        }
        }
        return null;
        
    }

    //1st Step
    webservice static string invokeIntegration(Id JobId, Boolean waterLoss, String estimatetype, String classNum, String categoryNum) {
        string Copy1 = 'line';
     string Copy2 = 'line';
     string Copy3 = 'line';
     string Copy4 = 'line';
     string Copy5 = 'line';
     string Copy55 = 'line';
     string Copy15 = 'line';
     string Copy16 = 'line';
     string Copy167 = 'line';
     string Copy12 = 'line';
     string Copy11 = 'line';
     string Copy1423 = 'line';
     string Copy125 = 'line';
     string Copy1123 = 'line';
     string Copy1452 = 'line';
     string Copy1513 = 'line';
     string Copy1456 = 'line';
     string Copy134 = 'line';
     string Copy177 = 'line';
     string Copy6 = 'line';
     string Copy7 = 'line';
     string Copy8 = 'line';
     string Copy9 = 'line';
     string Copy10 = 'line';
     string Copy17 = 'line';
     string Copy18 = 'line';
     string Copy19 = 'line';
     string Copy20 = 'line';
     string Copy21 = 'line';
     string Copy122 = 'line';
     string Copy123 = 'line';
     string Copy126 = 'line';
     string Copy127 = 'line';
     string Copy128 = 'line';
     string Copy129 = 'line';
     string Copy130 = 'line';
     string Copy131 = 'line';
     string Copy132 = 'line';
     string Copy133 = 'line';
     string Copy1344 = 'line';
     string Copy135 = 'line';
     string Copy136 = 'line';
     string Copy137 = 'line';
     string Copy138 = 'line';
     string Copy139 = 'line';
     string Copy140 = 'line';
     string Copy141 = 'line';
     string Copy142 = 'line';
     string Copy143 = 'line';
     string Copy144 = 'line';
     string Copy145 = 'line';
     string Copy146 = 'line';
     string Copy147 = 'line';
     string Copy148 = 'line';
     string Copy149 = 'line';
     string Copy150 = 'line';
     string Copy151 = 'line';
     string Copy152 = 'line';
     string Copy153 = 'line';
     string Copy154 = 'line';
     string Copy155 = 'line';
     string Copy156 = 'line';
     string Copy157 = 'line';
     string Copy158 = 'line';
    string Copy160 = 'line';
    string Copy161 = 'line';
     string Copy162 = 'line';
     string Copy163 = 'line';
     string Copy164 = 'line';
     string Copy165 = 'line';
    string Copy166 = 'line';
    string Copy167a = 'line';
     string Copy168 = 'line';
     string Copy169 = 'line';
     string Copy170 = 'line';
     string Copy171 = 'line';
     string Copy172 = 'line';
     string Copy173 = 'line';
     string Copy174 = 'line';
     string Copy175 = 'line';
     string Copy176 = 'line';
     string Copy177h = 'line';
     string Copy178 = 'line';
     string Copy179 = 'line';
    string Copy180 = 'line';
        classNumber = classNum;
        categoryNumber = categoryNum;
        EstimateTypeMethod = estimatetype;
        WaterLossClass = waterloss;
        system.debug('Claim Number : '+classNumber + '@@@@@@ CategoryNumber : ' + categoryNumber+ '@@@@@ Estimate Type : ' +EstimateType + '@@@@ waterloss : '+ WaterLossClass);
        ATI_Job__c Job = getJobRecord(JobId);
        String method;
            method = 'UploadProjectInfo';
            if(job.division__c == 'Construction' || (job.division__c == 'Emergency Svces' && WaterLossClass == true)){
        return integrateMICA(JobId, method);
            }
            else{
                
                return '200';
            }
        
    }

    //2nd Step
    public static string integrateMICA(Id JobId, String action){
        system.debug('action-----'+action);
        ATI_Job__c Job = getJobRecord(JobId);
        string msg = '';
       // if(!Job.isEmpty()){
                    system.debug('Sync With MICA');
                    msg = addProjectinfo(Job, action);
                    system.debug(job);
         //       }
        system.debug('integrateMICA');
        system.debug('XML Sending =========');
        system.debug(Job);
        //add Field to Update such as synced with MICA = true
        //update Job;
      //  system.debug('MICA Integration is equal to '+Job.ECONZ_Task_Created__c);
        //error messaging, need to add MICA Error message
            return msg;
        }
    
public static String addProjectInfo(ATI_Job__c Job, String method) {
        
            string reqXML;
            //if(method == 'UploadProjectInfo'){
            reqXML = buildUploadProjectInfoRequestXML(Job , method);
            //}
           /* if(method == 'UploadEstimate'){
                reqXML = buildUploadEstimateRequestXML(Job, method);
            }*/
           // system.debug('reqXML-----'+reqXML);
           // invokeCallAndUpdateResults(reqXML, Job, method);
        
        //update Job;
        return invokeCallAndUpdateResults(reqXML, Job, method);
    }


private static string buildUploadProjectInfoRequestXML(ATI_Job__c Job, string method) {
     String office;
     Office__c off = [Select Id, Name FROM Office__c WHere Id =: job.office2__c];
        if(off.name == 'Anaheim'){
            office = 'ATI-ANAHEIM';
        }
        if(off.name == 'Chicago' || off.name == 'DENVER' || off.name == 'FLAGSTAFF' 
        || off.name == 'HOUSTON' || off.name == 'HQ' || off.name == 'ORLANDO' ||
        off.name == 'SACRAMENTO' || off.name == 'SEATTLE' || off.name == 'TUCSON'){
            office = 'ATI-' + off.name;
            office.toUpperCase();
        }
        if(off.name == 'Dallas'){
            office = 'ATI-DALLAS-PLANO';
        }
        if(off.name == 'Las Vegas'){
            office = 'ATI-LAS-VEGAS';
        }
        if(off.name == 'Los Angeles'){
            office = 'ATI-LOS-ANGELES';
        }
        if(off.name == 'New England'){
            office = 'ATI-NEW-ENGLAND';
        }
        if(off.name == 'Philadelphia'){
            office = 'ATI-PHILADELPHIA';
        }
        if(off.name == 'Phoenix'){
            office = 'ATI-PHOENIX';
        }
        if(off.name == 'Riverside'){
            office = 'ATI-INLAND-EMPIRE';
        }
        if(off.name == 'San Diego'){
            office = 'ATI-SAN-DIEGO';
        }
        if(off.name == 'San Francisco'){
            office = 'ATI-HAYWARD';
        }
        if(off.name == 'San Jose'){
            office = 'ATI-SAN-JOSE';
        }
        if(off.name == 'Sonoma'){
            office = 'ATI-PETALUMA';
        }
        if(off.name == 'Tampa'){
            office = 'ATI-FLORIDA';
        }
        system.debug('buildUploadProjectInfoRequestXML----------'+method);
        string strReq = getHeaderXML();
        List<Account> a = [Select Id, BillingAddress, Name FROM Account Where Id=:job.account__c];
        List<Contact> c = [Select Id, Email, firstName, LastName From Contact Where Id=:job.contact__c];
        Datetime stDate = System.Now();
        strReq = strReq + '<soap:Body>'+'<'+method + ' xmlns="http://buildfusion.com/">' + '<xmlString>';
        strReq = strReq + '<![CDATA[<PropertyDamageRemodelExchange>'+ '<DateSent>' + stDate.format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT') + '</DateSent>';
        strReq = strReq + getUserBean('Project');
       strReq = strReq + '<EntityCode>'+office+'</EntityCode>';
        //strReq = strReq + '<EntityCode>'+'ATI_TEST'+'</EntityCode>';

        //PUT OFFICE
        strReq = strReq +'<MasterLocation>' +'General' + '</MasterLocation>';
        strReq = strReq +'<MessageType>' + 'ProjectExport' + '</MessageType>';
        strReq = strReq + '<Project>';
        strReq = strReq + '<ProjectInternalId>'+ job.id + '</ProjectInternalId>';
        strReq = strReq +'<ClaimNumber>' + job.claim__c + '</ClaimNumber>';
        strReq = strReq +'<PolicyNumber>' + job.policy__c + '</PolicyNumber>';
        strReq = strReq +'<Contact>';
        strReq = strReq +'<ContactType>OWNER</ContactType>';
       // if(!c.isEmpty() && !String.isBlank(c[0].firstName)){
        //strReq = strReq +'<ContactFirstName>' + c[0].firstName + '</ContactFirstName>';}
        strReq = strReq +'<ContactFirstName>' + job.job_name__c + '</ContactFirstName>';
        //if(!c.isEmpty() && !String.isBlank(c[0].LastName)){
       // strReq = strReq +'<ContactLastName>' + c[0].LastName + '</ContactLastName>';}
        //if(!c.isEmpty() && !String.isBlank(c[0].email)){
        //strReq = strReq +'<EmailAddress>' + c[0].email + '</EmailAddress>';}
         strReq = strReq +'</Contact>';
        strReq = strReq +'<Contact>';
        strReq = strReq +'<ContactType>INSCO</ContactType>';
        if(!a.isEmpty() && !String.isBlank(a[0].Name)){
        strReq = strReq + '<ContactFirstName>'+ a[0].Name + '</ContactFirstName>';}
        strReq = strReq + '</Contact>';
        strReq = strReq +'<ProjectEvent>';
        strReq = strReq +'<ProjectEventCode>LOSSDATE</ProjectEventCode>';
        strReq = strReq +'<ProjectEventDate>' + job.job_Start_Date__c + '</ProjectEventDate>';
        strReq = strReq +'</ProjectEvent>';
        strReq = strReq +'<Notes>';
        strReq = strReq +'<Id>'+ job.id + '</Id>';
        strReq = strReq +'<Name>Description of loss</Name>';
        strReq = strReq +'<Type>DN</Type>';
        strReq = strReq +'<TimeStampUtc>' + system.now() + '</TimeStampUtc>';
        strReq = strReq +'<Note></Note>';
        strReq = strReq +'</Notes>';
        strReq = strReq +'<ExtendedProjectProperties>'; 
        system.debug('WaterLoss Class is + ' + WaterLossClass);
        if(WaterLossClass){
        strReq = strReq +'<ExtendedProjectProperty Source="ATI" Name="Division"' +' '+ 'Value="' +job.division__c + '-Water"'+ ' '+ 'Type="string"/>';
        }
        if(!WaterLossClass){
        strReq = strReq +'<ExtendedProjectProperty Source="ATI" Name="Division"' +' '+ 'Value=' +'"'+ job.division__c + '"'+ ' '+ 'Type="string"/>'; 
        }
        strReq = strReq +'</ExtendedProjectProperties>'; 
        strReq = strReq +'</Project>';
        strReq = strReq +'<DataSource>ATI</DataSource>'; 
        strReq = strReq +'</PropertyDamageRemodelExchange>';
        strReq = strReq +']]>';
        strReq = strReq +'</xmlString>';
        strReq = strReq +'</'+ method + '>';
        strReq = strReq +'</soap:Body>';
        strReq = strReq +'</soap:Envelope>';
        system.debug('@@@strReq'+strReq);
        return strReq;
    }
    
    private static string invokeCallAndUpdateResults(string reqXML, ATI_Job__c Job, string method) {
        system.debug('method------'+method);
        system.debug(reqXML);
      //  invokeUploadEstimate(job, waterLoss);
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
        list<string> returnmessages = new list<string>();
        try{
        if (statusCode == '200') {
            boolean isError = doc.toXmlString().contains('ErrorBean') ? true : false;
            
             
                 Dom.Document doc1 = new Dom.Document();
        system.debug('doc with xml string ' + doc.toXmlString());
        String docString = doc.toXmlString();
        string chars = '&lt;';
        string replacechars = '<';
        string docStringConverted = docString.replace(chars, replacechars);
        system.debug('doc&&& '+ docStringConverted);
        doc1.load(docStringConverted);
        system.debug('doc&&&1 '+ doc1);
        system.debug('doc root element ' + doc1.getrootelement());
            for(DOM.xmlnode body : doc1.getrootelement().getchildelements()){
                system.debug('Body ' + body.getName());
				for( dom.xmlnode UploadProjectInfoResponse : body.getchildelements()){
                    system.debug('UploadProjectResponse ' + body.getName());
					for (dom.xmlnode UploadProjectInfoResult : UploadProjectInfoResponse.getchildelements()){
                        system.debug('UploadProjectResult'+ UploadProjectInfoResult.getName());
                        for(dom.xmlnode DocumentElement : uploadprojectinforesult.getchildelements()){
                            system.debug('DocumentElement'+ DocumentElement.getName());
                           
                        //system.debug('after uploaddprojectresult ' + uploadprojectinforesponse.getName());
                        //system.debug('child element' + uploadprojectinforesponse.getchildelement('ProjectGuid', 'http://buildfusion.com/'));
                        //system.debug('uploadprojectinforesponse ' + uploadprojectinforesponse.getchildelement('Documentelement', 'http://buildfusion.com/'));
                       // dom.xmlnode documentelement = uploadprojectinforesponse.getchildelement('Documentelement','http://buildfusion.com/');
                       // system.debug('DocumentElement ' + documentelement);
                       // dom.xmlnode returnmessage = documentelement.getchildelement('returnmessage', 'http://buildfusion.com/');
                        //system.debug('returnmessage ' + returnmessage);
                        //system.debug(returnmessage.getchildelement('ProjectGuid', 'http://buildfusion.com/').getText());
						for(dom.xmlnode returnmessage : DocumentElement.getchildelements()){
                            system.debug('Return Message Name : '+ returnmessage.getName());
                            system.debug('ProjectGuid is ' + returnmessage.getchildelement('ProjectGuid', 'http://buildfusion.com/').getText());
                            String projectId1 = returnmessage.getChildElement('ProjectID', 'http://buildfusion.com/').getText();
                            String projectguid1 = returnmessage.getchildelement('ProjectGuid', 'http://buildfusion.com/').getText();
                           // String projectId1 = returnmessage.getChildElement('ProjectId', 'http://buildfusion.com/').getText();
                           system.debug(projectguid1);
                            system.debug('ProjectId : '+ projectId1);
                           // system.debug(projectguid1);
                            ProjectGuid = projectguid1;
                            ProjectId = projectId1;
                           // ProjectGuid = returnmessage.getchildelement('ProjectGuid', 'http://buildfusion.com/').getText();
                           // ProjectId = returnmessage.getchildelement('ProjectId', 'http://buildfusion.com/').getText();
                           // system.debug('uploadprojectinforesult ' + uploadProjectinfoResult.getName());
							//for(dom.xmlnode documentelement1 : uploadProjectinfoResult.getchildelements()){
                              //  system.debug('documentelement ' + documentelement);
                              //  if(documentelement1.getName()=='returnmessage'){
                               //     system.debug('Getting through the if statement '+ documentelement1.getName());
								//for (dom.xmlnode returnmessage : documentelement.getchildelements()){
                                    //system.debug(returnmessage.getname());
									//if(returnmessage.getname() == 'returnmessage') {
							//returnmessages.add(returnmessage.getchildelement('projectguid',null).getText());
						   // ProjectGuid = (documentelement.getchildelement('ProjectGuid','http://buildfusion.com/').getText());
                           // ProjectId = (documentelement.getchildelement('ProjectId','http://buildfusion.com/').getText());
                           // system.debug('ProjectGuid ' + ProjectGuid);
                           // ProjectGuid=(documentelement.getchildelement('Status','http://buildfusion.com/').getText());
                                    //returnmessages.add(documentelement.getchildelement('projectguid',null).getText());
                                     //   system.debug('returnmessage ' + documentelement);
                                               }
                                               }
                                               }
                                               }
                                               
            }                              
            }else{
                return '400';
            }     
}
        catch(exception e){
            system.debug(e.getMessage());
            return '400';
        }
        
    
    system.debug('Estimate Type before Uploading Estimate : ' + EstimateTypeMethod);
    return invokeUploadEstimate(job.id, EstimateTypeMethod, classNumber, categoryNumber, 'UploadEstimate', WaterLossClass);
   
    }
    
        

    webservice static String invokeUploadEstimate(Id jobs, String EstimateType, String classNum, String category, String method, Boolean isWaterLoss){
        system.debug('Before Retrieving Records');
        ATI_Job__c job = getJobRecord(jobs);
        EstimateTypeMethod = EstimateType;
        system.debug('Estimate Type Method is + ' + EstimateTypeMethod);
        classNumber = classNum;
        categoryNumber = category;
        WaterLossClass = isWaterLoss;
        
       
        //return 'Working';
        return addEstimateInfo(Job, method);
    }

    public static String addEstimateInfo(ATI_Job__c Job, String method) {
        
            string reqXML;
            if(method == 'UploadEstimate'){
                reqXML = buildUploadEstimateRequestXML(Job, method);
            }
        return invokeEstimateCall(reqXML, Job, method);
    }
    private static string buildUploadEstimateRequestXML(ATI_Job__c Job, string method) {
        system.debug('buildUploadProjectInfoRequestXML----------'+method);
        Map<string,MICAIntegration__c> mapCredentials = MICAIntegration__c.getAll();
        Decimal count = mapCredentials.get('UploadEstimate').count__c;
        
        count += 1;
        set<id> ctl = new set<id>();
        List<contentdocumentlink> a = [Select Id,contentdocumentId FROM contentdocumentlink where LinkedEntityId =: job.id Order By SystemModStamp DESC Limit 1];
        system.debug('Content documetn Link' + a[0]);
        List<contentversion> ctv = [Select Id, contentdocumentId, versiondata, title FROM ContentVersion Where contentdocumentId =: a[0].contentdocumentId];
        system.debug('Ctv ' + ctv[0]);
        list<User> u = [Select Id, email FROM User Where Id=:job.project_Manager__c];

        //change office to meet NextGearSolutions office
          Integer countOfEstimates;
        List<estimate__c> estimateLookup = [Select Id, Name, job__c, creation_date__c FROM Estimate__c Where job__c =: job.id ORDER BY Creation_Date__c DESC];
        //List<estimate__c> estimateLookupSupplement = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Estimate_Type__c = 'Supplement' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        //List<estimate__c> estimateLookupChangeOrder = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Estimate_Type__c = 'Change Order' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        Estimate__c estimate = new Estimate__c(Name = EstimateTypeMethod, Estimate_type__c = EstimateTypeMethod, job__c = job.id, creation_date__c = system.now());
        // if(EstimateTypeMethod == 'Main'){
            //countOfEstimates = estimateLookup.size();
            if(EstimateTypeMethod == 'Main'){
            countOfEstimates = 1;
            }
            if(EstimateTypeMethod == 'Supplement'){
                countOfEstimates = estimateLookup.size();
            countOfEstimates += 1;
            }
            if(EstimateTypeMethod == 'Change Order'){
            countOfEstimates = estimateLookup.size();
            countOfEstimates += 1;
            }
            //countOfEstimates += 1;
            //estimate.name = 'EST-' + job.job_number_No_Dashes__c + '-'+ '0'+ countOfEstimates;
           // insert estimate;
        //   Integer countOfEstimates;
        // List<estimate__c> estimateLookupMain = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Name like '%Main%' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        // List<estimate__c> estimateLookupSupplement = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Name like '%Supplement%' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        // List<estimate__c> estimateLookupChangeOrder = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Name like '%Change Order%' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
       
        // if(EstimateTypeMethod == 'Main'){
        //     countOfEstimates = estimateLookupMain.size();
        //     countOfEstimates += 1;
        // }
        // if(EstimateTypeMethod == 'Supplement') {
        //     countOfEstimates = estimateLookupSupplement.size();
        //     countOfEstimates += 11;
        // }
        // if(EstimateTypeMethod == 'Change Order') {
        //     countOfEstimates = estimateLookupChangeOrder.size();
        //     countOfEstimates += 13;
        // }

        string strReq = getHeaderXML1();
        
        Datetime stDate = System.Now();
        strReq = strReq + '<soap12:Body>'+'<'+method + ' xmlns="https://nextgearsolutions.com/">';
        strReq = strReq + '<userName>ATIQAAssist</userName>';
        //strReq = strReq + getUserBean('Estimate');
        strReq = strReq + '<password><![CDATA[@At1QAA5s1st]]></password>';
        strReq = strReq + '<request>';
        //system.debug(' Email of user ' + u[0].email);
        //if(!u.isEmpty() && !String.isBlank(u[0].email)){
        strReq = strReq +'<QaAssistUserID>' +u[0].email + '</QaAssistUserID>';//put pd email}
        strReq = strReq +'<ExternalSystemID>' + u[0].email + '</ExternalSystemID>';
        strReq = strReq + '<AuditExternalUserID>'+ u[0].email + '</AuditExternalUserID>'; // PUT PD EMAIL
         system.debug(job.Project_Manager_FirstName__c);
        strReq = strReq +'<AuditExternalUserFirstName>' + job.Project_Manager_FirstName__c + '</AuditExternalUserFirstName>';
        strReq = strReq +'<AuditExternalUserLastName>' + job.Project_Manager_LastName__c + '</AuditExternalUserLastName>';
        if(!u.isEmpty() && !String.isBlank(u[0].email)){ 
        strReq = strReq +'<ExternalUserEmail>' + u[0].email + '</ExternalUserEmail>';} // add the email of PD for Prod..
        if(!String.isBlank(job.ProjectGuid__c)){
        strReq = strReq +'<ProjectGuid>' + job.ProjectGuid__c + '</ProjectGuid>';}
        else {
        strReq = strReq +'<ProjectGuid>' +ProjectGuid + '</ProjectGuid>';    
        }      
        //strReq = strReq +'<EstimateType>'+ EstimateType + '</EstimateType>';
        strReq = strReq +'<EstimateType>'+ 'RoughDraft' + '</EstimateType>';
         //if(!String.isBlank(job.ProjectGuid__c)){
        double num = math.random();
        system.debug(string.valueOf(num));
        String ranNum = String.valueOf(num);
        String ranNum1 = ranNum.replaceAll('0.','1');
        strReq = strReq +'<EstimateBucketID>' +countOfEstimates + '</EstimateBucketID>';
        //else {
       // strReq = strReq +'<EstimateBucketID>' +'1' + '</EstimateBucketID>';    
       // }   
       // strReq = strReq +'<EstimateBucketID>' + 'ea123'+ '</EstimateBucketID>';
        strReq = strReq +'<EstimateBucketName>' +'<![CDATA[' + EstimateTypeMethod + ']]>'+ '</EstimateBucketName>';
        strReq = strReq +'<EstimateRevisionID>'+ranNum1+'</EstimateRevisionID>';
        //must be different each time.
        //if(WaterLossClass && ((!String.isBlank(categoryNumber)) || categoryNumber != '0')){
        if(WaterLossClass){
        strReq = strReq +'<WaterLossCategoryID>'+integer.ValueOf(categoryNumber)+ '</WaterLossCategoryID>';
        }
        else{
        strReq = strReq +'<WaterLossCategoryID>'+0+'</WaterLossCategoryID>';
        }
        //if(WaterLossClass = true && ((!String.isBlank(classNumber)) || classNumber != '0')){
        if(WaterLossClass){
       strReq = strReq +'<WaterLossClassID>'+integer.ValueOf(classNumber)+ '</WaterLossClassID>';
        }
        else{
        strReq = strReq +'<WaterLossClassID>'+0+'</WaterLossClassID>';    
        }
        strReq = strReq +'<UploadFileInfo>'; 
        strReq = strReq +'<FileName>' + '<![CDATA['+ ctv[0].title+'.pdf]]>'+  '</FileName>';  
        strReq = strReq +'<FileContent>' + EncodingUtil.base64Encode(ctv[0].versiondata) + '</FileContent>';  
        strReq = strReq +'</UploadFileInfo>';
        strReq = strReq +'</request>';
        strReq = strReq +'</'+ method + '>';
        strReq = strReq +'</soap12:Body>';
        strReq = strReq +'</soap12:Envelope>';
        system.debug('@@@strReq'+strReq);
        return strReq;
    }

    private static string invokeEstimateCall(string reqXML, ATI_Job__c Job, string method) {
        system.debug('method------'+method);
        system.debug(reqXML);
      //  invokeUploadEstimate(job, waterLoss);
        Map<string, dom.Document> returnMap = invokeHTTPRequest(reqXML, method);
        dom.Document doc;
        String isSuccessfull;
        string ReviewId;
        string statusCode;
        string ReviewUrl;
        String ErrorMessage;
        for (string a : returnMap.keyset()) {
            statusCode = a;
            doc = returnMap.get(statusCode);
            break;
        }
        //system.debug(doc.toXmlString());
        system.debug(statusCode);
        try{
        if (statusCode == '200') {
            boolean isError = doc.toXmlString().contains('ErrorBean') ? true : false;
            
             
             Dom.Document doc1 = new Dom.Document();
        system.debug('doc with xml string ' + doc.toXmlString());
        String docString = doc.toXmlString();
        string chars = '&lt;';
        string replacechars = '<';
        string docStringConverted = docString.replace(chars, replacechars);
        system.debug('doc&&& '+ docStringConverted);
        doc1.load(docStringConverted);
        system.debug('doc&&&1 '+ doc1);
        system.debug('doc root element ' + doc1.getrootelement());
            for(DOM.xmlnode body : doc1.getrootelement().getchildelements()){
                system.debug('Body ' + body.getName());
				for( dom.xmlnode UploadProjectInfoResponse : body.getchildelements()){
                    system.debug('UploadProjectResponse ' + UploadProjectInfoResponse.getName());
					for (dom.xmlnode UploadProjectInfoResult : UploadProjectInfoResponse.getchildelements()){
                        system.debug('UploadProjectInfoResult'+ UploadProjectInfoResult.getName());
                           // system.debug('Return Message Name : '+ returnmessage.getName());
                           // system.debug('ProjectGuid is ' + returnmessage.getchildelement('ProjectGuid', 'https://nextgearsolutions.com/').getText());
                           isSuccessfull = UploadProjectInfoResult.getChildElement('IsReviewSuccessful', 'https://nextgearsolutions.com/').getText();
                           system.debug('Is Successful : ' + isSuccessfull);
                           if(isSuccessfull == 'true'){
                            ReviewId = UploadProjectInfoResult.getChildElement('ReviewId', 'https://nextgearsolutions.com/').getText();
                            ReviewURL = UploadProjectInfoResult.getChildElement('ReviewUrl', 'https://nextgearsolutions.com/').getText();
                            system.debug('Review Url is ' + ReviewURL);
                           }else{
                            ErrorMessage = UploadProjectInfoResult.getChildElement('ErrorMessage', 'https://nextgearsolutions.com/').getText();
                           }
                           // String projectguid1 = returnmessage.getchildelement('ProjectGuid', 'https://nextgearsolutions.com/').getText();
                           // String projectId1 = returnmessage.getChildElement('ProjectId', 'http://buildfusion.com/').getText();
                           //system.debug(projectguid1);
                          //  system.debug('ProjectId : '+ projectId1);
                           // system.debug(projectguid1);
                            //ProjectGuid = projectguid1;
                           // ProjectId = projectId1;
                                         //      }
                                               }
                }
                }
                                               }else{
                                                   if(job.ProjectGuid__c == null){
                                                   job.projectGuid__c = ProjectGuid;
                                                   }
                                                    job.mica_integration__c = true;
                                                    job.mica_error_message__c = ErrorMessage;
                                                   update job;
                                                   return ErrorMessage;
                                               }
                                               }
        catch(exception e){
            job.projectGuid__c = ProjectGuid;
            job.mica_integration__c = true;
            job.mica_error_message__c = ErrorMessage;
            update job;
            system.debug(e.getMessage());
            return ErrorMessage;
        }

    if(isSuccessfull=='true'){
          Map<string,MICAIntegration__c> mapCredentials = MICAIntegration__c.getAll();
        MicaIntegration__c countUpdate = mapCredentials.get('UploadEstimate');
        countUpdate.count__c += 1;
        update countUpdate;
        job.mica_integration__c = true;
        if(job.ProjectGuid__c == null){
            job.First_Successful_Estimate_Upload__c = system.now();
        }
        job.MICA_Last_Successful_Sync__c = system.now();
        if(WaterLossClass){
        job.class__c = classNumber;
        job.category__c = categoryNumber;
        }
        job.reviewId__c = ReviewId;
        job.QA_Assist_Estimate__c = ReviewUrl;
        if(String.isBlank(job.ProjectGuid__c)){
        job.projectGuid__c = ProjectGuid;
        }
         if(String.isBlank(job.projectId__c)){
        job.projectId__c = ProjectId;
         }
        update job;
        Integer countOfEstimates;
        List<estimate__c> estimateLookup = [Select Id, Name, job__c, creation_date__c FROM Estimate__c Where job__c =: job.id ORDER BY Creation_Date__c DESC];
        //List<estimate__c> estimateLookupSupplement = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Estimate_Type__c = 'Supplement' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        //List<estimate__c> estimateLookupChangeOrder = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Estimate_Type__c = 'Change Order' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        Estimate__c estimate = new Estimate__c(Name = EstimateTypeMethod, estimate_link__c = ReviewUrl, Estimate_type__c = EstimateTypeMethod,job__c = job.id,reviewID__c = ReviewId, creation_date__c = system.now());
        // if(EstimateTypeMethod == 'Main'){
            countOfEstimates = estimateLookup.size();
            countOfEstimates += 1;
            estimate.name = 'EST-' + job.job_number_No_Dashes__c + '-'+ '0'+ countOfEstimates;
            insert estimate;
        // Integer countOfEstimates;
        // List<estimate__c> estimateLookupMain = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Name like '%Main%' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        // List<estimate__c> estimateLookupSupplement = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Name like '%Supplement%' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        // List<estimate__c> estimateLookupChangeOrder = [Select Id, Name, job__c, creation_date__c FROM Estimate__c where Name like '%Change Order%' AND job__c =: job.id ORDER BY Creation_Date__c DESC];
        // Estimate__c estimate = new Estimate__c(Name = EstimateTypeMethod, estimate_link__c = ReviewUrl, Estimate_type__c = EstimateTypeMethod, reviewID__c = ReviewId, job__c = job.id, creation_date__c = system.now());
        // if(EstimateTypeMethod == 'Main'){
        //     countOfEstimates = estimateLookupMain.size();
        //     countOfEstimates += 1;
        //     estimate.name = 'Main- ' + job.job_number_No_Dashes__c + '-'+ '00'+ countOfEstimates;
        //     insert estimate;
        // }
        // if(EstimateTypeMethod == 'Supplement') {
        //     estimate.Related_Estimate__c = estimateLookupMain[0].id;
        //     countOfEstimates = estimateLookupSupplement.size();
        //     countOfEstimates += 1;
        //     estimate.name = 'Supplement- ' + job.job_number_No_Dashes__c + '-'+ '00'+ countOfEstimates;
        //     insert estimate;
        // }
        // if(EstimateTypeMethod == 'Change Order') {
        //     estimate.Related_Estimate__c = estimateLookupMain[0].id;
        //     countOfEstimates = estimateLookupChangeOrder.size();
        //     countOfEstimates += 1;
        //     estimate.name = 'Change Order- ' + job.job_number_No_Dashes__c + '-'+ '00'+ countOfEstimates;
        //     insert estimate;
        // }
        List<contentdocumentlink> a = [Select Id,contentdocumentId FROM contentdocumentlink where LinkedEntityId =: job.id Order By SystemModStamp DESC Limit 1];
        system.debug('Content documetn Link' + a[0]);
        List<contentversion> ctv = [Select Id, Checksum, ContentDocumentId, ContentLocation, ContentModifiedById, 
        ContentModifiedDate, ContentSize,  FileExtension, FileType, FirstPublishLocationId, 
        IsAssetEnabled, IsLatest, IsMajorVersion, NegativeRatingCount, Origin, OwnerId, 
        PathOnClient, PositiveRatingCount, PublishStatus, RatingCount, ReasonForChange, 
        SharingOption, Title, VersionData, VersionNumber FROM ContentVersion Where contentdocumentId =: a[0].contentdocumentId];
        


        ContentVersion conVer = new ContentVersion();
        conVer.PathOnClient = '/' + ctv[0].PathOnClient; 
        conVer.Title = ctv[0].title; 
        conVer.VersionData = ctv[0].versionData; 
        insert conVer;
        ContentDocumentLink cDe = new ContentDocumentLink();
        ContentVersion cdId = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :conVer.Id];
        cDe.ContentDocumentId = cdId.contentdocumentId;
        cDe.LinkedEntityId = estimate.id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe; 
        //ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :conVer.Id];
        return isSuccessfull;
    }else{
          if(job.ProjectGuid__c == null){
          job.projectGuid__c = ProjectGuid;
          }
          job.mica_integration__c = true;
          job.mica_error_message__c = ErrorMessage;
          update job;
          return ErrorMessage;
    }
        
    }

    private static string getHeaderXML() {
        return '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
    }
    private static string getHeaderXML1() {
        return '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
    }
    
    private static string getUserBean(String RequestType) {
        string LoginId,Password;
        string strUserBean;
        Map<string,MICAIntegration__c> mapCredentials = MICAIntegration__c.getAll();
        if(RequestType == 'Project'){
        LoginId = mapCredentials.get('Prod').LoginID__c;
        password = mapCredentials.get('Prod').Password__c;
        strUserBean = '<LoginId>'+loginId+ '</LoginId>' +
            '<Password>'+password + '</Password>';
        }
        if(RequestType == 'Estimate'){
        LoginId = mapCredentials.get('UploadEstimate').LoginID__c;
        password = mapCredentials.get('UploadEstimate').Password__c;
        strUserBean = '<userName>'+loginId+ '</userName>' +
            '<password>'+password +'</password>';
        system.debug('strUserBean----'+strUserBean);
        }
        return strUserBean;
    }

    private static Map<string, dom.Document> invokeHTTPRequest(string reqXML, string method) {
        System.debug('reqXML:'+reqXML);
        System.debug('method:'+method);
        string EndPoint;
        Map<string,MicaIntegration__c> mapCredentials = MicaIntegration__c.getAll();
        System.debug('mapCredentials:'+mapCredentials);
       /* if([SELECT IsSandbox FROM Organization].isSandbox){
            if(mapCredentials != null && mapCredentials.get('Test') != null){
                EndPoint = mapCredentials.get('Test').EndPointURL__c;
            }
        }*/
        //else{
            if(method == 'UploadEstimate'){
                EndPoint = mapCredentials.get('UploadEstimate').EndPoint__c;
            }
            if(method == 'UploadProjectInfo'){
                EndPoint = mapCredentials.get('Prod').EndPoint__c;
            }
       // }
         try {
        Map<string, dom.Document> returnMap = new Map<string, dom.Document> ();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(EndPoint);
        req.setTimeout(120000);
        req.setMethod('POST');
        if(method == 'UploadEstimate'){
        req.setHeader('Content-Type', 'application/soap+xml; charset=utf-8');
        }
       // req.setHeader('Host', 'micaexchange.com');
        //if(method == 'UploadEstimate'){
        //req.setHeader('SOAPAction', 'https://nextgearsolutions.com/UploadEstimate');
        //}
        if(method == 'UploadProjectInfo'){
      //  req.setHeader('SOAPAction', 'http://buildfusion.com/UploadProjectInfo');
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        }
     
        req.setBody(reqXML);
        req.setTimeout(120000);
        Http http = new Http();
        System.debug(method);
        system.debug(req);
       
            
        
        HTTPResponse res = http.send(req);
         
        system.debug('res is ' + res );
        System.debug('res.getBody:'+res.getBody());
        System.debug('res.getStatusCode:'+res.getStatusCode());

        if (res.getStatusCode() == 200) {
            Dom.Document doc = res.getBodyDocument();
            system.debug('Response:'  +doc.toXmlString()); 
            returnMap.put(string.valueof(res.getStatusCode()), doc);  
        }
        else {
            returnMap.put('StatusCode:' + res.getStatusCode() + ' Status:' + res.getStatus(), null);
    }
        return returnMap;
        
            
        }catch (Exception e) {
            system.debug('Exception is ' + e);
            Map<string, dom.Document> returnMap = new Map<string, dom.Document> ();
            returnMap.put('StatusCode:' + '400'+ ' Status:'+ 'Failure', null);
            return returnMap;
        
        }
    
    }

    
    
}