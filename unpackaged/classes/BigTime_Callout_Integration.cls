/**
 * @File Name          : BigTime_Callout_Integration.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/11/2019, 6:07:55 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/3/2019   Sean Gray     Initial Version
**/
public with sharing class BigTime_Callout_Integration {
    public static Map<Id, Account> accountMap = new Map<Id,Account>();
    public static Map<Id, Contact> contactMap = new Map<Id,Contact>();
    public static Map<Id, ATI_Job__c> jobMap = new Map<Id,ATI_Job__c>();
    //public static List<ATI_Job__c> jobList;
    public static Set<Id> accountSetIds = new Set<Id>();
    public static Set<Id> contactSetIds = new Set<Id>();
    public static String firmId;
    public static String token;


@AuraEnabled
    public static void invokeCallout(Id jobId) {
        system.debug('Hitting this point');
        List<ATI_Job__c> jobList = new List<ATI_Job__c>();
        List<ATI_Job__c> jobs = [Select Id, BigtimeSID__c, name, division__c, stage__c, contact__c, account__c, claim__c, project_site_city__c, project_site_Zipcode__c, project_site_state__c, project_site_address__c FROM ATI_Job__c Where Id =: jobId];
        for(ATI_Job__c job : jobs){
            //ATI_Job__c oldjob = oldJobs.get(job.id);  && job.stage__c == 'won' && job.stage__c != oldjob.stage__c 
            system.debug('Job info ' + job);
            if(job.division__c == 'Consulting') {
                jobList.add(job);
                jobMap.put(job.Id, job);
                //contactSetIds.add(job.contact__c);
                accountSetIds.add(job.account__c);
            }
        }
        system.debug('Job List  ' + jobList);
        if(!joblist.isEmpty()){
            

            //contactMap = new Map<Id,Contact>([Select Id, Email, Name, firstName, LastName, BigtimeSID__c, mailingAddress From Contact Where Id=:contactSetIds]);
            accountMap = new Map<Id,Account>([Select Id, Name, BigTimeSID__c, billingaddress From Account Where Id=:accountSetIds]);
            //system.debug('Contact : ' + contactMap);
            system.debug('Account : '+ accountMap);

            for(ATI_Job__c job : jobList){
                if(String.isEmpty(accountMap.get(job.account__c).bigtimeSID__c)){
                   PostJobAccountContact(job.name, 'AccountInsert', '', job.Id, job.account__c);
                }
                if(!String.isEmpty(jobMap.get(job.id).bigtimeSID__c) && !test.isRunningTest()){
                  PostJobAccountContact(job.name, 'JobUpdate', jobMap.get(job.id).bigtimeSID__c, job.Id,  job.account__c);
                }
                
                    //PostJobAccountContact(job.Name, 'JobInsert', '', job.Id, job.contact__c, job.account__c);
                if(String.isEmpty(jobMap.get(job.id).bigtimeSID__c)){
                    system.debug('Using insert Method ' + jobMap.get(job.id).bigtimeSID__c);
                  PostJobAccountContact(job.name, 'JobInsert', '', job.Id,  job.account__c);
                }
                
                // if(String.isEmpty(contactMap.get(job.contact__c).bigtimeSID__c)){
                //  PostJobAccountContact(job.name, 'ContactInsert', '', job.Id, job.contact__c, job.account__c);
                // }
                else{
                    system.debug('All Synced');
                   
                }
                
                // if(String.isEmpty(contactMap(job.contact__c).bigtimeSID__c)){
                //     PostJobAccountContact('', 'ContactInsert', '', job.Id, job.contact__c, job.account__c);
                // }
            }
        }

    }
    


public static void PostJobAccountContact(String jobName, String method, String Bigtimeid, String jobId, String AccountId){
    string editedId;
    string requestBody;
    SObject objectToUse;
    Map<string,BigTime__c> mapCredentials = BigTime__c.getAll();
            token = mapCredentials.get('Bigtime').token__c;
            firmId = mapCredentials.get('Bigtime').firmid__c;
    //Setting the ID to 15 digits
    if(method == 'AccountInsert'){
        editedId = accountId.right(jobId.length()-3)+jobId.right(0);
        //objectToUse = accountMap.get(AccountId);
        //contactMap = new Map<Id,Contact>([Select Id, Email, Name, firstName, LastName, BigtimeSID__c, mailingAddress From Contact Where Id=:contactId]);
        //accountMap = new Map<Id,Account>([Select Id, Name, BigTimeSID__c, billingaddress From Account Where Id=:accountId]);
    }
    if(method == 'JobInsert' || method == 'JobUpdate'){
        editedId = jobId.right(jobId.length()-3)+jobId.right(0);
        //objectToUse = jobMap.get(jobId);
        // jobMap = new Map<Id,ATI_Job__c>([Select Id, Name, BigTimeSID__c From ATI_Job__c Where Id=:jobId]);
        // accountMap = new Map<Id,Account>([Select Id, Name, BigTimeSID__c, billingaddress From Account Where Id=:accountId]);
        // contactMap = new Map<Id,Contact>([Select Id, Email, Name, firstName, LastName, BigtimeSID__c, mailingAddress From Contact Where Id=:contactId]);
    }
    // if(method == 'ContactInsert'){
    //     editedId = contactId.right(jobId.length()-3)+jobId.right(0);
    //     //objectToUse = contactMap.get(contactId);
    //     // jobMap = new Map<Id,ATI_Job__c>([Select Id, Name, BigTimeSID__c From ATI_Job__c Where Id=:jobId]);
    //     // contactMap = new Map<Id,Contact>([Select Id, Email, Name, firstName, LastName, BigtimeSID__c, mailingAddress From Contact Where Id=:contactId]);
    // }
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    //setting the Endpoint, and fields Depending on whether its Account/Job/Contact or Update/Insert
    system.debug('Method Used : ' + method);
    if(method == 'AccountInsert'){
        system.debug('Account Map in the callout : ' + accountMap);
        if(accountMap.get(AccountId).BillingAddress != null){
        requestBody = '{"Nm":"'+accountMap.get(AccountId).Name+'", "ClientId":"'+editedId+'"}'; //,"FullAddress":"'+accountMap.get(AccountId).BillingAddress+'"
        }else{
        requestBody = '{"Nm":"'+accountMap.get(AccountId).Name+'", "ClientId":"'+editedId+'"}';
        }
        request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/client/detail');
        system.debug('RequestBody is    ' + requestBody);
    }
    if(method == 'AccountUpdate'){
        request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/client/detail/'+accountMap.get(AccountId).BigTimeSID__c); 
        requestBody = '{"Nm":"'+jobName+'", "ProjectCode":"'+editedId+'"}'; //COME BACK AND FIX
    }
    if(method == 'JobInsert'){
        request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/project/detail');
        //if(String.isEmpty(contactMap.get(contactId).BigTimeSID__c)){
        requestBody = '{"Nm":"'+jobName+'", "ProjectCode":"'+editedId+'", "ClientId":"'+accountMap.get(AccountId).BigTimeSID__c+'","InvoiceNotes":"' +jobMap.get(jobId).claim__c + '\n' + jobName + '\n' + jobMap.get(jobId).project_site_Address__c + '\n' + jobMap.get(jobId).project_site_city__c + ', ' + jobMap.get(jobId).project_site_State__c + ', ' + jobMap.get(jobId).project_site_Zipcode__c + '"}';
        //}else{
       // requestBody = '{"Nm":"'+jobName+'", "ProjectCode":"'+editedId+'", "ClientId":"'+accountMap.get(AccountId).BigTimeSID__c+'","PrimaryContactId":"'+contactMap.get(contactId).BigTimeSID__c+'"}';  
        //}   // check if there are any other fields I want to send
    }
    if(method == 'JobUpdate'){
        request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/project/detail/'+jobMap.get(jobId).BigTimeSID__c); 
        requestBody = '{"Nm":"'+jobName+'", "ProjectCode":"'+editedId+'"}'; //COME BACK AND FIX
    }
    // if(method == 'ContactInsert'){
    //     if(!String.isEmpty(contactMap.get(contactId).name) || !String.isEmpty(contactMap.get(contactId).firstName) || !String.isEmpty(contactMap.get(contactId).lastName) ){
    //     requestBody = '{"ProjectSid":"'+jobMap.get(jobId).BigTimeSID__c+'", "FullNm":"'+contactMap.get(contactId).name+'", "FName":"'+contactMap.get(contactId).firstname+'", "SName":"'+contactMap.get(contactId).lastname+'"}'; //, "FullAddress":{"FullAddress":"'+ contactMap.get(contactId).mailingAddress+'"}
    //     }
    //     else{
    //     requestBody = '{"ProjectSid":"'+jobMap.get(jobId).BigTimeSID__c+'", "FullNm":"'+contactMap.get(contactId).name+'", "FName":"'+contactMap.get(contactId).name+'"}';   
    //     }
        //if(String.isEmpty(contactMap.get(contactId).firstName)){
        // requestBody = '{"ProjectSid":"'+jobMap.get(jobId).BigTimeSID__c+'", "FullNm":"'+contactMap.get(contactId).name+'", "FName":"NoFirstName", "SName":"'+contactMap.get(contactId).lastname+'", "FullAddress":{"FullAddress":"'+ contactMap.get(contactId).mailingAddress+'"}}';
        // }
        // if(String.isEmpty(contactMap.get(contactId).lastName)){
        // requestBody = '{"ProjectSid":"'+jobMap.get(jobId).BigTimeSID__c+'", "FullNm":"'+contactMap.get(contactId).name+'", "FName":"'+contactMap.get(contactId).firstname+'", "SName":"'+contactMap.get(contactId).lastname+'", "FullAddress":{"FullAddress":"'+ contactMap.get(contactId).mailingAddress+'"}}';    
        // }
        // if(String.isEmpty(contactMap.get(contactId).BillingAddress)){
        // requestBody = '{"ProjectSid":"'+jobMap.get(jobId).BigTimeSID__c+'", "FullNm":"'+contactMap.get(contactId).name+'", "FName":"'+contactMap.get(contactId).firstname+'", "SName":"'+contactMap.get(contactId).lastname+'", "FullAddress":{"FullAddress":"'+ contactMap.get(contactId).mailingAddress+'"}}';   
        //}
      //  request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/project/contact/{'+ jobMap.get(jobId).BigTimeSID__c +'}');
    //}
    // if(method == 'ContactUpdate'){
    //     request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/project/detail/{' + contactMap.get(contactId).BigTimeSID__c +'}'); // change to client & update endpoint
    // }
    request.setMethod('POST');
    system.debug('Endpoint is '+ request);
    system.debug('RequestBody is    ' + requestBody);
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    request.setHeader('X-Auth-Token', token);
    request.setHeader('X-Auth-Realm', firmid);
    system.debug('FirmId is ' + firmId + '       Token is   '+ token);
// Set the body as a JSON object
// we want the project code to be the record Id.. and the name to be Job Name, also Job Name for displayname
// Removing the first 3 digits of the jobId because ProjectCode can only be a max of 15, and we already know the first 3 dig
    request.setBody(requestBody);
    //request.setTimeout(2000);
    system.debug('Request Parameters are : ' + request.getBody());
    HttpResponse response = http.send(request);
    Integer statusCode = response.getStatusCode();
    system.debug(statusCode);
    String body = response.getBody();
    system.debug(body);
// If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {
        system.debug('Response is : ' + response);
        system.debug('Response with get body ' + response.getBody());
        TokenWrapper tokenwrap = (TokenWrapper)JSON.deserialize(body, TokenWrapper.class);
        system.debug('Tokenwrap : ' + tokenwrap);
        if(method == 'AccountInsert'){
            accountMap.get(AccountId).bigTimeSID__c = tokenwrap.SystemId;
            accountMap.get(AccountId).BigTime_Last_Sync__c = system.now();
            accountMap.get(AccountId).BigTime_status__c = string.valueOf(StatusCode);
            //update accountMap.values();
            //if(!String.isEmpty(contactMap.get(contactId).BigTimeSID__c)){
                if(test.isRunningTest()){}
                else{
            PostJobAccountContact(jobName, 'JobInsert', Bigtimeid, jobId, AccountId);
                }
            //}
            // else{
            // PostJobAccountContact(jobName, 'ContactInsert', Bigtimeid, jobId, contactId, AccountId); 
             }
        
        // if(method == 'AccountUpdate'){
        //     accountMap.get(AccountId).bigTimeSID__c = tokenwrap.SystemId;
        //     accountMap.get(AccountId).BigTime_Last_Sync__c = system.now();
        //     accountMap.get(AccountId).BigTime_status__c = string.valueOf(StatusCode);
        //     update accountMap.values();
            
        // }
        if(method == 'JobInsert'){
            jobMap.get(jobId).bigTimeSID__c = tokenwrap.SystemId;
            jobMap.get(jobId).BigTime_Last_Sync__c = system.now();
            jobMap.get(jobId).BigTime_status__c = string.valueOf(StatusCode);
            update accountMap.values();
                 update jobMap.values();
                 system.debug('Done');
                 
            // update jobMap.values();
            //  if(String.isEmpty(contactMap.get(contactId).BigTimeSID__c)){
            //  PostJobAccountContact(jobName, 'ContactInsert', Bigtimeid, jobId, AccountId);
            //  }else{
                 
            //     //string.valueOf(StatusCode);
            //  }
        }
        if(method == 'JobUpdate'){
            //jobMap.get(jobId).bigTimeSID__c = tokenwrap.SystemId;
            jobMap.get(jobId).BigTime_Last_Sync__c = system.now();
            jobMap.get(jobId).BigTime_status__c = string.valueOf(StatusCode);
            update jobMap.values();
            
        }
        // if(method == 'ContactInsert'){
        //     contactMap.get(contactId).bigTimeSID__c = tokenwrap.SystemId;
        //     contactMap.get(contactId).BigTime_Last_Sync__c = system.now();
        //     contactMap.get(contactId).BigTime_status__c = string.valueOf(StatusCode);
        //     update contactMap.values();
        //     update accountMap.values();
        //     update jobMap.values();
        //     //return string.valueOf(StatusCode);
        // }
        // if(method == 'ContactUpdate'){
        //     contactMap.get(contactId).bigTimeSID__c = tokenwrap.SystemId;
        //     contactMap.get(contactId).BigTime_Last_Sync__c = system.now();
        //     contactMap.get(contactId).BigTime_status__c = string.valueOf(StatusCode);
        //     update contactMap.values();
        // }
    

            
        //probably put safeguards to still update the account/contact/job
        
        //return 'Error';
}
    // update contactMap.values();
    // update accountMap.values();
    // update jobMap.values();
   
    
    

}

// public static void GetProject(){
// Map<string,BigTime__c> mapCredentials = BigTime__c.getAll();
//     String token = mapCredentials.get('Bigtime').token__c;
//     String firmId = mapCredentials.get('Bigtime').firmid__c;
// string SystemId = '4465008';
// Http http = new Http();
// HttpRequest request = new HttpRequest();
// request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/project/detail/'+SystemId+'?View={Basic}&{ShowAllContacts=True}');
// request.setMethod('GET');
// request.setHeader('Content-Type', 'application/json;charset=UTF-8');
// request.setHeader('X-Auth-Token', token);
// request.setHeader('X-Auth-Realm', firmId);
// HttpResponse response = http.send(request);
// // If the request is successful, parse the JSON response.
// if (response.getStatusCode() == 200) {
//     // Deserialize the JSON string into collections of primitive data types.
//     system.debug('Getting the project '+ response.getBody());

// }
// }
// @future(callout=true)
// public static void GetInvoices(){
// Map<string,BigTime__c> mapCredentials = BigTime__c.getAll();
// String token = mapCredentials.get('Bigtime').token__c;
// String firmId = mapCredentials.get('Bigtime').firmid__c;
// Http http = new Http();
// HttpRequest request = new HttpRequest();
// request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/invoice/history?startDt=2019-08-01&endDt=2019-09-04');
// request.setMethod('GET');
// request.setHeader('Content-Type', 'application/json;charset=UTF-8');
// request.setHeader('X-Auth-Token', token);
// request.setHeader('X-Auth-Realm', firmId);
// HttpResponse response = http.send(request);
// // If the request is successful, parse the JSON response.
// if (response.getStatusCode() == 200) {
//     // Deserialize the JSON string into collections of primitive data types.
//     String body = response.getBody();
//     system.debug('Getting the project '+ response.getBody());
//     body = '{"Invoices":'+ body;
//     body = body + '}';
//     system.debug('Getting the body after edit  ' + body);
//      TokenWrapper3 tokenwrap = (TokenWrapper3)JSON.deserialize(body, TokenWrapper3.class);
//         system.debug('Tokenwrap : ' + tokenwrap);
//     Set<string> projectIds = new Set<String>();
//     map<String, string> invoiceMap = new map<string, string>();
//     List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
//     Set<Id> invoiceSet = new Set<Id>();
//     for(BigInvoices big : tokenwrap.Invoices){
//             if(!String.isBlank(big.ProjectSid)){
//                 invoiceMap.put(big.ProjectSid, big.Sid);
//                 projectIds.add(big.ProjectSid); 
//             }
//     }
//     List<ATI_Job__c> jobs = [Select Id, ProjectGuid__c, BigTime_Invoice_Created__c FROM ATI_Job__c Where ProjectGuid__c IN:projectIds AND BigTime_Invoice_Created__c = false];
// //remember to update big time invoice created....
//         //jobToUpdate.BigTime_Last_Sync__c = system.now();
//         //jobToUpdate.BigTime_status__c = string.valueOf(StatusCode);
//         //if(Bigtimeid == null){
//         //jobToUpdate.BigtimeSID__c = tokenwrap.SystemId;
//     //I have the jobs, now I need to create the invoices and put the projectSID number on it. Then I need to update the invoices with line items
//     for(ATI_Job__c job : jobs){
//         Invoice__c inv = new Invoice__c(Name = 'BigTime Invoice', ATI_Job__c = job.id, Sid__c = invoiceMap.get(job.projectGuid__c));
//         invoicesToInsert.add(inv);
//     }
//     if(!invoicesToInsert.isEmpty()){
//     insert invoicesToInsert;
//     for(invoice__c i : invoicesToInsert){
//     invoiceSet.add(i.id);
//     }
//     }
//     GetLineItemsForInvoices(invoiceSet);
    
// }
// }
// @future(callout=true)
// public static void GetLineItemsForInvoices(Set<Id> invoiceIds){
// List<Invoice__c> invoices = [Select Id FROM Invoice__c Where id =: invoiceIds];
// Map<string,BigTime__c> mapCredentials = BigTime__c.getAll();
// String token = mapCredentials.get('Bigtime').token__c;
// String firmId = mapCredentials.get('Bigtime').firmid__c;
// string SID = '4429123';
// Http http = new Http();
// HttpRequest request = new HttpRequest();
// request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/invoice/detail/4283088');
// request.setMethod('GET');
// request.setHeader('Content-Type', 'application/json;charset=UTF-8');
// request.setHeader('X-Auth-Token', token);
// request.setHeader('X-Auth-Realm', firmId);
// HttpResponse response = http.send(request);
// // If the request is successful, parse the JSON response.
// if (response.getStatusCode() == 200) {
//      String body = response.getBody();
//     system.debug('Getting the project '+ response.getBody());
//      TokenWrapper3 tokenwrap = (TokenWrapper3)JSON.deserialize(body, TokenWrapper3.class);
//         system.debug('Tokenwrap : ' + tokenwrap);
//     // Deserialize the JSON string into collections of primitive data types.
//     //system.debug('Getting the project '+ response.getBody());

// }
// }
//     public class BigInvoices{
//         //public String ProjectSID {get;set;}
//         public String Sid {get;set;}
//         public String ProjectSid {get;set;}
//         public String SystemId {get;set;}
//     }
//     public class Random3TokenWrapperException extends Exception{
//     }

// @future(callout=true)
// public static void CreateInvoice(){
// Map<string,BigTime__c> mapCredentials = BigTime__c.getAll();
//     String token = mapCredentials.get('Bigtime').token__c;
//     String firmId = mapCredentials.get('Bigtime').firmid__c;
// string SystemId = '4465026';
// Http http = new Http();
// HttpRequest request = new HttpRequest();
// request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/invoice/create?projectSid=4465008&invoiceType=0');
// request.setMethod('POST');
// request.setHeader('Content-Type', 'application/json;charset=UTF-8');
// request.setHeader('X-Auth-Token', token);
// request.setHeader('X-Auth-Realm', firmId);
// HttpResponse response = http.send(request);
// // If the request is successful, parse the JSON response.
// if (response.getStatusCode() == 200) {
//     // Deserialize the JSON string into collections of primitive data types.
//     system.debug('Getting the project '+ response.getBody());

// }
// }
// @future(callout=true)
// public static void GetInvoiceSpecifics(){
// Map<string,BigTime__c> mapCredentials = BigTime__c.getAll();
//     String token = mapCredentials.get('Bigtime').token__c;
//     String firmId = mapCredentials.get('Bigtime').firmid__c;
// string SID = '4429123';
// Http http = new Http();
// HttpRequest request = new HttpRequest();
// request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/invoice/detail/4465008');
// request.setMethod('GET');
// request.setHeader('Content-Type', 'application/json;charset=UTF-8');
// request.setHeader('X-Auth-Token', token);
// request.setHeader('X-Auth-Realm', firmId);
// HttpResponse response = http.send(request);
// // If the request is successful, parse the JSON response.
// if (response.getStatusCode() == 200) {
//      String body = response.getBody();
//     system.debug('Getting the project '+ response.getBody());
//      TokenWrapper3 tokenwrap = (TokenWrapper3)JSON.deserialize(body, TokenWrapper3.class);
//         system.debug('Tokenwrap : ' + tokenwrap);
//     // Deserialize the JSON string into collections of primitive data types.
//     //system.debug('Getting the project '+ response.getBody());

// }
// }
// @AuraEnabled 
//     public static string forceBigTimeCalloutSync(String recordId){
//         String method;
//         ATI_Job__c job = [Select Id, division__c, Name, BigTimeSid__c, stage__c FROM ATI_Job__c WHERE Id =: recordId];
        // if(job.BigTimeSId__c != null && job.stage__c == 'Won'){
        //     method = updateMethod;
        //     PostJob(job.division__c, job.id, job.name, method, job.BigtimeSID__c);
        //     return 'Updated Project in Bigtime. You May Now Close the Popup';
        // }
        // if(job.BigtimeSID__c == null && job.stage__c == 'Won'){
        //     method = newProject;
        //     PostJob(job.division__c, job.id, job.name, method, job.BigtimeSID__c);
        //     return 'Created New Project in Bigtime. You May Now Close the Popup';
        // }
        // if(job.stage__c != 'Won'){
        //     return 'Stage is not Won, please change before syncing';
        // }
        // else{
        //     return 'Error, Please contact your Salesforce Administrator';
    //     // }
    //     return 'test';
    // }



@future(callout=true)
    public static void resetCredentials(){
    system.debug('maybe working');
    Map<string,Bigtime__c> mapCredentials = Bigtime__c.getAll();
    system.debug('mapCredentials : '+ mapCredentials);
    String UserId = mapCredentials.get('Bigtime').userId__c;
    String Pwd = mapCredentials.get('Bigtime').Pwd__c;
    system.debug('mapCredentials : '+ mapCredentials);
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://iq.bigtime.net/BigTimeData/api/v2/session');
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //Bigtime__c bt = 
// Set the body as a JSON object
    string body = '{"UserId":"'+UserId+'" , "Pwd":"'+Pwd+'"}';
    request.setBody(body);
    //request.setTimeout(2000);
    system.debug('Request Parameters are : ' + request.getBody());
    HttpResponse response = http.send(request);
    Integer statusCode = response.getStatusCode();
    String bodyresponse = response.getBody();
// If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {
        system.debug('Response is : ' + response);
        system.debug('Response with get body ' + response.getBody());
        string body1;
        TokenWrapper tokenwrap = (TokenWrapper)JSON.deserialize(bodyresponse, TokenWrapper.class);
        system.debug('Token Wrap is ' + tokenwrap);
        system.debug('Token Value is ' + tokenwrap.token);
        system.debug('Firm Value is ' + tokenwrap.firm);
         if(tokenwrap != null){
             //Map<string,BigTime__c> mapBigtime = BigTime__c.getAll();
             Bigtime__c b= [Select Id, token__c, firmId__c FROM Bigtime__c Where name='Bigtime'];
             b.token__c = tokenwrap.token;
             b.firmid__c = tokenwrap.firm;
             update b;
             
         //PostJob(tokenwrap.token , tokenwrap.firm, division, jobId, jobName, method, Bigtimeid);
     }
    }else{
        throw new RandomTokenWrapperException ('Could not access the API. Status:' + StatusCode);

    }
    
    }
     public class TokenWrapper{
        public String token {get;set;}
        public String firm {get;set;}
        public String SystemId {get;set;}
    
    }
    public class RandomTokenWrapperException extends Exception{
    }

}