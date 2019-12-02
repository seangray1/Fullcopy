@isTest
public class PRLDE_ATIJobEmailTest{

@isTest
public static void EmailHandlerTest(){

  // create a new email and envelope object
  Messaging.InboundEmail email = new Messaging.InboundEmail() ;
  Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

  // setup the data for the email
  email.subject = 'Test Email Subject ATI';
  email.PlainTextBody = 'From:'+ '\n'+
  'The Hartford Adj Ref -CC'+'\n'+
  
  'To:'+'\n'+

'American Technologies, Inc. - Phoenix'+'\n'+

'Assignment Profile:'+'\n'+

'Type:   Normal'+'\n'+


'Policy Type:   Homeowner'+'\n'+


'Policy Number:  55RBE809528'+ '\n'+

                 'Dwelling ($163000)'+'\n'+

'Policy Limits:   Contents ($114100)'+'\n'+

                 'Other Structures ($16300)'+'\n'+

'Claim Rep: Qiana Young'+'\n'+

'Date of Loss:  01/14/2019'+ '\n'+


'Claim Number:  PP0018184614'+ '\n'+


'Insured Name:THEODORE JOHN CLARK'+ '\n'+

'CR Name:John Billgram'+'\n' +
      
'CR Phone #: 123456789' + '\n'+

'Day Phone:  (623) 213-7279'+ '\n'+


'Mobile Phone:  (623) 229-1387'+ '\n'+


'Type of Loss:  WIND DAMAGE'+ '\n'+


'Property Access Name: THEODORE JOHN CLARK'+ '\n'+


'Property Access Phone:  (623) 213-7279'+ '\n'+

'XA ID:  03KGK83'+ '\n'+

'Property Location: 11412 W PUGET AVE, PEORIA, AZ 85345  Google Maps  MapQuest'+'\n'+

                    '33.564893º N, 112.305348º W'+'\n'+


'Instructions:'+'\n'+

'From: The Hartford -  Outside Staff'+'\n'+
 
'ASSIGNMENT PROFILE:'+'\n'+
'Type: Normal'+'\n'+
'Claim Rep: '+'\n'+
'Claim Number:  PP0018184614'+ '\n'+
'Insured Name:THEODORE JOHN CLARK'+'\n'+
'Day Phone: (623) 213-7279'+'\n'+
'Evening Phone: (000) 000-0000'+'\n'+
 
'Type of Loss: Wind Damage'+'\n'+
'Job Type: General'+'\n'+
'Location of Property: 11412 W PUGET AVE, PEORIA, AZ 85345'+'\n'+
 
'Instructions:'+'\n'+
'Summary of Assignment '+'\n'+
      
'Main Contact: THEODORE JOHN CLARK'+'\n'+
 
 'Day phone: 623-213-7279'+'\n'+
      
 
 'Mobile: 623-229-1387'+'\n'+
 
 'Primary: 623-213-7279  |'+'\n'+
 
 'Reporter: THEODORE JOHN CLARK'+'\n'+
      
  'Loss Description: Test Value' + '\n' + 
        
 'Desk Adjuster: Test Value' + '\n' + 
        
  'Adjuster Office Phone: Test Value' + '\n' + 
        
   'Third Party Name: Test Value' + '\n' + 
 
 'Day phone: 623-213-7279'+'\n'+
 
 'Mobile:  623-229-1387'+'\n'+
 
 'Primary: 623-213-7279  |'+'\n'+
      
 
 'Policy Type: HO0003  |'+'\n'+
 
 'Policy Deductibles:  Dwelling  - 1000.00 usd  |  Contents  - 1000.00 usd  |  Other Structures  - 1000.00 usd  |'+'\n'+
 
 'Name of claim rep: Qiana Young |'+'\n'+
 
 'Business Phone: 800-843-7006 x2303367 |'+'\n'+
 
 'E-mail address of insured: rangertjc9634@yahoo.com |'+'\n'+
      
  'Project Site Contact Name: THEODORE JOHN CLARK'+'\n' +
 
 'Writing company: Trumbull Insurance Company |' + '\n'+
 
 'Dates:'+'\n'+
      
 'Assignment Received by XactAnalysis:'+'\n'+

 '01/16/2019 09:06PM GMT'+'\n'+

 'Notification Sent:'+'\n'+ 

 '01/16/2019 02:06PM MT';
 
  env.fromAddress = 'test@preludesys.com';
  
    TestDataUtil.createCustomSettings_TriggerStatus();
    
  //create Account
  
   Account acc = new Account();
   acc.Name = 'ES Job Account';
   acc.Type = 'Property Owner';
   acc.BillingStreet = '123 AS Street';
   acc.BillingCity = 'New York';
   acc.BillingState = 'NY';
   acc.Billingpostalcode = '34567';
   acc.BillingCountry = 'USA';
   insert acc;
   
   // add an Binary attachment
  
  Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
  attachment.body = blob.valueOf('my attachment text');
  attachment.fileName = 'textfileone.txt';
  attachment.mimeTypeSubType = 'text/plain';
  email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
   
  
  // call the email service class and test it with the data in the testMethod
  PRLDE_ATIJobEmail jobEmail = new PRLDE_ATIJobEmail();
  jobEmail.handleInboundEmail(email, env);
  Test.startTest();
  email.PlainTextBody = 'Test';
  
  try{
  
  jobEmail.handleInboundEmail(email, env);
  
  }
  
  catch(Exception e){
  
  }
  
  email.PlainTextBody = 'From:'+ '\n'+
  
  'The Hartford Adj Ref -CC'+'\n'+
  
  'To:'+'\n'+

'Preludesys Technologies, Inc. - California'+'\n'+

'Assignment Profile:'+'\n'+

'Type:   Normal'+'\n'+

'Date of Loss: 07/04/2018' + '\n' +

'Member Number: 002266838, Loss Report Number: 023' + '\n' +

'Member Name: SMITH, LYNN'+'\n' +
      
'CR Name:John Billgram'+'\n' +
      
'CR Phone #: 123456789' + '\n'+

'Evening Phone: (858) 312-1021' + '\n' +

'Mobile Phone: (858) 705-0672' + '\n' +

'Email Address:dses321@yahoo.com' + '\n' +

'Type of Loss: WTR-PLB' +'\n' +

'XA ID: 03CGTZJ' + '\n' +

'Location of Property: 16218 Pinto Ridge Dr, San Diego, CA 92127' + '\n' +

'33.006475º N, 117.118871º W' + '\n' +

'Instructions:'+'\n'+
'Summary of Assignment '+'\n'+
      
 'Project Site Contact Name: The Hartford Adj'+'\n' +

'Dates:'+'\n'+

 'Assignment Received by ActAnalysis:';
 
   try{
   
   jobEmail.handleInboundEmail(email, env);
   
   }
   
   catch(Exception e){
   
   }
   
   
    email.PlainTextBody = 'From:'+ '\n'+
  
  'The Hartford Adj Ref -CC'+'\n'+
  
  'To:'+'\n'+

'Preludesys America, Inc. - SanFrancisco'+'\n'+

'Assignment Profile:'+'\n'+

'Type:   Normal'+'\n'+

'Date of Loss: 07/04/2018' + '\n' +


'CR Name:John Billgram'+'\n' +

'CR Phone #: (858) 312-1021' + '\n' +
        
 'Member Name: Test ,SF ' + '\n' +

'Mobile Phone: (858) 705-0672' + '\n' +

'Email Address:dses321@yahoo.com' + '\n' +
        
 'Project Site Contact Name: The Hartford Adj Ref'+'\n' +

'Type of Loss: WTR-PLB' +'\n' +

'XA ID: 03CGTZJ' + '\n' +
        
 'Desk Adjuster: Test Value' + '\n' + 
        
  'Adjuster Office Phone: Test Value' + '\n' + 
        
   'Third Party Name: Test Value' + '\n' + 

'Location of Property: 16218 Pinto Ridge Dr, San Diego, CA 92127' + '\n' +

'33.006475º N, 117.118871º W' + '\n' +

'Instructions:'+'\n'+
'Summary of Assignment '+'\n'+

'Dates:'+'\n'+

 'Assignment Received by ActAnalysis:';
 
   try{
   
   jobEmail.handleInboundEmail(email, env);
   
   }
   
   catch(Exception e){
   
   }

  Test.stopTest();

  }

}