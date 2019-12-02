/**
* @author           kanitha Priya P
* @version          1.0
* @date             04-07-2017
* @status           Developed
* @Description      The purpose of this controller is to view the Material Requisitions and to create a new Requisition form.
**/

public with sharing class MRSummaryController {

    public String MRId{get;set;}
    public List<Material_Requisition__c> MRRecordLst{get;set;}
    public Material_Requisition__c MR_Record{get;set;}
    public List<Material_Requisition_line_item__c> MRLineItemLeftTable {get;set;}
    public List<Material_Requisition_line_item__c> MRLineItemRightTable {get;set;}
    public List<Material_Requisition_line_item__c> MRLineItem {get;set;}
    public String MRStatus {get;set;}
    public List<String> FormType {get;set;}
    //public String MainColSize{get;set;}
    //public String SubColSize{get;set;}
    //public String Profile_Name {get;set;}
    public String JobName{get;set;}
    public String JobNumber{get;set;}
    public String LocationName{get;set;}
    public String Status{get;set;}
    public String DateOrdered{get;set;}
    //public DateTime DaO{get;set;}
    public Set<String> MRToHighlight{get;set;}
    public Map<String,Boolean> MRToHighlightMap{get;set;}
    public String CollapsibleLabel{get;set;}
    public List<PermissionSetAssignment> permissionSetIds{get;set;}
    public Boolean UnitCostRenderer{get;set;}
    public Boolean ZeroValue{get;set;}
    public Boolean blankNegValue{get;set;}
    public Boolean RetndGreater{get;set;}
    public List<PermissionSet> permissionSetList{get;set;}
    
    public MRSummaryController()
    {
        try
        {
            //Gets the record Id for the existing MR
            MRId = ApexPages.currentPage().getParameters().get('MRId');
            
            MRRecordLst = new List<Material_Requisition__c>();
            MR_Record = new Material_Requisition__c();
            MRLineItem = new List<Material_Requisition_line_item__c>();
            MRLineItemLeftTable = new List<Material_Requisition_line_item__c>();
            MRLineItemRightTable = new List<Material_Requisition_line_item__c>();
            MRToHighlight = new Set<String>();
            MRToHighlightMap = new Map<String,Boolean>();
            CollapsibleLabel = 'More Details';
            permissionSetIds = new List<PermissionSetAssignment>();
            permissionSetList = new List<PermissionSet>();
            UnitCostRenderer = false;
            ZeroValue = false;
            blankNegValue = false;
            RetndGreater = false;
            
            //Form Type takes the possible set of form statuses to be shown in Summary UI
            FormType = new List<String>();
            FormType.add('In Progress');
            FormType.add('Completed');
            
            //Gets the list of users assigned to the permission set 'MR_UnitCost_Access' and sets  
            //UnitCostRenderer which will be used to render the column 'unit cost' in MR Summary UI
            permissionSetList = PRLDE_DataUtility.fetchPermissionsetWithName('MR_UnitCost_Access');
            
            if(permissionSetList.size() > 0)
            {
                permissionSetIds = PRLDE_DataUtility.fetchAllPermissionsetAssignees(permissionSetList[0].Id);
            }
            if(permissionSetIds.size() > 0 )
            {
                for(PermissionSetAssignment permId : permissionSetIds)
                {
                    if(userinfo.getuserId() == permId.AssigneeId)
                    {
                        UnitCostRenderer = true;
                    }
                
                }
            }
        
            getDetailsByMRFormID();
            
            // If the form status is 'In Progress', 'Mark as Complete' button will be displayed.
            // If the form status is 'Completed', 'Mark as InProgress' button will be displayed.
            if(MR_Record.status__c == 'In Progress')
            MRStatus = 'Mark as Complete';
            else
            MRStatus = 'Mark as In Progress';
            
        }
        catch(Exception e)
        {
        
        }
    }
    
    /// <OBJECTIVE>
    /// This method gets the MR details with the MRId
    /// </OBJECTIVE>
    
    public void getDetailsByMRFormID()
    {
    
        try
        {
            //Fetches MR deatils with MR Id
            MRRecordLst = PRLDE_DataUtility.fetchMR(null,FormType,1,null,null,null,MRId);
            
            if(MRRecordLst.size() > 0)
            { 
            
                MR_Record = MRRecordLst[0];
                JobName = MRRecordLst[0].ATI_Job__r.Job_Name__c;
                JobNumber = MRRecordLst[0].ATI_Job__r.Job_Number__c;
                LocationName = MRRecordLst[0].Location_text__c;
                Status = MRRecordLst[0].Status__c;
                DateOrdered = (DateTime.newInstance(MRRecordLst[0].CreatedDate.year(),MRRecordLst[0].CreatedDate.month(),MRRecordLst[0].CreatedDate.day())).format('MM/dd/yyyy');
                MRLineItem = PRLDE_DataUtility.fetchMRItem(MR_Record.id);
                
                system.debug(Logginglevel.info,'==MRRecordLst== '+MRRecordLst);
                system.debug(Logginglevel.info,'==MRLineItem== '+MRLineItem);
                
                // Splits and displays the line items in left and right tables
                for(Material_Requisition_line_item__c item : MRLineItem)
                {
                    MRToHighlightMap.put(item.Name,false);
                }
                
                if(MRLineItem.size() == 1){
                
                    MRLineItemLeftTable.addAll(MRLineItem);
                
                }
                else if(MRLineItem.size() == 2){
                
                    MRLineItemLeftTable.add(MRLineItem[0]);
                    MRLineItemRightTable.add(MRLineItem[1]);
                
                }
                else if(MRLineItem.size() == 3){
                
                    MRLineItemLeftTable.add(MRLineItem[0]);
                    MRLineItemLeftTable.add(MRLineItem[1]);
                    MRLineItemRightTable.add(MRLineItem[2]);
                
                }
                else if(MRLineItem.size() > 1 && Math.mod(MRLineItem.size(),2)== 0)
                {
                
                    for(Integer i =0;i<=((MRLineItem.size())/2)-1;i++)
                    {
                        MRLineItemLeftTable.add(MRLineItem[i]);
                    }
                
                    for(Integer i =((MRLineItem.size())/2);i<=MRLineItem.size()-1;i++){
                        MRLineItemRightTable.add(MRLineItem[i]);
                    }
                
                
                }
                else if(MRLineItem.size() > 1 && Math.mod(MRLineItem.size(),2)== 1)
                {
                    
                    for(Integer i =0;i<=((MRLineItem.size())/2);i++)
                    {
                        MRLineItemLeftTable.add(MRLineItem[i]);
                    }
                
                    for(Integer i =((MRLineItem.size())/2+1);i<=MRLineItem.size()-1;i++)
                    {
                        MRLineItemRightTable.add(MRLineItem[i]);
                    }
                
                }
            }
        }
        catch(Exception e){
        
        }
    }
    
    /// <OBJECTIVE>
    /// This method redirects the user to MR List view.
    /// </OBJECTIVE>
    
    public PageReference Back()
    {
        try
        {
            pageReference pg = new PageReference('/apex/MR_List_view');
            pg.setRedirect(true);
            return pg;
        }
        catch(Exception e)
        {
            return null;
        }
    
    }
    
    /// <OBJECTIVE>
    /// This method redirects the user to MR UI.
    /// </OBJECTIVE>
    
    public PageReference Edit()
    {
        try
        {
            pageReference pg = new PageReference('/apex/MR_UI?MRId='+MRId);
            pg.setRedirect(true);
            return pg;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
    /// <OBJECTIVE>
    /// This method updates the form status to 'In Progress'/'Completed'
    /// </OBJECTIVE>
    
    public void UpdateStatus()
    {
        try
        {
            system.debug('==MRRecordLst== '+MRRecordLst);
        
            MRToHighlight.clear();
            MRToHighlightMap.clear();
            
            if(MR_Record.status__c == 'In Progress')
            {
                // If the form status is 'In Progress', it checks for returned quantities greater than shipped. 
                //If found any, an error message will be thrown. Else the form status will be updated to 'Complete'   
                      
                for(Material_Requisition_line_item__c item : MRLineItemLeftTable)
                {
                    if((item.Shipped__c == null && item.Returned__c != null)|| (item.Returned__c != null && ((item.Shipped__c - item.Returned__c) < 0)) || (item.Returned__c < 0 || item.Shipped__c < 0) || (item.Returned__c == 0 && item.Shipped__c == 0)|| item.Returned__c == null)
                    {
                       // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter a shipped quantity greater than the Returned quantity for the material ' + item.Name));
                        MRToHighlight.add(item.Name);
                        MRToHighlightMap.put(item.Name,true);
                        
                        if(item.Shipped__c == null || item.Returned__c == null || (item.Returned__c < 0 || item.Shipped__c < 0))
                        {
                            blankNegValue = true;
                        }
                        if(item.Shipped__c != null && item.Returned__c != null && ((item.Shipped__c - item.Returned__c) < 0))
                        {
                            RetndGreater = true;
                        }
                        if(item.Returned__c == 0 && item.Shipped__c == 0)
                        {
                            ZeroValue = true;
                        }
                     }
                     else
                     {
                         MRToHighlightMap.put(item.Name,false);
                     }
                }
                
                for(Material_Requisition_line_item__c item : MRLineItemRightTable)
                {
                    if((item.Shipped__c == null && item.Returned__c != null)|| (item.Returned__c != null && ((item.Shipped__c - item.Returned__c) < 0)) || (item.Returned__c < 0 || item.Shipped__c < 0)|| (item.Returned__c == 0 && item.Shipped__c == 0) || item.Returned__c == null)
                    {
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter a shipped quantity greater than the Returned quantity for the material ' + item.Name));
                        MRToHighlight.add(item.Name);
                        MRToHighlightMap.put(item.Name,true);
                        if(item.Shipped__c == null || item.Returned__c == null || (item.Returned__c < 0 || item.Shipped__c < 0))
                        {
                            blankNegValue = true;
                        }
                        if(item.Shipped__c != null && item.Returned__c != null && ((item.Shipped__c - item.Returned__c) < 0))
                        {
                            RetndGreater = true;
                        }
                        if(item.Returned__c == 0 && item.Shipped__c == 0)
                        {
                            ZeroValue = true;
                        }
                    }
                    else
                     {
                         MRToHighlightMap.put(item.Name,false);
                     }
                }
                
                if(MRToHighlight.size() == 0)
                {    
                    
                    MR_Record.status__c = 'Completed';
                    MRStatus = 'Mark as In Progress';
                    Status = 'Completed';
                    update MR_Record;
                }
                else
                {
                    if(blankNegValue == true && RetndGreater == false)
                    {    
                        if(ZeroValue == true)
                        {
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Shipped or Returned quantity cannot not be blank or less than zero. <br/> Both Shipped and Returned quantity cannot be zero. Please enter correct values.'));
                        }
                        else
                        {
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Shipped or Returned quantity cannot not be blank or less than zero. Please enter correct values.'));
                        }
                    }
                    
                    if(blankNegValue == false && RetndGreater == true)
                    {    
                        if(ZeroValue == true)
                        {
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Returned quantity cannot be greater than the Shipped quantity. <br/> Both Shipped and Returned quantity cannot be zero. Please enter correct values.'));
                        }
                        else
                        {
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Returned quantity cannot be greater than the Shipped quantity. Please enter correct values.'));
                        }
                    } 
                    
                    if(blankNegValue == true && RetndGreater == true)
                    {    
                        if(ZeroValue == true)
                        {
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Shipped or Returned quantity cannot not be blank or less than zero. <br/> The Returned quantity cannot be greater than the Shipped quantity. <br/> Both Shipped and the Returned quantity cannot be zero. Please enter correct values.'));
                        }
                        else
                        {
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Shipped or Returned quantity cannot not be blank or less than zero. <br/> The Returned quantity cannot be greater than the Shipped quantity. Please enter correct values.'));
                        }
                    }
                    
                    if(ZeroValue == true && blankNegValue == false && RetndGreater == false)
                    {
                        
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Both Shipped and Returned quantity cannot be zero. Please enter correct values.'));
                    }              
                }
            }
            // If the form status is 'Completed', the status will be moved to 'In Progress' 
            else
            {
                for(Material_Requisition_line_item__c item : MRLineItemLeftTable)
                {
                    MRToHighlightMap.put(item.Name,false);
                }
                for(Material_Requisition_line_item__c item : MRLineItemRightTable)
                {
                    MRToHighlightMap.put(item.Name,false);
                }
                    
                MR_Record.status__c = 'In Progress';
                MRStatus = 'Mark as Complete';
                Status = 'In Progress';
                update MR_Record;
            }
        }
        catch(Exception e)
        {
        
        
        }
    
    }
    
}