public with sharing class UserContactLookup
{   
    private String id = ApexPages.currentPage().getParameters().get('id');
    
    public string QueryString {get;set;}
    
    public string SelectedEmails {get;set;}
    public string SelectedNames {get;set;}
    
    public string SelectedContactIds {get;set;}
    
    public string IsCC {get;set;}
    
    public UserContactLookup() 
    {
        
        IsCC = '';
        
        if(ApexPages.currentPage().getParameters().get('CC') == 'YES'){
            IsCC = 'CC';
        }
        
        Contacts = new List<Contact>();
        
        Users = new List<User>();
        
        if(ApexPages.currentPage().getParameters().get('keyword') != null){
            QueryString = ApexPages.currentPage().getParameters().get('keyword');
        }
        
 
    } 
    
    public PageReference DoSearchAll(){
        try{
            
            
             Contacts = new List<Contact>();
        
             Users = new List<User>();
            
            if(QueryString != null && QueryString != ''){
                string sQry = '%' + QueryString + '%';
                
                for(Contact c : [Select Id, Name, Email From Contact Where Name Like : sQry  AND Email != null Order By LastModifiedDate DESC Limit 100 ]){
                    Contacts.add(c);
                }
                
                for(User u : [Select Id, Name, Email From User Where Name Like : sQry  AND Email != null Order By LastModifiedDate DESC Limit 100 ]){
                    Users.add(u);
                }
            }
            else{
                for(Contact c : [Select Id, Name, Email From Contact Where  Email != null Order By LastModifiedDate DESC Limit 10 ]){
                    Contacts.add(c);
                }
                
                for(User u : [Select Id, Name, Email From User Where Email != null Order By LastModifiedDate DESC Limit 10 ]){
                    Users.add(u);
                }
            }
            
            if(Contacts.size() == 0 && Users.size() == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Contact or User found. Please filter the search criteria and try again.'));
            }
        
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        return null;
    }
    
    public PageReference DoSearchUser(){
        try{
 
             Users = new List<User>();
            
             if(QueryString != null && QueryString != ''){
                
                string sQry = '%' + QueryString + '%';
  
                for(User u : [Select Id, Name, Email From User Where Name Like : sQry AND Email != null Order By Name Limit 100 ]){
                    Users.add(u);
                }
             }
             else{
                PageReference pr = DoSearchAll();
             }
             
            if(Contacts.size() == 0 && Users.size() == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No User found. Please filter the search criteria and try again.'));
            }
        
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        return null;
    }
    
    public PageReference DoSearchContact(){
        try{
  
             Contacts = new List<Contact>();
   
             if(QueryString != null && QueryString != ''){
                
                string sQry = '%' + QueryString + '%';
                
                for(Contact c : [Select Id, Name, Email From Contact Where Name Like : sQry AND Email != null Order By Name Limit 100 ]){
                    Contacts.add(c);
                }
              
             }
             else{
                PageReference pr = DoSearchAll();
             }
             
            if(Contacts.size() == 0 && Users.size() == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Contact found. Please filter the search criteria and try again.'));
            }
        
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        return null;
    }
    
    
    public List<Contact> Contacts { set; get; }
    
    public List<User> Users { set; get; }
    
    
    @isTest 
    Static void testUserContactLookup()
    {
        Account acc = new Account(Name = 'testAcc',BillingStreet ='Test Street', billingState = 'CA', billingCountry = 'USA',
        billingPostalCode = '213',billingCity = 'SFO');
        insert acc;
        PageReference contactLooking = Page.UserContactLookup; 
        contactLooking.getParameters().put('id', acc.Id);
        Test.setCurrentPage(contactLooking);
        UserContactLookup controller = new UserContactLookup();
        System.assert(controller.Contacts.size() == 0);
        
        Contact con = new Contact(LastName = 'testCon', AccountId = acc.Id);
        insert con;
        
        System.assertNotEquals(con.id, null);
        
        ApexPages.currentPage().getParameters().put('keyword', 'test');
        
         UserContactLookup cls = new UserContactLookup();
         
         try{
            PageReference pr = cls.DoSearchAll();
         }
         catch(Exception ex){
            system.debug(ex.getMessage());
         }
         
         cls.QueryString = 'test';
         
         try{
            PageReference pr = cls.DoSearchContact();
         }
         catch(Exception ex){
            system.debug(ex.getMessage());
         }
         
          try{
            PageReference pr = cls.DoSearchUser();
         }
         catch(Exception ex){
            system.debug(ex.getMessage());
         }
    }
    
     @isTest 
    Static void testUserContactLookup2()
    {
        Account acc = new Account(Name = 'testAcc',BillingStreet ='Test Street', billingState = 'CA', billingCountry = 'USA',
        billingPostalCode = '213',billingCity = 'SFO');
        insert acc;
        PageReference contactLooking = Page.UserContactLookup; 
        contactLooking.getParameters().put('id', acc.Id);
        Test.setCurrentPage(contactLooking);
        UserContactLookup controller = new UserContactLookup();
        System.assert(controller.Contacts.size() == 0);
        
        
        ApexPages.currentPage().getParameters().put('keyword', 'test');
        
         UserContactLookup cls = new UserContactLookup();
         
         try{
            PageReference pr = cls.DoSearchAll();
         }
         catch(Exception ex){
            system.debug(ex.getMessage());
         }
         
         cls.QueryString = 'test';
         
         try{
            PageReference pr = cls.DoSearchContact();
         }
         catch(Exception ex){
            system.debug(ex.getMessage());
         }
         
          try{
            PageReference pr = cls.DoSearchUser();
         }
         catch(Exception ex){
            system.debug(ex.getMessage());
         }
    } 
}