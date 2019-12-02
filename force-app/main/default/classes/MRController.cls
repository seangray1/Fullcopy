/**
 * @author           kanitha Priya P
 * @version          1.0
 * @date             05-07-2017
 * @status           Developed
 * @Description      The purpose of this controller is to create a new Requisition form or modify the exisiting requisition form.
 **/
public with sharing class MRController {
    
    public String JobName {get;set;}
    public String JobId {get;set;}
    public String JobNumber {get;set;}
    public String JobLocation {get;set;}
    public List < SelectOption > Location {get;set;}
    public List < MRLocation__c > LocationList {get;set;}
    public List <Location_Code__c> LocationCodeList {get;set;}
    public String DateOrdered {get;set;}
    public String Status {get;set;}
    public List < Material__c > FullMatList {get;set;}
    public List < Material__c > MaterialList {get;set;}
    public List < Material__c > MaterialListBackup {get;set;}
    //public List < Material__c > MaterialList2 {get;set;}
    public List < Material_Requisition_line_item__c > MatLineItemLeftTable {get;set;}
    public List < Material_Requisition_line_item__c > MatLineItemRightTable {get;set;}
    public List < Material_Requisition_line_item__c > MatLineItemLeftTableBackup {get;set;}
    public List < Material_Requisition_line_item__c > MatLineItemRightTableBackup {get;set;}
    public List < Material_Requisition_line_item__c > MatLineItemLeftTableTemp {get;set;}
    //public List < Material_Requisition_line_item__c > MatLineItemRightTableTemp {get;set;}
    public Map < String, Material_Requisition_line_item__c > MatItemMap {get;set;}
    public List < Material_Requisition_line_item__c > MatLineItemsplit {get;set;}
    public Map < String, Material__c > FullMatListMap {get;set;}
    public Map < String, Material__c > FullMatListMap_With_UOM {get;set;}
    public Map < String, Material_Requisition_line_item__c > MaterialListMap {get;set;}
    public Map < String, Material__c > MaterialIsShowMap {get;set;}
    public List < SelectOption > Shipped {get;set;}
    public List < SelectOption > Returned {get;set;}
    public String searchText {get;set;}
    public List < ATI_Job__c > JobNameList {get;set;}
    //public Boolean IsNew {get;set;}
    public List < String > JobListStr {get;set;}
    public Boolean AddedToList {get;set;}
    public String MRId {get;set;}
    public List < Material_Requisition_line_item__c > ExistingMRItem {get;set;}
    public Map < String, Material_Requisition_line_item__c > ExistingMRItemMap {get;set;}
    public Material_Requisition__c ExistingMR {get;set;}
    public Set < Material_Requisition_line_item__c > ItemToDelete {get;set;}
    public Boolean DisableSave{get;set;}
    public String CollapsibleLabel{get;set;}
    public List<PermissionSetAssignment> permissionSetIds{get;set;}
    public List<PermissionSet> permissionSetList{get;set;}
    @RemoteAction public Boolean DeviceRenderer{get;set;}
    public Boolean UnitCostRenderer{get;set;}
    
    /// <OBJECTIVE>
    /// This Wrapper class gets Job Id, Job Name and pass the values to MR UI.Used for autocomplete feature as the One App users does not have access to ATI_Job__c object
    /// </OBJECTIVE>
    public class OppWrapClass
    {
        public String label{get;set;}
        public String Name{get;set;}
        public Id value{get;set;}
    }
        
    public MRController() 
    {

        MaterialList = new List < Material__c > ();
        FullMatList = new List < Material__c > ();
        MaterialIsShowMap = new Map < String, Material__c > ();
        MatLineItemLeftTable = new List < Material_Requisition_line_item__c > ();
        MatLineItemRightTable = new List < Material_Requisition_line_item__c > ();
        MatLineItemLeftTableBackup = new List < Material_Requisition_line_item__c > ();
        MatLineItemRightTableBackup = new List < Material_Requisition_line_item__c > ();
        FullMatListMap = new Map < String, Material__c > ();
        FullMatListMap_With_UOM = new Map < String, Material__c > ();
        JobNameList = new List < ATI_Job__c > ();
        ExistingMRItem = new List < Material_Requisition_line_item__c > ();
        ExistingMRItemMap = new Map < String, Material_Requisition_line_item__c > ();
        ExistingMR = new Material_Requisition__c();
        Shipped = new List < SelectOption > ();
        Returned = new List < SelectOption > ();
        Location = new List < SelectOption > ();
        LocationList = new List < MRLocation__c > ();
        LocationCodeList = new List <Location_Code__c > ();
        DisableSave = false;
        CollapsibleLabel = 'More Details';
        DeviceRenderer = true;
        permissionSetIds = new List<PermissionSetAssignment>();
        permissionSetList = new List<PermissionSet>();
        UnitCostRenderer = false;
        
        try
       {
            //Gets the record Id for the existing MR
            MRId = ApexPages.Currentpage().getparameters().get('MRId');
            
            //Gets the list of users assigned to the permission set 'MR_UnitCost_Access' and sets  
            //UnitCostRenderer which will be used to render the column 'unit cost' in MR UI
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
        
            //Gets the Existing MR if MRId is not null
            if (MRId != null && MRId != '') 
            {
                ExistingMRItem = PRLDE_DataUtility.fetchMRItem(MRId);
                ExistingMR = PRLDE_DataUtility.fetchMRWithId(MRId);
                if (ExistingMR != null && ExistingMR.Status__c == 'In Progress') 
                {
                    JobName = ExistingMR.ATI_Job__r.Job_Name__c;
                    JobNumber = ExistingMR.ATI_Job__r.Job_Number__c;
                    Status = ExistingMR.Status__c;
                    
                    DateTime JobDt = DateTime.newInstance(ExistingMR.CreatedDate.year(),ExistingMR.CreatedDate.month(),ExistingMR.CreatedDate.day());
    
                    DateOrdered = JobDt.format('MM/dd/yyyy');
                    JobId = ExistingMR.ATI_Job__c;
                    
                    // Fetches the list of Locations based on Job's 'Office' and 'Division' 
                    LocationList = PRLDE_DataUtility.fetchLocation(ExistingMR.ATI_Job__r.Office2__c, ExistingMR.ATI_Job__r.Division__c);
                   
                    if(ExistingMR.LocationCode__c != null)
                    {
                        // Adds the existing MR Location as the selected Location value
                        Location.add(new SelectOption(ExistingMR.Locationcode__c, ExistingMR.Locationcode__r.Description__c));
                        LocationCodeList = PRLDE_DataUtility.fetchAllLocationCodes(ExistingMR.Locationcode__r.Description__c);
                        //LocationList.sort();
                        
                        for (Location_code__c loc: LocationCodeList) 
                        {    
                                Location.add(new SelectOption(loc.Id, loc.Description__c));
                        }
                    }
                    else
                    {
                        for (MRLocation__c loc: LocationList) 
                        {
                            // Adds the Default Location as the selected Location value
                            if (loc.IsDefault__c == true) {
                                Location.add(new SelectOption(loc.Locationcode__c, loc.Locationcode__r.Description__c));
                            }
                        }
                        
                        //LocationList.sort();
                        if(Location.size() > 0)
                        {
                             LocationCodeList = PRLDE_DataUtility.fetchAllLocationCodes(Location[0].getLabel());
                        } 
                        else
                        {
                            LocationCodeList = PRLDE_DataUtility.fetchAllLocationCodes('');
                        }    
                        for (Location_Code__c loc: LocationCodeList) 
                        {
                                Location.add(new SelectOption(loc.Id, loc.Description__c));
                        }
                    
                    }
                    
                    for (Material_Requisition_line_item__c ItemLst: ExistingMRItem) 
                    {
                        ExistingMRItemMap.put(ItemLst.Name, ItemLst);
                    }
                }
            }
            
            system.debug('==ExistingMR== ' + ExistingMR);
            
            if ((MRId == null || MRId == '') || (ExistingMR != null && ExistingMR.Status__c == 'In Progress')) 
            {
                //Adds the default set of picklist values to Shipped and Returned [1 to 10]
                for (Integer i = 0; i <= 10; i++) 
                {
                    if (i == 0) 
                    {
                        Shipped.add(new SelectOption('', ''));
                        Returned.add(new SelectOption('', ''));
                    } else 
                    {
                        Shipped.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
                        Returned.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
                    }
                }
                
                // Fetches the full list of Materials from DB irrespective of IsShow value
                FullMatList = PRLDE_DataUtility.fetchAllMaterials();
    
                for (Material__c fullMap: FullMatList) 
                {
                    FullMatListMap.put(fullMap.Description__c, fullMap);
                    FullMatListMap_With_UOM.put(fullmap.Description__c + ' - ' + fullMap.Unit_Of_Measurement__c, fullMap);
                }
    
                getMRItemList();
                
            }
            
       }
        catch(Exception e)
        {
        
        }
    }
    
    /// <OBJECTIVE>
    /// This method fetches the list of Material Line items on initial load
    /// </OBJECTIVE>
    
    public void getMRItemList() {
        
        // Fetches the list of Materials from DB where IsShow is set to true
        MaterialList = PRLDE_DataUtility.fetchShowMaterials();
        
        MaterialListBackup = new List < Material__c > ();
        MatLineItemLeftTableBackup = new List < Material_Requisition_line_item__c > ();
        MatLineItemRightTableBackup = new List < Material_Requisition_line_item__c > ();

        // Divides the Materials into two equal halves and display in Left and Right Material Line Item table
        for (Integer i = 0; i < MaterialList.size(); i++) 
        {

            MaterialIsShowMap.put(MaterialList[i].Description__c + ' - ' + MaterialList[i].Unit_of_Measurement__c, MaterialList[i]);
            Material_Requisition_line_item__c mItem = new Material_Requisition_line_item__c();
            String MatDesc = MaterialList[i].Description__c + ' - ' + MaterialList[i].Unit_of_Measurement__c;

            if (ExistingMRItemMap != null && ExistingMRItemMap.size() > 0 && ExistingMRItemMap.get(MatDesc) != null) 
            {
                mItem = ExistingMRItemMap.get(MatDesc);
                ExistingMRItemMap.remove(MatDesc);
            } else 
            {
                mItem.Name = MatDesc;
                mItem.IsPicklist__c = MaterialList[i].IsPicklist__c;
                mItem.Unit_Cost__c = MaterialList[i].Unit_Cost__c;
            }

            if (i == 0) 
            {
                MatLineItemLeftTable.add(mItem);
            } 
            else if (i == 1 && MaterialList.size() == 2) 
            {
                MatLineItemRightTable.add(mItem);
            } 
            else 
            {

              /*  if (Math.mod(i, 2) == 0) 
                {
                    MatLineItemLeftTable.add(mItem);
                } else 
                {
                    MatLineItemRightTable.add(mItem);
                } */
                
                if(i < (MaterialList.size())/2)
                {
                    MatLineItemLeftTable.add(mItem);
                }
                else
                {
                    MatLineItemRightTable.add(mItem);
                }
            }
        }
        // To add IsShow false materials to the list
        for(Integer i = 0; i<ExistingMRItemMap.values().size(); i++)
        {
            if (i == 0) 
            {
                MatLineItemLeftTable.add(ExistingMRItemMap.values()[i]);
            } 
            else if (i == 1 && ExistingMRItemMap.values().size() == 2) 
            {
                MatLineItemRightTable.add(ExistingMRItemMap.values()[i]);
            } else 
            {

              /*  if (Math.mod(i, 2) == 0) 
                {
                    MatLineItemLeftTable.add(ExistingMRItemMap.values()[i]);
                } else 
                {
                    MatLineItemRightTable.add(ExistingMRItemMap.values()[i]);
                } */
                
                if(i < (ExistingMRItemMap.values().size())/2)
                {
                    MatLineItemLeftTable.add(ExistingMRItemMap.values()[i]);
                }
                else
                {
                    MatLineItemRightTable.add(ExistingMRItemMap.values()[i]);
                }
            }
        }

        //Take a backup of the Original MaterialList,MatLineItemLeftTable and MatLineItemRightTable
        MaterialListBackup.addAll(MaterialList);
        MatLineItemLeftTableBackup.addAll(MatLineItemLeftTable);
        MatLineItemRightTableBackup.addAll(MatLineItemRightTable);
        system.debug('==MatLineItemLeftTable== ' + MatLineItemLeftTable);
        system.debug('==MatLineItemRightTable== ' + MatLineItemRightTable);

    }

    /// <OBJECTIVE>
    /// This method performs a search in the backend with the searchtext and displayes the related Materials in MR UI.
    /// </OBJECTIVE>
    
    public void SearchByMaterialName() 
    {
        try
        {
            // When the user searches for a Material/Line item, save button will be disabled
            DisableSave = true;
            system.debug(Logginglevel.info,'JobLocation -- '+JobLocation);
            
            if (AddedToList == true) 
            {
                MaterialListBackup = new List < Material__c > ();
                MatLineItemLeftTableBackup = new List < Material_Requisition_line_item__c > ();
                MatLineItemRightTableBackup = new List < Material_Requisition_line_item__c > ();
                MaterialListBackup.addAll(MaterialList);
                MatLineItemLeftTableBackup.addAll(MatLineItemLeftTable);
                MatLineItemRightTableBackup.addAll(MatLineItemRightTable);
            }
    
            MatLineItemLeftTable = new List < Material_Requisition_line_item__c > ();
            MatLineItemRightTable = new List < Material_Requisition_line_item__c > ();
            MaterialList = new List < Material__c > ();
            MaterialListMap = new Map < String, Material_Requisition_line_item__c > ();
            MatLineItemsplit = new List < Material_Requisition_line_item__c > ();
            
            SearchText = SearchText.trim();
            //Searches the search text in the Left backup table 
            for (Material_Requisition_line_item__c item: MatLineItemLeftTableBackup) {
                if (item.Name.containsIgnoreCase(SearchText)) {
                    Material_Requisition_line_item__c itemToAddLft = new Material_Requisition_line_item__c(Name = item.Name, IsPicklist__c = item.IsPicklist__c, Unit_Cost__c = item.Unit_Cost__c, Shipped__c = item.Shipped__c, Returned__c = item.Returned__c);
                    MatLineItemsplit.add(itemToAddLft);
                    MaterialListMap.put(itemToAddLft.Name, itemToAddLft);
                }
    
            }
            //Searches the search text in the Right backup table
            for (Material_Requisition_line_item__c item: MatLineItemRightTableBackup) {
                if (item.Name.containsIgnoreCase(SearchText)) {
                    Material_Requisition_line_item__c itemToAddRgt = new Material_Requisition_line_item__c(Name = item.Name, IsPicklist__c = item.IsPicklist__c, Unit_Cost__c = item.Unit_Cost__c, Shipped__c = item.Shipped__c, Returned__c = item.Returned__c);
                    MatLineItemsplit.add(itemToAddRgt);
                    MaterialListMap.put(itemToAddRgt.Name, itemToAddRgt);
                }
    
            }
            
    
            //Searches the search text in the Materials table where IsShow is set to false
            for (Material__c fullLst: FullMatListMap.values()) {
                String compareStr = fullLst.Description__c + ' - ' + fullLst.Unit_of_Measurement__c;
    
                if (MaterialListMap.get(compareStr) == null && compareStr.containsIgnoreCase(SearchText)) {
                    MatLineItemsplit.add(new Material_Requisition_line_item__c(Name = compareStr, IsPicklist__c = fullLst.IsPicklist__c, Unit_Cost__c = fullLst.Unit_Cost__c));
                    MaterialListMap.put(compareStr, new Material_Requisition_line_item__c(Name = compareStr, IsPicklist__c = fullLst.IsPicklist__c, Unit_Cost__c = fullLst.Unit_Cost__c));
    
                }    
            }
            
            if (MatLineItemsplit.size() > 5 && MatLineItemsplit.size() <= 10) {
                for (Integer i = 0; i < MatLineItemsplit.size(); i++) 
                {
                   /* if (Math.mod(i, 2) == 0) 
                    {
                        MatLineItemLeftTable.add(MatLineItemsplit[i]);
                    } else {
                        MatLineItemRightTable.add(MatLineItemsplit[i]);
                    } */
                    
                    if( i < (MatLineItemsplit.size())/2)
                    {
                        MatLineItemLeftTable.add(MatLineItemsplit[i]);
                    }
                    else
                    {
                        MatLineItemRightTable.add(MatLineItemsplit[i]);
                    }
    
                }
    
            } else {
                for (Integer i = 0; i < MatLineItemsplit.size(); i++) {
                    MatLineItemLeftTable.add(MatLineItemsplit[i]);
                }
            }
            
            //Sort the table in asc when searched the materials
            MatLineItemLeftTable.sort();
            
            
            AddedToList = false;
            
            
        }
        catch(Exception e)
        {
        
        }
    }
    
   
    
    /// <OBJECTIVE>
    /// This method is called when the user clicks on 'Add to List' in MR UI.
    /// This method checks for the non zero values in shipped and returned column in Left and Right Material line item table and adds the respective materials
    /// </OBJECTIVE>
    
    public void SearchComplete() 
    {    
        try
        {
            // Add to List button enables back the 'Save' button
            DisableSave = false;
            
            // Checks for non zero shipped and returned values
            if ((MatLineItemLeftTable.size() > 0 || MatLineItemRightTable.size() > 0) && (MatLineItemRightTableBackup.size() > 0 || MatLineItemLeftTableBackup.size() > 0)) 
            {
    
                MatItemMap = new Map < String, Material_Requisition_line_item__c > ();
    
                MatLineItemLeftTableTemp = new List < Material_Requisition_line_item__c > ();
                for (Material_Requisition_line_item__c item: MatLineItemLeftTable) {
                        MatItemMap.put(item.Name, item);
                }
    
                for (Material_Requisition_line_item__c item: MatLineItemRightTable) {
                        MatItemMap.put(item.Name, item);
                }
    
                // Compares the newly entered shipped and returned values with the existing vales and updates the original line item list
                for (Material_Requisition_line_item__c item: MatLineItemLeftTableBackup) {
                    if (MatItemMap.get(item.Name) != null) {
                        system.debug('MatLineItemLeftTableBackup compare :' + item);
                        Material_Requisition_line_item__c itemCompare = new Material_Requisition_line_item__c();
                        itemCompare = MatItemMap.get(item.Name);
                        item.Shipped__c = itemCompare.Shipped__c;
                        item.Returned__c = itemCompare.Returned__c;
                        MatItemMap.remove(item.Name);
                    }
    
                }
    
                for (Material_Requisition_line_item__c item: MatLineItemRightTableBackup) {
                    if (MatItemMap.get(item.Name) != null) {
                        system.debug('MatLineItemRightTable compare :' + item);
                        Material_Requisition_line_item__c itemCompare = new Material_Requisition_line_item__c();
                        itemCompare = MatItemMap.get(item.Name);
                        item.Shipped__c = itemCompare.Shipped__c;
                        item.Returned__c = itemCompare.Returned__c;
                        MatItemMap.remove(item.Name);
                    }
    
                }
    
                system.debug('==MatItemMap== ' + MatItemMap);
                MatLineItemLeftTable = new List < Material_Requisition_line_item__c > ();
                MatLineItemRightTable = new List < Material_Requisition_line_item__c > ();
                
                // Splits and displays the line items in left and right tables
                for (Integer i = 0; i < MatItemMap.size(); i++) 
                {
                if(MatItemMap.values()[i].Shipped__c != null || MatItemMap.values()[i].Returned__c != null)
                    {
                        if (i == 0) {
                            MatLineItemLeftTable.add(MatItemMap.values()[i]);
                        } else if (i == 1 && MatItemMap.size() == 2) {
                            MatLineItemRightTable.add(MatItemMap.values()[i]);
                        } else 
                        {
                          /*if (Math.mod(i, 2) == 0) 
                            {
                                MatLineItemLeftTable.add(MatItemMap.values()[i]);
                            } 
                            else 
                            {
                                MatLineItemRightTable.add(MatItemMap.values()[i]);
                            } */
                            if(i < (MatItemMap.size())/2)
                            {
                                MatLineItemLeftTable.add(MatItemMap.values()[i]);
                            }
                            else
                            {
                                MatLineItemRightTable.add(MatItemMap.values()[i]);
                            }
                        }
                    }
                }
                // Adds the old backup values to Left and Right Tables
                MatLineItemLeftTable.addAll(MatLineItemLeftTableBackup);
                MatLineItemRightTable.addAll(MatLineItemRightTableBackup);
                //To remove IsShow false quantities from the list where the shipped and returned values are null
                //MatLineItemLeftTable.sort();
                //MatLineItemRightTable.sort();
                QuantityChangeUpdate();
                
                // To sort the Line items and add them to Left and Right tables
                Map<String,Material_Requisition_line_item__c> LineItemMap = new Map<String,Material_Requisition_line_item__c>();
                List<String> LineItemList = new List<String>();
                
                for(Material_Requisition_line_item__c lItem : MatLineItemLeftTable)
                {
                    LineItemMap.put(lItem.Name,lItem);
                    LineItemList.add(lItem.Name);
                }
                for(Material_Requisition_line_item__c lItem : MatLineItemRightTable)
                {
                    LineItemMap.put(lItem.Name,lItem);
                    LineItemList.add(lItem.Name);
                }
                LineItemList.sort();
                
                MatLineItemLeftTable = new List < Material_Requisition_line_item__c > ();
                MatLineItemRightTable = new List < Material_Requisition_line_item__c > ();
                
                for(Integer i = 0; i < LineItemList.size(); i++ )
                {
                    if(i == 0)
                    {
                        MatLineItemLeftTable.add(LineItemMap.get(LineItemList[i]));
                    }
                    else if(i == 1 && LineItemList.size() == 2)
                    {
                        MatLineItemRightTable.add(LineItemMap.get(LineItemList[i]));
                    }
                    else
                    {
                        if(i < LineItemList.size()/2)
                        {
                            MatLineItemLeftTable.add(LineItemMap.get(LineItemList[i]));
                        }
                        else
                        {
                            MatLineItemRightTable.add(LineItemMap.get(LineItemList[i]));
                        }
                    }
                }
            }
            // Removes the search text with on click of Add to List button
            searchText = null;
            AddedToList = true;
        }
        catch(Exception e)
        {
        
        }
    }

    /// <OBJECTIVE>
    /// This method clears the search text and displays the old list
    /// </OBJECTIVE>
    
    public void ClearSearch() {
        try
        {
            DisableSave = false;
            
            MatLineItemLeftTable = new List < Material_Requisition_line_item__c > ();
            MatLineItemRightTable = new List < Material_Requisition_line_item__c > ();
    
            MatLineItemLeftTable.addAll(MatLineItemLeftTableBackup);
            MatLineItemRightTable.addAll(MatLineItemRightTableBackup);
    
            searchText = null;
            AddedToList = false;
        }
        catch(Exception e)
        {
        
        }
    }
    
    /// <OBJECTIVE>
    /// This method is called when any of the shipped or returned quantity is made null. 
    /// This method removes the materials where IsShow is set to false from the original list when the quantities are made null.
    /// </OBJECTIVE>
    
    public void QuantityChangeUpdate() {
        try
        {
            // Checks for removed quantities in Left table
            if (MatLineItemLeftTable.size() > 0) {
                for (Integer j = 0; j < MatLineItemLeftTable.size(); j++) 
                {
                    If((MatLineItemLeftTable[j].Shipped__c == null) && (MatLineItemLeftTable[j].Returned__c == null)) 
                    {
                        if (MaterialIsShowMap.size() > 0 && MaterialIsShowMap.get(MatLineItemLeftTable[j].Name) == null) 
                        {
                            MatLineItemLeftTable.remove(j);
                            j--;
                        }
                    }
                }
            }
            //MatLineItemLeftTable.sort();
            
            // Checks for removed quantities in Right table
            if (MatLineItemRightTable.size() > 0) {
                for (Integer j = 0; j < MatLineItemRightTable.size(); j++) {
                    If((MatLineItemRightTable[j].Shipped__c == null) && (MatLineItemRightTable[j].Returned__c == null)) {
                        if (MaterialIsShowMap.size() > 0 && MaterialIsShowMap.get(MatLineItemRightTable[j].Name) == null) {
                            MatLineItemRightTable.remove(j);
                            j--;
                        }
                    }
                }
    
            }
            //MatLineItemRightTable.sort();
            AddedToList = false;
        }
        catch(Exception e)
        {
        
        }
    }

    /// <OBJECTIVE>
    /// This method saves the form with new changes and redirects the user to MR Summary UI.
    /// </OBJECTIVE>
    
    public PageReference FormSave() {
        try
        {
            DisableSave = false;
            // If the form is saved without selecting a job, an error will be thrown
            if ((JobName != null && JobName != '') && ((JobNumber != '' && JobNumber != null) && (DateOrdered != '' && DateOrdered != null) && (Status != '' && Status != null))) {
                
                if(JobLocation == '')
                {
                    JobLocation = null;
                }
                //Upserts the MR with the given values
                Material_Requisition__c MR = PRLDE_DataUtility.UpsertMR(JobId, Status, MRId, JobLocation);
                
                //Fetches the MR with the MR Id. Used to update the MR Name
                List < Material_Requisition__c > MRObjList = PRLDE_DataUtility.fetchMR(null, null, 1, null, null, null, MR.Id);
                system.debug('++++++++'+MRObjList.size());
                if (MRObjList.size() > 0) 
                {
                    // Updates MR Name in the pattern <MR>-<JobName>-<AutoNumber>
                   // PRLDE_DataUtility.UpdateMR(MRObjList[0]);
                    
                    system.debug('==MRObjList[0]== '+MRObjList[0]);
    
                    List < Material_Requisition_line_item__c > ItemListToUpdate = new List < Material_Requisition_line_item__c > ();
                    
                    // Creates a list with the list of line items to Update. If the given Shipped and Returned value is less than 0, an error message will be thrown
                    for (Material_Requisition_line_item__c item: MatLineItemLeftTable) {
                        If((item.Shipped__c != null) || (item.Returned__c != null)) {
                            
                            Material__c MatLft = FullMatListMap_With_UOM.get(item.Name);
                            if (MatLft != null) {
                                Material_Requisition_line_item__c MR_ItemLft = new Material_Requisition_line_item__c();
    
                                MR_ItemLft = item;
                                MR_ItemLft.Material__c = MatLft.Id;
                                MR_ItemLft.Description__c = MatLft.Description__c;
                                MR_ItemLft.IsPicklist__c = MatLft.IsPicklist__c;
                                MR_ItemLft.Shipped__c = item.Shipped__c;
                                MR_ItemLft.Returned__c = item.Returned__c;
                                MR_ItemLft.Unit_Cost__c = item.Unit_Cost__c;
    
                                if (MR_ItemLft.Material_Requisition__c == null)
                                    MR_ItemLft.Material_Requisition__c = MRObjList[0].Id;
    
                                MR_ItemLft.Name = item.Name;
                                ItemListToUpdate.add(MR_ItemLft);
                            }
                        
                        }
                    }
    
                    for (Material_Requisition_line_item__c item: MatLineItemRightTable) 
                    {
                        If((item.Shipped__c != null) || (item.Returned__c != null)) {
                        
                            Material__c MatRgt = FullMatListMap_With_UOM.get(item.Name);
                            if (MatRgt != null) {
                                Material_Requisition_line_item__c MR_ItemRgt = new Material_Requisition_line_item__c();
    
                                MR_ItemRgt = item;
                                MR_ItemRgt.Material__c = MatRgt.Id;
                                MR_ItemRgt.Description__c = MatRgt.Description__c;
                                MR_ItemRgt.IsPicklist__c = MatRgt.IsPicklist__c;
                                MR_ItemRgt.Shipped__c = item.Shipped__c;
                                MR_ItemRgt.Returned__c = item.Returned__c;
                                MR_ItemRgt.Unit_Cost__c = item.Unit_Cost__c;
    
                                if (MR_ItemRgt.Material_Requisition__c == null)
                                    MR_ItemRgt.Material_Requisition__c = MRObjList[0].Id;
    
                                MR_ItemRgt.Name = item.Name;
                                ItemListToUpdate.add(MR_ItemRgt);
                            }
                        }
                     
                    }
    
                    // Creates a list with the list of items to delete - New changes
                    ItemToDelete = new Set < Material_Requisition_line_item__c > ();
                    ItemToDelete.addAll(ExistingMRItem);
                    ItemToDelete.removeAll(ItemListToUpdate);
    
                    system.debug('== ApexPages.getMessages() ApexPages.hasMessages()' + ApexPages.getMessages() + ApexPages.hasMessages());
                    
                    // Checks if the form has any ERROR messages and if returned false, it redirects the user to Summary UI
                    if (ApexPages.hasMessages() == false) {
                        PRLDE_DataUtility.DeleteMRItem(ItemToDelete);
                        PRLDE_DataUtility.UpsertMRLineItem(ItemListToUpdate);
                        pageReference pgRef = new PageReference('/apex/MR_Summary_UI?MRId=' + MRObjList[0].Id);
                        pgRef.setRedirect(true);
                        return pgRef;
                    } else 
                    {
                        return null;
                    }
                } else {
                    return null;
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a valid job Name'));
                return null;
            }
        }
        catch(Exception e)
        {
            return null;
        
        }
    }
    
    /// <OBJECTIVE>
    /// This method cancels the form with new changes and redirects the user to MR List view.
    /// </OBJECTIVE>
    
    public PageReference Cancel() {
        try
        {
            pageReference pg;
            // If it is a new form, redirects the user to list UI
            if(MRId == null || MRId == '')
            {
                pg = new PageReference('/apex/MR_List_view');
            }
            // If it is an existing form, redirects the user to Summary UI
            else
            {
                pg = new PageReference('/apex/MR_Summary_UI?MRId=' + MRId);
            }
            pg.setRedirect(true);
            return pg;
        }
        catch(Exception e)
        {
             return null;
        }
    }

       
    /// <OBJECTIVE>
    /// This method fetches the list of opportunities based on the given partial job text in MR UI. Used for autoComplete feature.
    /// </OBJECTIVE>
    
    @RemoteAction
    public static List<OppWrapClass> getMatchedOpportunityList(String strSearchString) {
        try
        {
            List<OppWrapClass> Opplst = new List<OppWrapClass>();
            
            for (ATI_Job__c job: PRLDE_DataUtility.fetchOpp(strSearchString, 10)) 
            {
                OppWrapClass OppObj = new OppWrapClass();
                
                OppObj.Name = job.Job_Name__c;
                OppObj.label = job.Name;
                OppObj.value = job.Id;
                Opplst.add(OppObj);
            }
            system.debug('==Opplst== '+Opplst);
            return Opplst;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
    
    /// <OBJECTIVE>
    /// This method autopopulates the job details based on the selected JobName.
    /// </OBJECTIVE>
    
    public void getJobDetails() 
    {
        
        try
        {
            system.debug('==JobName + JobId== ' + JobName+JobId);
            
            if (JobId != null && JobId != '' && JobName != null && JobName != '') 
            {
                // Fetches and assigns the Job details with the obtained JobId
                JobNameList = PRLDE_DataUtility.fetchJobWithId(JobId, 1);
                DateTime TodayDate = DateTime.newInstance(Date.today().year(),Date.today().month(),Date.today().day());
                
                LocationList.clear();
                Location.clear();
                JobLocation ='';
                if (JobNameList.size() > 0) {
                    JobNumber = JobNameList[0].Job_Number__c;
                    JobName = JobNameList[0].Job_Name__c;
                    Status = 'In Progress';
                    
                    If(ExistingMR != null && ExistingMR.CreatedDate != null)
                    {
                        system.debug('==ExistingMR== '+ExistingMR);
                        DateTime d = DateTime.newInstance(ExistingMR.CreatedDate.year(),ExistingMR.CreatedDate.month(),ExistingMR.CreatedDate.day());
                        DateOrdered = d.format('MM/dd/yyyy');
                    }
                    else
                    {
                        DateOrdered = TodayDate.format('MM/dd/yyyy');
                    }
                    
                    LocationList = PRLDE_DataUtility.fetchLocation(JobNameList[0].Office2__c, JobNameList[0].Division__c);
                    for (MRLocation__c loc: LocationList) {
                        if (loc.IsDefault__c == true) {
                            system.debug('-----Selected Value' + loc.Locationcode__c +'---'+loc.Locationcode__r.Description__c);
                            Location.add(new SelectOption(loc.Locationcode__c, loc.Locationcode__r.Description__c));
                        }
                    }
                    if(Location.size() > 0)
                    {
                        system.debug('Location[0].getValue()'+Location[0].getValue());
                        LocationCodeList = PRLDE_DataUtility.fetchAllLocationCodes(Location[0].getLabel());
                    
                        for (Location_code__c loc: LocationCodeList) {                            
                           Location.add(new SelectOption(loc.Id, loc.Description__c));
                        }

                    }
                    else
                    {
                        LocationCodeList = PRLDE_DataUtility.fetchAllLocationCodes('');
                        for (Location_code__c loc: LocationCodeList) {                            
                           Location.add(new SelectOption(loc.Id, loc.Description__c));
                        }
                    }
                } else {
                    JobNumber = '';
                    Status = '';
                    DateOrdered = '';
                    Location.clear();
                }
                
            } else {
                JobNumber = '';
                Status = '';
                DateOrdered = '';
                Location.clear();
            } 
        }
        catch(Exception e)
        {
        
        }
    }
}