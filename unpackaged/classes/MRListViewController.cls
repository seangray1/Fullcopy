/**
* @author           kanitha Priya P
* @version          1.0
* @date             03-07-2017
* @status           Developed
* @Description      The purpose of this controller is to view the Material Requisitions and to create a new Requisition form.
**/

public with sharing class MRListViewController {

    public List<RecentlyViewed> RecentList {get;set;}
    public List<Material_Requisition__c> MRList {get;set;}
    public List<Material_Requisition__c> MRListTemp {get;set;}
    public List<Material_Requisition__c> ALLMRList {get;set;}
    public List<Id> MRId {get;set;}
    public List<String> FormType {get;set;}
    public String SelectedFormType {get;set;}
    public String SearchText {get;set;}
    public String ListLabel {get;set;}
    public Integer counter {get;set;}
    public Integer limitSize {get;set;}
    public Integer totalSize {get;set;} 
    public List < SelectOption > SelectFormType {get;set;}
    public Map<Id,Material_Requisition__c>ALLMRMap{get;set;}
    public Boolean displayPopup {get; set;} 
    public Id MRLinkId{get;set;}
    public MRListViewController(){
    
        try
        {
            // FormType takes the allowed MR statuses to be displayed in MR List view 
            FormType = new List<String>();
            FormType.add('In Progress');
            FormType.add('Completed');
            SelectFormType = new List < SelectOption > ();
            displayPopup = false;
            
            // Assigning the default picklist value as 'Recently Viewed'
            if(SelectedFormType == null)
            {
                SelectedFormType = 'Recently Viewed';
                
            }
            SelectFormType.add(new SelectOption('Recently Viewed','Recent Forms'));
            SelectFormType.add(new SelectOption('In Progress','In Progress Forms'));
            
            // Setting parameters for pagination
            counter = 0;
            limitSize = 5;
            totalSize = 0;
            
            //Fetching the Recently viewed MR on initial Load
            LoadMR();
        }
        catch(Exception e)
        {
        
        }
        system.debug(Logginglevel.info,'MRList Controller'+MRList);
    
    }
    
    /// <OBJECTIVE>
    /// Fetches the 'Recently viewed'/ 'In Progress' Material Requisitions based on the picklist value selected
    /// </OBJECTIVE>
    
    public void LoadMR()
    {
    
        MRList = new List<Material_Requisition__c>();
        MRListTemp = new List<Material_Requisition__c>();
        ALLMRList = new List<Material_Requisition__c>();
        RecentList = new List<RecentlyViewed>();
        ALLMRMap = new Map<Id,Material_Requisition__c>();
        counter = 0;
        limitSize = 5;
        MRId = new List<Id>();
        system.debug('SelectedFormType '+SelectedFormType);
        
        try
        {
           
            //Fetches Recently Viewed MRs
            if(SelectedFormType == 'Recently Viewed')
            {
                //To fetch MR with Last Modified Date
                ALLMRList = PRLDE_DataUtility.fetchMR(null,FormType,5,userinfo.getuserid(),null,null,null);
                ListLabel = 'Recently Viewed Requisition Forms';
                SelectedFormType = 'Recently Viewed';
            }
            //Fetches all 'In Progress' MRs
            else if(SelectedFormType == 'In Progress'){
            
                ALLMRList = PRLDE_DataUtility.fetchMR(null,null,null,userinfo.getuserid(),SelectedFormType,null,null);
                ListLabel = 'In Progress Requisition Forms';
                SelectedFormType = 'In Progress';
            }
            
            SearchText = '';
            beginning();
            
        }
        catch(Exception e)
        {
        
        }
        system.debug(Logginglevel.info,'MRList LoadMR'+MRList);
    }
    
    /// <OBJECTIVE>
    /// Fetches the Material Requisitions based on the given search text
    /// </OBJECTIVE>
    public void SearchByMRName(){
    
        MRList = new List<Material_Requisition__c>();
        ALLMRList = new List<Material_Requisition__c>();
        counter = 0;
        
        try
        {
            //Trims extra spaces in searchtext
            if(SearchText != null)
            {
                SearchText = SearchText.trim();
            }
            ALLMRList = PRLDE_DataUtility.fetchMR(null,FormType,null,userinfo.getuserid(),null,SearchText,null);
            
            // Validates the List size and dynamically changes the List Label
            if(ALLMRList.size() == 0)
            {
                ListLabel = 'No Search Results Found';
                counter = 0;
                totalSize = 0; 
            }
            else
            {
                ListLabel = 'Search Results';
                beginning();
              
            }
        }
        catch(Exception e)
        {
        
        }
        system.debug(Logginglevel.info,'MRList SearchByMRName'+MRList+counter+limitSize+totalSize);
    }
    
    /// <OBJECTIVE>
    /// Redirects the user to the New MR form
    /// </OBJECTIVE>
    public pageReference NewMR()
    {
        pageReference pg = new PageReference('/apex/MR_UI?MRId=');
        pg.setRedirect(true);
        return pg;
    }
    
    public pageReference MRLink()
    {
        pageReference pg = new PageReference('/apex/MR_Summary_UI?MRId='+MRLinkId);
        pg.setRedirect(true);
        return pg;
    }
    
    /// <OBJECTIVE>
    /// Used for pagination. Displays the first set of records in MRList.
    /// </OBJECTIVE>
    public void beginning(){
   
        MRList.clear();
        counter=0;
        totalSize = ALLMRList.size();
        
        if((counter + limitSize) <= totalSize){
       
            for(Integer i=0;i<limitSize;i++){
                MRList.add(AllMRList.get(i));
            }   
           
        } else{
       
            for(Integer i=0;i<totalSize;i++){
                MRList.add(AllMRList.get(i));
            }       
           
        }
       
    }
    
    /// <OBJECTIVE>
    /// Used for pagination. Displays the next set of records in MRList.
    /// </OBJECTIVE>
    public void next(){
   
        MRList.clear();
        counter=counter+limitSize;
        totalSize = ALLMRList.size();
        
        if((counter+limitSize) <= totalSize){
            for(Integer i=counter;i<(counter+limitSize);i++){
                MRList.add(AllMRList.get(i));
            }
        } else{
            for(Integer i=counter;i<totalSize;i++){
                MRList.add(AllMRList.get(i));
            }
        }
    }
    
    /// <OBJECTIVE>
    /// Used for pagination. Displays the previous set of records in MRList.
    /// </OBJECTIVE>
    public void previous(){
   
        MRList.clear();
        totalSize = ALLMRList.size();
        
        counter=counter-limitSize;       
       
        for(Integer i=counter;i<(counter+limitSize); i++){
            MRList.add(AllMRList.get(i));
        }
    }
    
    /// <OBJECTIVE>
    /// Used for pagination. Displays the last set of records in MRList.
    /// </OBJECTIVE>
    public void last(){
   
        MRList.clear();
        totalSize = ALLMRList.size();
        
        if(math.mod(totalSize , limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } else if (math.mod(totalSize , limitSize) != 0){
            counter = limitSize * ((totalSize/limitSize));
        }
       
        for(Integer i=counter-1;i<totalSize-1;i++){
                MRList.add(AllMRList.get(i));
        }
       
    }
    
    /// <OBJECTIVE>
    /// Used for pagination. To disable the Next buttons.
    /// </OBJECTIVE>
    public Boolean getDisableNext(){
   
        if((counter + limitSize) >= totalSize )
            return true ;
        else
            return false ;
    }
    
    /// <OBJECTIVE>
    /// Used for pagination. To disable the Previous buttons.
    /// </OBJECTIVE>
    public Boolean getDisablePrevious(){
   
        if(counter == 0)
            return true ;
        else
            return false ;
    } 
    
}