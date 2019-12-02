public with sharing class EmailInvoice
{   
    private Set<Id> AttachmentIds;
    
    private String id = ApexPages.currentPage().getParameters().get('id');
       
    public string SelectedFolder {get;set;}
   
 
    public List<FileInfo> listFileObj {get;set;}
    
    public string ParentId {get;set;}
    
    public string ActivityStatus {get;set;}
    
    public string HideAttachmentType {get;set;}
    public string HideActivityStatus {get;set;}
       
    public EmailInvoice()
    {   
        try{
            FolderId = UserInfo.getUserId();
            HideAttachmentType = 'NO';
            HideActivityStatus = 'NO';

            if(ApexPages.currentPage().getParameters().get('id') != null){
                ParentId = ApexPages.currentPage().getParameters().get('id');   
            }
            system.debug('ParentId----'+ParentId);
            for(Invoice__c i : [Select Id,Bill_To__c,CC_Account__c From Invoice__c  Order By LastModifiedDate DESC Limit 1 ]){

                for(Contact c : [Select Email,Id,Name From Contact Where AccountId = : i.Bill_To__c AND Email != null Order By LastModifiedDate DESC Limit 1]){
                    AdditionalToNames = c.Name;
                    AdditionalToEmails = c.Email;
                    AdditionalToContactIds = c.Id;
                }
                
                for(Contact c : [Select Email,Id,Name From Contact Where AccountId = : i.CC_Account__c AND Email != null Order By LastModifiedDate DESC Limit 1]){
                    AdditionalToNamesCC = c.Name;
                    AdditionalToEmailsCC = c.Email;
                    AdditionalToContactIdsCC = c.Id;
                }
            }
            
            if(ApexPages.currentPage().getParameters().get('HideAttachmentType') != null){
                HideAttachmentType = ApexPages.currentPage().getParameters().get('HideAttachmentType');   
            }
            
            if(ApexPages.currentPage().getParameters().get('HideActivityStatus') != null){
                HideActivityStatus = ApexPages.currentPage().getParameters().get('HideActivityStatus');   
            }
            
            SelectedFolder = UserInfo.getOrganizationId();
            showContents = true;
            
            listFileObj = new List<FileInfo>();
            for(integer i=0; i<3;i++){
                FileInfo fi = new FileInfo();
                listFileObj.add(fi);
            }
            
            if(id instanceOf Id)
            {
                showAttachment = true;
                ObjectId = id;
                isShowTemplate = false;
                BccMe = false;
                 
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Parameter is wrong.'));
            }
            
            ActivityStatus = 'Completed';
            
            
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        } 
         
    }
     
      
    public Contact Contact { set; get; }
     
    public String Subject { set; get; }
    
    public String Content { set; get; }
    
    public String CarbonCopy { set; get; }
    
    public String ToCopy { set; get; }
    
    public String ContactNames { set; get; }
    
    public String ContactEmails { set; get; }
    
    public String AdditionalToNames { set; get; }
    
    public String AdditionalToEmails { set; get; }
     
    public String AdditionalToContactIds { set; get; }
    
     public String AdditionalToNamesCC { set; get; }
     
    public String AdditionalToEmailsCC { set; get; }
     
    public String AdditionalToContactIdsCC { set; get; }
    
    public String AttachmentNames { set; get; }
    
    public String ForSendAttachmentIds { set; get; }
    
    public String ForSendAttachmentNames { set; get; }
    
    public String ForSendDocumentIds { set; get; }
    
    public String ForSendDocumentNames { set; get; }

    public String ForSendContentIds { set; get; }
    
    public String ForSendContentNames { set; get; }
        
    public Boolean BccMe { set; get; }
    
    public Boolean showAttachment { set; get; }
    
    public String Type { set; get; }
    
    public String TemplateId { set; get; }
    
    public String ObjectId { set; get; }
    
    public Boolean isShowTemplate { set; get; }
    
    public EmailTemplate ForSendTemplate { set; get; }
    
    public string DocumenterSearchQuery {get;set;}
    public string FolderId {get;set;}
    
    public string WorkSpaceId {get;set;}
    
     public List<SelectOption> getAllActivityStatus() {
        List<SelectOption> options = new List<SelectOption>();
         
        Schema.DescribeFieldResult fieldResult =  Task.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)
        {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
      }
      
      
      public List<SelectOption> getDocFolders() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(UserInfo.getUserId(),'My Personal Documents'));
        options.add(new SelectOption( '', 'All Documents'));
        for(Folder f: [Select f.Type, f.Name, f.Id, f.DeveloperName From Folder f Where f.Type = 'Document' Order By Name Limit 1000]){
            options.add(new SelectOption(f.Id,f.Name)); 
        } 
        
        return options;
      }
      
      public List<SelectOption> getWorkSpace() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '', 'All Libraries'));
        for(ContentWorkspace f: [Select c.Name, c.Id From ContentWorkspace c  Order By Name Limit 1000]){
            options.add(new SelectOption(f.Id,f.Name)); 
        } 
        
        return options;
      }
      
      
       //builds a picklist of values based upon the passed information
    public List<selectOption> getAttachmentTypes() {
        list<SelectOption> options = new list<SelectOption>();
        try{
         // Get the object type of the SObject.
          Schema.sObjectType objType = Task.getSObjectType(); 
          // Describe the SObject using its object type.
          Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
          // Get a map of fields for the SObject
          map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
          // Get the list of picklist values for this field.
          list<Schema.PicklistEntry> values = fieldMap.get('CRMG_EmailAtt__Attachment_Type__c').getDescribe().getPickListValues();
          // Add these values to the selectoption list.
          for (Schema.PicklistEntry a : values)
          { 
             options.add(new SelectOption(a.getLabel(), a.getValue())); 
          }
        }
        catch(Exception ee){ 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFo, ee.getMessage() ));
                }  
      return options;
   }
   
    
    public Boolean showContents { get; set; }
    public String ContentSearchQuery { get; set; }
    public List<ContentVersion> Contents
    {
        get
        {
            List<ContentVersion> cons;
            try
            {
                showContents = true;
                
                if(WorkSpaceId != null && WorkSpaceId != ''){
                    
                    SET<ID> setDocId = new SET<ID>();
                    for(ContentWorkspaceDoc cwd: [Select c.ContentWorkspaceId, c.ContentDocumentId From ContentWorkspaceDoc c Where ContentWorkspaceId =: WorkSpaceId]){
                        setDocId.add(cwd.ContentDocumentId);
                    }
                    
                    if(ContentSearchQuery != null && ContentSearchQuery != '')
                    {
                        string strQ = '%' + ContentSearchQuery + '%';
                        cons = [Select PathOnClient, VersionNumber, FileType, PublishStatus, Owner.Name, Id,  Description, ContentUrl, ContentSize From ContentVersion where ContentDocumentId IN:setDocId AND IsDeleted = false and PathOnClient like :strQ order by PathOnClient];
                    }
                    else
                    {
                        cons = [Select PathOnClient, VersionNumber, FileType, PublishStatus, Owner.Name, Id,  Description, ContentUrl, ContentSize From ContentVersion where  ContentDocumentId IN:setDocId AND IsDeleted = false order by PathOnClient Limit 1000];
                    }
                }
                else{
                    if(ContentSearchQuery != null && ContentSearchQuery != '')
                    {
                        string strQ = '%' + ContentSearchQuery + '%';
                        cons = [Select PathOnClient, VersionNumber, FileType, PublishStatus, Owner.Name, Id,  Description, ContentUrl, ContentSize From ContentVersion where IsDeleted = false and PathOnClient like :strQ order by PathOnClient ];
                    }
                    else
                    {
                        cons = [Select PathOnClient, VersionNumber, FileType, PublishStatus, Owner.Name, Id,  Description, ContentUrl, ContentSize From ContentVersion where IsDeleted = false order by PathOnClient Limit 1000];
                    }
                }
                
                return cons;
            }
            catch(Exception ex)
            {
                showContents = false;
            }
            return null;
        }
        set;
    }
    
    public List<AttachmentInfo> AttachmentInfos
    {
        get
        {
            List<AttachmentInfo> AttachmentInfos = new List<AttachmentInfo>();
            
            if(id instanceOf Id)
            {
                Set<Id> userIds = new Set<Id>();
                Map<Id, String> UserNames = new Map<Id, String>();
                Set<Id> allRelatedIds = new Set<Id>();
                allRelatedIds.add(id);
                 
                
                for(Attachment att : [select Id, Name, LastModifiedById, CreatedById from Attachment where ParentId in :allRelatedIds order by Name  desc])
                {
                    userIds.add(att.LastModifiedById);
                    userIds.add(att.CreatedById);
                }
                
                 try{
                    
                    string strQryFeed = 'Select  Id, ContentType, ContentFileName,CreatedById From UserProfileFeed Where Type = \'ContentPost\' AND ParentId = \'' + id + '\'  WITH UserId = \'' + UserInfo.getUserId() + '\'  Limit 400';
                    
                    for(SObject sObj :  database.query(strQryFeed) )
                    { 
                        userIds.add(string.valueof(sObj.get('CreatedById'))); 
                    }
            
                } catch(System.RequiredFeatureMissingException e){
                    system.debug(e.getMessage()); 
                }
                catch(Exception ee){
                    system.debug(ee.getMessage()); 
                }
                
                for(User user : [select Id, FirstName, LastName from User where Id in :userIds])
                {
                    UserNames.put(user.Id, user.FirstName + ' ' + user.LastName);
                }
                
                AttachmentInfo info;
                for(Attachment att : [select Id, Name, LastModifiedById, CreatedById from Attachment where ParentId in :allRelatedIds order by Name asc])
                {
                    info = new AttachmentInfo();
                    info.AttachmentId = att.Id;
                    info.AttachemntName = att.Name;
                    info.AttachmentType = 'Attachment';
                    info.LastModifiedBy = UserNames.get(att.LastModifiedById);
                    info.CreatedBy = UserNames.get(att.CreatedById);
                    AttachmentInfos.add(info);
                }   
                
                try{
                    
                    string strQryFeed = 'Select  Id, ContentType, ContentFileName,CreatedById From UserProfileFeed Where Type = \'ContentPost\' AND ParentId = \'' + id + '\'   WITH UserId = \'' + UserInfo.getUserId()  + '\'  Limit 400 ';
                 
                    for(SObject sObj :  database.query(strQryFeed) )
                    {
                        info = new AttachmentInfo();
                        info.AttachmentId = string.valueof(sObj.get('Id'));
                        info.AttachemntName = string.valueof(sObj.get('ContentFileName'));
                        info.LastModifiedBy = UserNames.get(string.valueof(sObj.get('CreatedById')));
                        info.CreatedBy = UserNames.get(string.valueof(sObj.get('CreatedById')));
                        info.AttachmentType = 'Feed Attachment';
                        AttachmentInfos.add(info);
                    }
            
                } catch(System.RequiredFeatureMissingException e){
                    system.debug(e.getMessage()); 
                }
                catch(Exception ee){
                    system.debug(ee.getMessage()); 
                }
                
            }
            return AttachmentInfos;
        }
        set;
    }
    
    
    public List<Document> Documents
    {
        get
        {
            List<Document> Documents = new List<Document>();
            
            if(FolderId != null && FolderId != ''){
                if(DocumenterSearchQuery != null && DocumenterSearchQuery != ''){
                    string strQ = '%' + DocumenterSearchQuery + '%';
                    Documents = [Select d.Type, d.Name, d.Id, d.DeveloperName, d.Description From Document d 
                                Where FolderId = :FolderId AND Name LIKE:DocumenterSearchQuery Order By d.Name ASC Limit 1000];
                }
                else{
                    Documents = [Select d.Type, d.Name, d.Id, d.DeveloperName, d.Description From Document d 
                                Where FolderId = :FolderId  Order By d.Name ASC Limit 1000];
                }
            }
            else{
                if(DocumenterSearchQuery != null && DocumenterSearchQuery != ''){
                    string strQ = '%' + DocumenterSearchQuery + '%';
                    Documents = [Select d.Type, d.Name, d.Id, d.DeveloperName, d.Description From Document d 
                                Where  Name LIKE:DocumenterSearchQuery Order By d.Name ASC Limit 1000];
                }
                else{
                    Documents = [Select d.Type, d.Name, d.Id, d.DeveloperName, d.Description From Document d 
                                 Order By d.Name ASC Limit 1000];
                }
            }
             
            return Documents;
        }
        set;
    }
    
    
    public List<EmailTemplate> EmailTemplates
    {
        get
        {   
            if(SelectedFolder == null || SelectedFolder == ''){
                SelectedFolder = UserInfo.getOrganizationId();
            }
            
            return [select Id, Name, Subject, TemplateType, Description, Body from EmailTemplate where IsActive = true AND FolderId = : SelectedFolder  limit 100];
        }
    }
    
    public PageReference DoNothing(){
        return null;
    }

    public PageReference save()
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string strAllEmails = '';
       

        if(AdditionalToEmails != null && AdditionalToEmails != ''){
            if(strAllEmails != ''){
                strAllEmails = strAllEmails + ',';
            }
            strAllEmails = strAllEmails + AdditionalToEmails;
        }
        
        if(ToCopy != null && ToCopy != ''){
            ToCopy = ToCopy.replace(';', ',');
            if(strAllEmails != ''){
                strAllEmails = strAllEmails + ',';
            }
            strAllEmails = strAllEmails + ToCopy;
        }
        
        
        if(strAllEmails.contains(','))
        {
            email.setToAddresses(strAllEmails.split(','));
        }
        else if(strAllEmails.contains('@'))
        {
            email.setToAddresses(new String[] { strAllEmails });
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid contact or email address, please input correct email address.'));
            return null;
        }
        
        string strAllEmailsCC = '';
       

        if(AdditionalToEmailsCC != null && AdditionalToEmailsCC != ''){
            if(strAllEmailsCC != ''){
                strAllEmailsCC = strAllEmailsCC + ',';
            }
            strAllEmailsCC = strAllEmailsCC + AdditionalToEmailsCC;
        }
        
        if(CarbonCopy != null && CarbonCopy != '')
        {   
            CarbonCopy = CarbonCopy.replace(' ', '');
             
            if(strAllEmailsCC != ''){
                strAllEmailsCC = strAllEmailsCC + ',';
            }
            strAllEmailsCC = strAllEmailsCC + CarbonCopy;
        }
        
        if(strAllEmailsCC != null && strAllEmailsCC != ''){
            
             List<string> lstCCopy = new List<string>();
             for(string ssCC1: strAllEmailsCC.split(',')){
                for(string ssCC2: ssCC1.split(';')){
                    lstCCopy.add(ssCC2);
                }
             }
            
            email.setCcAddresses( lstCCopy );
        }
        
        if(BccMe)
        {
            User user = [select Email from User where Id = :UserInfo.getUserId()];
            email.setBccAddresses( new String[] { user.Email } );
        }

        
            email.setSubject(Subject);
            email.setHtmlBody(Content);
        
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        Messaging.EmailFileAttachment mailAttachment;
        
        Set<Id> attachIds = new Set<Id>();
        if(ForSendAttachmentIds != null && ForSendAttachmentIds != '')
        {
            if(ForSendAttachmentIds.contains(','))
            {
                for(String attid : ForSendAttachmentIds.split(','))
                {
                    attachIds.add(attid);
                }
            }
            else if(ForSendAttachmentIds.length() == 18)
            {
                attachIds.add(ForSendAttachmentIds);
            }
        }
        
        string AllFileAttachmentName = '';
        
        for(Attachment att : [select Name, Body from Attachment where Id in :attachIds])
        {
            mailAttachment = new Messaging.EmailFileAttachment();
            mailAttachment.setFileName(att.Name);
            mailAttachment.setBody(att.Body);
            attachments.add(mailAttachment);
            
            if(AllFileAttachmentName != ''){
                AllFileAttachmentName = AllFileAttachmentName + ',';
            }
            AllFileAttachmentName = AllFileAttachmentName + att.Name;
        }
        
        try{
                    
            string strQryFeed = 'Select  Id, ContentFileName,ContentData From UserProfileFeed Where  Id IN: attachIds  WITH UserId = \'' + UserInfo.getUserId() + '\'  Limit 100';
            
            for(SObject sObj :  database.query(strQryFeed) )
            {
 
                mailAttachment = new Messaging.EmailFileAttachment();
                mailAttachment.setFileName(string.valueof(sObj.get('ContentFileName')));
                mailAttachment.setBody((blob) sObj.get('ContentData' ));
                attachments.add(mailAttachment);
                
                if(AllFileAttachmentName != ''){
                    AllFileAttachmentName = AllFileAttachmentName + ',';
                }
                AllFileAttachmentName = AllFileAttachmentName + string.valueof(sObj.get('ContentFileName'));
                
            }
    
        } catch(System.RequiredFeatureMissingException e){
            system.debug(e.getMessage()); 
        }
        catch(Exception ee){
            system.debug(ee.getMessage()); 
        }
        
        
        Set<Id> docIds = new Set<Id>();
        if(ForSendDocumentIds != null && ForSendDocumentIds != '')
        {
            if(ForSendDocumentIds.contains(','))
            {
                for(String attid : ForSendDocumentIds.split(','))
                {
                    docIds.add(attid);
                }
            }
            else if(ForSendDocumentIds.length() == 18)
            {
                docIds.add(ForSendDocumentIds);
            }
        }
        
        for(Document att : [select Name,Type, Body from Document where Id in :docIds])
        {
            mailAttachment = new Messaging.EmailFileAttachment();
            mailAttachment.setFileName(att.Name + '.' + att.Type);
            mailAttachment.setBody(att.Body);
            attachments.add(mailAttachment);
            
            if(AllFileAttachmentName != ''){
                AllFileAttachmentName = AllFileAttachmentName + ',';
            }
            AllFileAttachmentName = AllFileAttachmentName + att.Name;
        }
        
        Set<Id> contentIds = new Set<Id>();
        if(ForSendContentIds != null && ForSendContentIds != '')
        {
            if(ForSendContentIds.contains(','))
            {
                for(String conid : ForSendContentIds.split(','))
                {
                    contentIds.add(conid);
                }
            }
            else if(ForSendContentIds.length() == 18)
            {
                contentIds.add(ForSendContentIds);
            }
        }
        
        for(ContentVersion cv : [Select PathOnClient, VersionData From ContentVersion where Id in :contentIds])
        {
            mailAttachment = new Messaging.EmailFileAttachment();
            mailAttachment.setFileName(cv.PathOnClient);
            mailAttachment.setBody(cv.VersionData);
            attachments.add(mailAttachment);
            
            if(AllFileAttachmentName != ''){
                AllFileAttachmentName = AllFileAttachmentName + ',';
            }
            AllFileAttachmentName = AllFileAttachmentName + cv.PathOnClient;
        }
        
        if(attachments.size() > 0)
        {
            email.setFileAttachments(attachments);
        }
        
        try
        {   
            if(Test.isRunningTest() == false){
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Send email error, please check the input content.'));
            system.debug('==========' + ex.getMessage() );
            return null;
        }
            
            SET<Id> setConId = new SET<ID>();
            
            if(AdditionalToContactIds != null && AdditionalToContactIds != ''){ 
                List<string> lstConIds = AdditionalToContactIds.split(',');
                for(Contact c : [Select Id From Contact Where Id IN: lstConIds]){
                    setConId.add(c.Id);
                }
            }
            
            if(AdditionalToContactIdsCC != null && AdditionalToContactIdsCC != ''){ 
                List<string> lstConIds = AdditionalToContactIdsCC.split(',');
                for(Contact c : [Select Id From Contact Where Id IN: lstConIds]){
                    setConId.add(c.Id);
                }
            }
            
            if(setConId.size() > 0){
                
                List<Task> lstTask = new List<Task>();
                
                for(Id conId : setConId){
                    Task task = new Task(OwnerId = UserInfo.getUserId(), whoId = conId, ActivityDate = Date.Today(), whatId = ObjectId, Subject = 'Email: ' + Subject, Priority = 'Normal' );
               
                    task.Description = 'Additional To: ' + strAllEmails   + '\r\n     ';
                    task.Description += 'CC: ' + CarbonCopy + '\r\n     ';
                    //task.Description += 'BCC: ' + ToCopy + '\r\n     ';
                    task.Description += 'Attachment: ' + AllFileAttachmentName + '\r\n     ';
                    task.Description += 'Subject: ' + Subject + '\r\n     ';
                    task.Description += 'Body: ' + Content.replaceAll('<br/>', '\r\n');
                    task.Status = 'Completed';
                    
                    if(HideAttachmentType != 'YES'){
                        task.CRMG_EmailAtt__Attachment_Type__c = Type;
                    }
                    if(HideActivityStatus != 'YES'){
                        task.Status = ActivityStatus ;
                    }
                    
                    lstTask.add(task);
                }
                
                if(lstTask.size() > 0){
                    try
                    {
                        insert lstTask;
                    }
                    catch(Exception ex)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Create task error, please contact administrator.'));
                        system.debug('=================' + ex.getMessage() );
                        return null;
                    }
                }
            }
            else{
                Task task = new Task(OwnerId = UserInfo.getUserId(), ActivityDate = Date.Today(), whatId = ObjectId, Subject = 'Email: ' + Subject,  Priority = 'Normal' );
               
                task.Description = 'Additional To: ' + strAllEmails   + '\r\n     ';
                task.Description += 'CC: ' + CarbonCopy + '\r\n     ';
                //task.Description += 'BCC: ' + ToCopy + '\r\n     ';
                task.Description += 'Attachment: ' + AllFileAttachmentName + '\r\n     ';
                task.Description += 'Subject: ' + Subject + '\r\n     ';
                task.Description += 'Body: ' + Content.replaceAll('<br/>', '\r\n');
                task.Status = 'Completed';
                
                if(HideAttachmentType != 'YES'){
                    task.CRMG_EmailAtt__Attachment_Type__c = Type;
                }
                if(HideActivityStatus != 'YES'){
                    task.Status = ActivityStatus ;
                }
                    
                try
                {
                    insert task;
                }
                catch(Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Create task error, please contact administrator.'));
                    system.debug('=================' + ex.getMessage() );
                    return null;
                }
            }
            
             
        return new PageReference('/' + ObjectId);
    }
    
    public PageReference selectAttachments()
    {
        showAttachment = false;
        AttachmentNames = '';
        if(ForSendAttachmentNames != null && ForSendAttachmentNames != ''){
            AttachmentNames = ForSendAttachmentNames;
        }
        if(ForSendDocumentNames != null && ForSendDocumentNames != ''){
            if(AttachmentNames != ''){
                AttachmentNames = AttachmentNames+ ',';
            }
            AttachmentNames = AttachmentNames + ForSendDocumentNames;
        }
        if(ForSendContentNames != null && ForSendContentNames != ''){
            if(AttachmentNames != ''){
                AttachmentNames = AttachmentNames+ ',';
            }
            AttachmentNames = AttachmentNames + ForSendContentNames;
        }
        for(FileInfo FileObj : listFileObj ){
       
            if(FileObj.FileName != null && FileObj.FileBody != null ){
                Attachment att = new Attachment();
                att.ParentId = id;
                att.Name = FileObj.FileName;
                att.Body = FileObj.FileBody;
                
                upsert att;
                
                FileObj = new FileInfo();
                
                if(ForSendAttachmentIds != null && ForSendAttachmentIds != ''){
                    ForSendAttachmentIds = ForSendAttachmentIds + ',';
                }
                ForSendAttachmentIds = ForSendAttachmentIds + att.Id;
                
                if(AttachmentNames != ''){
                    AttachmentNames = AttachmentNames+ ',';
                }
                AttachmentNames = AttachmentNames + att.Name;
            }
        }
        
        listFileObj = new List<FileInfo>();
        for(integer i=0; i<3;i++){
            FileInfo fi = new FileInfo();
            listFileObj.add(fi);
        }
        
        return null;
    }
    
    public PageReference showEmailBody()
    {
        if(TemplateId instanceOf Id)
        {
            ForSendTemplate = [select Body, htmlvalue, TemplateType from EmailTemplate where Id = :TemplateId];
            
            if(ForSendTemplate.htmlvalue != null && ForSendTemplate.htmlvalue != '')
            {
                Content = ForSendTemplate.htmlvalue;
                Content = optimzeContent(Content);
            }
            
            if(ForSendTemplate.TemplateType == 'Text' && ForSendTemplate.Body != null && ForSendTemplate.Body != '')
            {
                Content = ForSendTemplate.Body.replaceAll('(\r\n)|\r|\n', '<br/>');
                Content = optimzeContent(Content);
            }

            Subject = optimzeContent(Subject);
            isShowTemplate = true;
        }
        return null;
    }
    
     public String optimzeContent(String temp)
    {
        String handledContent = temp.replaceAll(']]>', '');
        
        if(handledContent.indexOf('{!') != -1)
        {    
            Schema.SObjectType targetTypeCase = Schema.getGlobalDescribe().get('Case');
            Schema.DescribeSObjectResult descSORCase = targetTypeCAse.getDescribe(); 
            Map<String, Schema.SObjectField> mapDescSOCase = descSORCase.fields.getMap();
                            
            do
            {
                Integer mergeIndexStart = handledContent.indexOf('{!');
                Integer mergeIndexEnd = handledContent.indexOf('}');
                String mergeObjectField = handledContent.subString(mergeIndexStart + 2, mergeIndexEnd);
                
                if(mergeObjectField.indexOf('.') != -1)
                {
                    String mergeObject = mergeObjectField.subString(0, mergeObjectField.indexOf('.'));
                    String mergeField = mergeObjectField.subString(mergeObjectField.indexOf('.') + 1);
                    if(mergeObject == 'Organization')
                    {
                        Organization org = [select Name from Organization limit 1];
                        
                        if(org.Name != null){
                            handledContent = handledContent.subString(0, mergeIndexStart) + org.Name + handledContent.subString(mergeIndexEnd + 1);
                        }
                        else{
                            handledContent = handledContent.subString(0, mergeIndexStart) + '' + handledContent.subString(mergeIndexEnd + 1);
                        }
                    }
                    else if(mergeObject == 'User')
                    {
                        try
                        {
                            String userQuery = 'select ' + String.escapeSingleQuotes(mergeField) + ' from User where Id = \'' + UserInfo.getUserId() + '\' limit 1';
                            List<User> users = Database.query(userQuery);
                            
                            if(users[0].get(mergeField) != null){
                                handledContent = handledContent.subString(0, mergeIndexStart) + users[0].get(mergeField) + handledContent.subString(mergeIndexEnd + 1);
                            }
                            else{
                                handledContent = handledContent.subString(0, mergeIndexStart) + '' + handledContent.subString(mergeIndexEnd + 1);
                            }
                        }
                        catch(exception ex)
                        {
                            handledContent = handledContent.subString(0, mergeIndexStart) + '' + handledContent.subString(mergeIndexEnd + 1);   
                        }
                    } 
                    else
                    {
                        handledContent = handledContent.subString(0, mergeIndexStart) + ' ' + handledContent.subString(mergeIndexEnd + 1);
                    }
                }
                else
                {
                    handledContent = handledContent.subString(0, mergeIndexStart) + ' ' + handledContent.subString(mergeIndexEnd + 1);
                }
            }while(handledContent.indexOf('{!') != -1);
            
        }
        return handledContent;
    }   
     
    public PageReference cancel()
    {
        return new PageReference('/' + ObjectId);
    }

    public List<SelectOption> getFolders() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(UserInfo.getOrganizationId() ,'Unfiled Public Email Templates'));
        options.add(new SelectOption(UserInfo.getUserId() ,'My Personal Email Templates'));
        for(Folder f : [Select f.Type, f.Name, f.Id From Folder f Where f.Type = 'Email' Order By Name ]){
            options.add(new SelectOption(f.Id,f.Name));
        }
        return options;
   }
  
    public class AttachmentInfo
    {
        public AttachmentInfo() {}
        public String AttachmentId { set; get; }
        public String AttachemntName { set; get; }
        public String LastModifiedBy { set; get; }
        public String AttachmentType { set; get; }
        public String CreatedBy { set; get; }
    }
    
    public class FileInfo{
        public string FileName {get;set;}
        public blob FileBody {get;set;}
    }
    
    @isTest
    Static void testEmailInvoice()
    {     
        TestDataUtil.createCustomSettings_TriggerStatus();
        Account cus = new Account(Name = 'testAcc',BillingStreet ='Test Street', billingState = 'CA', billingCountry = 'USA',
        billingPostalCode = '213',billingCity = 'SFO');
        insert cus;
        
        system.assert(cus.Id != null );
        
        Contact contact = new Contact(Email = 'sinow.zhang@gmail.com', LastName = 'test0002',AccountId = cus.Id);
        insert contact;
                ATI_Job__c  o = new ATI_Job__c();
        
        o.Job_Name__c = 'test';
        o.Project_Site_Contact_Name__c = contact.id;
        o.Project_Site_Contact_Account__c = cus.id;
        o.Project_Site_Address__c = 'Test Street';
        o.Project_Site_City__c = 'Los Angeles';
        o.Project_Site_state__c = 'CA';
        o.Project_Site_zipcode__c ='90027';
        //o.County__c = 'LA';
        //o.City_of_LA__c = 'Yes';
        o.Stage__c ='Qualification';
        o.CloseDate__c = System.today().addDays(90); 
        o.office2__c = null;
        o.Division__c = 'test';   
        insert o;
        Invoice__c invoice = new Invoice__c();
        invoice.ATI_Job__c = O.Id;            
        invoice.Due_Date__c = system.today()+5;
        invoice.Status__c = 'In Process';
        invoice.CC_Account__c = cus.Id;
        invoice.Bill_To__c= cus.Id;
        
        insert invoice;
        
        EmailInvoice.getsObject(o.id);
        Blob attbody = Blob.valueOf('This is a the file1 content.');
        Attachment testatt1 = new Attachment(Name = 'file1', body = attbody, ParentId = contact.Id);
        Attachment testatt2 = new Attachment(Name = 'file2', body = attbody, ParentId = contact.Id);
        insert testatt1;
        insert testatt2;
        
        Document doc1 = new Document(Name = 'file2', body = attbody , FolderId = UserInfo.getUserId());
        insert doc1;
        
        contact = [select Id from Contact where Id = :contact.Id];
        PageReference EmailInvoice = Page.EmailInvoice;
        EmailInvoice.getParameters().put('id', contact.Id);
        Test.setCurrentPage(EmailInvoice);
        EmailInvoice controller = new EmailInvoice();
        controller.Subject = 'test';
        controller.contactEmails = 'Sinow.zhang@gmail.com';
        controller.AdditionalToEmails  = 'test1@gmail.com,test2@gmail.com';
        controller.ForSendAttachmentNames  = 'test.png';
        controller.CarbonCopy  = 'Sinow.zhang@gmail.com';
        controller.ForSendDocumentIds  = doc1.Id;
        controller.ForSendContentIds='test,test';
        
        List<SelectOption> lst1 = controller.getFolders();
        
        List<SelectOption> lst2 = controller.getDocFolders();
        
        List<SelectOption> lst3 = controller.getAllActivityStatus();
        
        List<SelectOption> lst4 = controller.getWorkspace();
        
        EmailTemplate template = [select Id from EmailTemplate limit 1];
        controller.TemplateId = template.Id;
        controller.ForSendAttachmentIds = testatt1.Id + ',' + testatt2.Id;
        controller.ForSendDocumentNames = 'test';
        controller.ForSendContentNames = 'test';
        try{
            controller.save();
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        controller.cancel();
        controller.selectAttachments();
        controller.showEmailBody();
        List<AttachmentInfo> AttachmentInfos = controller.AttachmentInfos;
        List<EmailTemplate> EmailTemplates = controller.EmailTemplates;
        String testContent = 'abc{!User.Name}abc{!Organization.Name}abc{!Contact.LastName}abc{!Case.Name}abc{!Contract.Name};';
        String optimzeTestContent = controller.optimzeContent(testContent);
        
        
        EmailInvoice.FileInfo fo = new EmailInvoice.FileInfo();
        
        fo.FileName = 'test.txt';
        fo.FileBody = attbody;
        
        controller.listFileObj.add(fo);
        controller.selectAttachments();
        
        controller = new EmailInvoice();
        controller.Subject = 'test';
        controller.Content = 'test';
        controller.contactEmails = 'Sinow.zhang@gmail.com';
        controller.BccMe = true;
        try{
            controller.save();
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
        List<Document> lstD = controller.Documents;
        List< ContentVersion > lstC = controller.Contents;
        
        PageReference pr2 = controller.DoNothing();
 
    }
    
    @isTest
    Static void testEmailInvoice2()
    {
     TestDataUtil.createCustomSettings_TriggerStatus();
        Account cus = new Account(Name = 'testAcc',BillingStreet ='Test Street', billingState = 'CA', billingCountry = 'USA',
        billingPostalCode = '213',billingCity = 'SFO');
        insert cus;
        
        system.assert(cus.Id != null );
        
        Contact contact = new Contact(Email = 'sinow.zhang@gmail.com', LastName = 'test0002',AccountId =cus.Id);
        insert contact;
        ATI_Job__c  o = new ATI_Job__c();
        
        o.Job_Name__c = 'test';
        o.Project_Site_Contact_Name__c = contact.id;
        o.Project_Site_Contact_Account__c = cus.id;
        o.Project_Site_Address__c = 'Test Street';
        o.Project_Site_City__c = 'Los Angeles';
        o.Project_Site_state__c = 'CA';
        o.Project_Site_zipcode__c ='90027';
        //o.County__c = 'LA';
        //o.City_of_LA__c = 'Yes';
        o.Stage__c ='Qualification';
        o.CloseDate__c = System.today().addDays(90); 
        o.office2__c = null;
        o.Division__c = 'test';   
        insert o;
        Invoice__c invoice = new Invoice__c();
        invoice.ATI_Job__c = O.Id;            
        invoice.Due_Date__c = system.today()+5;
        invoice.Status__c = 'In Process';
        invoice.CC_Account__c = Contact.AccountId;
        invoice.Bill_To__c= Contact.AccountId;
        insert invoice;
        
        EmailInvoice.getsObject(invoice.id);
        Blob attbody = Blob.valueOf('This is a the file1 content.');
        Attachment testatt1 = new Attachment(Name = 'file1', body = attbody, ParentId = contact.Id);
        Attachment testatt2 = new Attachment(Name = 'file2', body = attbody, ParentId = contact.Id);
        insert testatt1;
        insert testatt2;
        
        Document doc1 = new Document(Name = 'file2', body = attbody , FolderId = UserInfo.getUserId());
        insert doc1;
        
        contact = [select Id from Contact where Id = :contact.Id];
        PageReference EmailInvoice = Page.EmailInvoice;
        EmailInvoice.getParameters().put('id', contact.Id);
        Test.setCurrentPage(EmailInvoice);
        EmailInvoice controller = new EmailInvoice();
        controller.Subject = 'test';
        controller.contactEmails = 'Sinow.zhang@gmail.com';
        controller.AdditionalToEmails  = 'test1@gmail.com,test2@gmail.com';
        controller.ForSendAttachmentNames  = 'test.png';
        controller.CarbonCopy  = 'Sinow.zhang@gmail.com';
        controller.ForSendDocumentIds  = doc1.Id;
        
        controller.AdditionalToContactIds = contact.Id;
        
        List<SelectOption> lst1 = controller.getFolders();
        
        List<SelectOption> lst2 = controller.getDocFolders();
        
        List<SelectOption> lst3 = controller.getAllActivityStatus();
        
        List<SelectOption> lst4 = controller.getWorkspace();
        
        EmailTemplate template = [select Id from EmailTemplate limit 1];
        controller.TemplateId = template.Id;
        controller.ForSendAttachmentIds = testatt1.Id + ',' + testatt2.Id;
        controller.ForSendDocumentNames = 'test';
        controller.ForSendContentNames = 'test';
        try{
            controller.save();
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        controller.cancel();
        controller.selectAttachments();
        controller.showEmailBody();
        List<AttachmentInfo> AttachmentInfos = controller.AttachmentInfos;
        List<EmailTemplate> EmailTemplates = controller.EmailTemplates;
        String testContent = 'abc{!User.Name}abc{!Organization.Name}abc{!Contact.LastName}abc{!Case.Name}abc{!Contract.Name};';
        String optimzeTestContent = controller.optimzeContent(testContent);
        
        
        EmailInvoice.FileInfo fo = new EmailInvoice.FileInfo();
        
        fo.FileName = 'test.txt';
        fo.FileBody = attbody;
        
        controller.listFileObj.add(fo);
        controller.selectAttachments();
        List<SelectOption>  ll =controller.getAttachmentTypes();
        controller = new EmailInvoice();
        controller.Subject = 'test';
        controller.Content = 'test';
        controller.contactEmails = 'Sinow.zhang@gmail.com';
        controller.BccMe = true;
        try{
            controller.save();
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
        List<Document> lstD = controller.Documents;
        List< ContentVersion > lstC = controller.Contents;
        
        PageReference pr2 = controller.DoNothing();
 
    }
    
    @AuraEnabled
    public static sObject getsObject(ID ObjectId){
        
        String sObjName = ObjectId.getSObjectType().getDescribe().getName();
        
        if(sObjName == 'ATI_Job__c'){
          ATI_Job__c opp = (ATI_Job__c)Database.query('SELECT Id FROM ATI_Job__c where Id =: ObjectId LIMIT 1');
          return opp;
      }
        else if(sObjName == 'Invoice'){
          ATI_Job__c opp = (ATI_Job__c)Database.query('Select Id, (select id, ATI_Job__c__c from Invoice__c where Id =:ObjectId limit 1) from ATI_Job__c');
            return opp; 
        }
        else
            return null;

    }
     
}