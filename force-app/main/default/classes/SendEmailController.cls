public with sharing class SendEmailController {
    public Invoice__c invoice {get; set;}
    public String currentUserEmail { get; set; }   
    public String emailBody { get; set; }
    public String subject { get; set; }
    public Task emailTask { get; set; }
    public string additionalToAddress{ get; set; }
	public string bccAddress{ get; set; }
    public string ccAddress{ get; set; }    
    public List<Attachment> attachments { get; set; }
    
    EmailTemplate template;
    
    public SendEmailController( ApexPages.StandardController controller ){
        invoice = ( Invoice__c ) controller.getRecord();    
        
        Id attachmentId = (Id) ApexPages.currentPage().getParameters().get('attachmentId');
        emailTask = new Task();        
        currentUserEmail = Userinfo.getUserEmail();
        invoice = [ SELECT Id, Name, RecordType.DeveloperName, Bill_To__c, Bill_To__r.Name,Bill_To_Attention_Lookup__c
                  FROM Invoice__c 
                  WHERE Id =: invoice.Id ];       
        emailTask.WhoId = invoice.Bill_To_Attention_Lookup__c;
        
        template = [ SELECT Id, DeveloperName, Body 
                     FROM EmailTemplate WHERE DeveloperName = 'Invoice_Template_New' ];  

        attachments = [ SELECT Id, Name, bodylength, body FROM Attachment WHERE Id =: attachmentId];
    }
    
    public PageReference generateEmailBody(){
        Contact cnt = [select id, Email from Contact where email != null limit 1];
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId( template.id );
        msg.setWhatId( invoice.Id );
        subject = invoice.Bill_To__r.Name + ' : ' + invoice.Name;
        Savepoint sp = Database.setSavepoint();
        msg.setTargetObjectId( cnt.Id );        
        msg.setSaveAsActivity(false);
        Messaging.sendEmail( new List<Messaging.SingleEmailMessage> { msg } );
        Database.rollBack( sp );
        emailBody = msg.getHTMLBody();
        if( emailBody == null || emailBody == '' ){
            emailBody = msg.getPlainTextBody();
        }
        system.debug(emailBody);
        return null;
    }
    
    public PageReference sendEmail(){
        Savepoint sp = Database.setSavepoint();
        try{
            if( emailTask.whoId == null ){
                Apexpages.addMessage( new ApexPages.message( ApexPages.Severity.WARNING, 'To Address is required'  ) );                
                return null;    
            }
            List<Contact> contacts = [ SELECT Id, Email FROM Contact WHERE Id =: emailTask.WhoId ];
            string[] toAddresses = new String[]{};
            if( !contacts.isEmpty() ){
                toAddresses.add(contacts[0].Email);
            }
            string[] ccAddresses;
            if( ccAddress != null && ccAddress != '' ){
                for( String cc : ccAddress.split(',') ){
                    ccAddresses.add( cc );
                }
            }
            string[] bccAddresses;
            if( bccAddress != null && bccAddress != '' ){
                for( String cc : bccAddress.split(',') ){
                    bccAddresses.add( cc );
                }
            }
            system.debug( toAddresses );
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();       
            msg.setHtmlBody(emailBody);
            msg.setWhatId( invoice.Id );
            
            msg.setToAddresses( toAddresses );
            msg.setBccAddresses( bccAddresses );
            msg.setCCAddresses( ccAddresses );
            msg.setSaveAsActivity( true );
            msg.setSubject( subject );
            for ( Attachment a : attachments ){                
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName( a.Name );
                efa.setBody( a.Body );
                fileAttachments.add(efa);
                
            }
            msg.setFileAttachments(fileAttachments);
            Messaging.sendEmail( new List<Messaging.SingleEmailMessage> { msg } );
        }catch( Exception ex ){
            Database.rollBack( sp );
            Apexpages.addMessage( new ApexPages.message( ApexPages.Severity.ERROR, 'There was an error sending email'  ) );
            system.debug( ex.getMessage() );
            return null;
        }
        return new PageReference( '/' + invoice.Id );
    }
    
    public PageReference cancel(){
        return new PageReference( '/' + invoice.Id );
    }
}