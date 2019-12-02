/**
 * @author           Kanitha Priya P.
 * @version          1.0 
 * @date             19/8/2017
 * @Status           In Progress
 * @description      Test Data Utility class fetches data from objects and performs DML operations for objects used in Test classes.
 */
 
 public with sharing class PRLDE_TestDataUtility
 {
     
    /// <OBJECTIVE>
    /// Inserts the RecordType. 
    /// </OBJECTIVE>    
    
    public static RecordType FetchRecordType(String sObj,String TypeName)
    {
     
     RecordType AccRecType = [select Id,Name from RecordType where name =: TypeName and SobjectType =:sObj];
     Return AccRecType;
    }
    
    public static Account InsertAccount(RecordType RecType,String Type,String AccName,String Phone,String BillStreet,String BillCity,String BillState,String BillPostCode,String BillCountry)
    {
        Account Acc = new Account(RecordType = RecType,Name = AccName,Type = Type,Phone = Phone,BillingStreet = BillStreet,BillingCity = BillCity,BillingState = BillState,BillingPostalCode = BillPostCode,BillingCountry = BillCountry);
        Insert Acc;
        Return Acc;
    }
    
    public static ATI_Job__c InsertJob(RecordType RecType,String Name,Account Acc,Id office,String JobName,String JobNumber,Id ContactId,String Div)
    {
        ATI_Job__c Opp = new ATI_Job__c(RecordType = RecType,Name = Name,Account__c = Acc.Id,Office2__c = office,Job_Name__c = JobName,Job_Number__c = JobNumber,Stage__c = 'Estimating',CloseDate__c = Date.Today(),Project_Site_Contact_Name__c = ContactId,Project_Site_Contact_Account__c = Acc.id,Division__c = Div);
        Insert Opp;
        Return Opp;    
    }
    
    public static Material_Requisition__c InsertMR(Id JobId,String Status,Id LocId,String Name)
    {
        Material_Requisition__c MR = new Material_Requisition__c(ATI_Job__c = JobId,Status__c = Status,LocationCode__c = LocId,Name = Name);
        Insert MR;
        Return MR;
    
    }
    
    public static Material_Requisition_line_item__c InsertMRItem(String Name,String Description,Integer Shipped,Integer Returned,Id Mat)
    {
        Material_Requisition_line_item__c MRItem = new Material_Requisition_line_item__c(Name = Name,Description__c = Description,Shipped__c = Shipped,Returned__c = Returned,Material__c = Mat);
        Insert MRItem;
        Return MRItem;
    }
    
    public static Material__c InsertMaterial(String Name,Integer ItemCode,String UOM,Boolean IsShow,Boolean IsPicklist,String Description)
    {
        Material__c Mat = new Material__c(Name = Name,Item_Code__c = ItemCode,Unit_of_Measurement__c = UOM,IsShow__c =IsShow,IsPicklist__c = IsPicklist,Description__c = Description);
        Insert Mat;
        Return Mat;
    }
    
    public static Office__c InsertOffice(String Name,String address,String Region,String State)
    {
        Office__c Off = new Office__c(Name = Name,Address__c = address,Region__c = Region,State__c = State);
        Insert Off;
        Return Off;
    }
    
    public static Contact InsertContact(String FirstName,String LastName,Id AccId,String Phone)
    {
         Contact con = new Contact(FirstName = FirstName,LastName = LastName,AccountId = AccId,Phone = Phone);
         Insert con;
         Return con;
    }
    
    public static User FetchUser(Id userId)
    {
        User usr = [Select Id from User where Id = :userId];
        Return usr;
    }
    
    public static TriggerStatus__c InsertTrgSetting(Boolean JobNum)
    {
        TriggerStatus__c testSetting = new TriggerStatus__c();
        testSetting.JobSetJobNumber__c = JobNum;
        
        Insert testSetting;
        Return testSetting;
    
    }
    
    /// <OBJECTIVE>
    /// Insert a Materials record 
    /// </OBJECTIVE>    
    public static Material__c InsertMaterial(string Name,string Description,Decimal ItemCode,boolean IsPickList,Boolean IsShow,String UOM,Decimal UnitCost)
    {
         
         Material__c  Material = new Material__c();
         
         Material.Name = Name;
         Material.Item_Code__c = ItemCode;
         Material.IsPicklist__c = IsPicklist;
         Material.IsShow__c = IsShow;         
         Material.Unit_of_Measurement__c = UOM;
         Material.Unit_Cost__c = UnitCost;
         Material.Description__c = Description;
         
         
         Insert Material;
         return Material;
    }
    
     /// <OBJECTIVE>
    /// Insert a Materials record 
    /// </OBJECTIVE>    
    public static Material_Requisition_line_item__c InsertMateriallineitem(string Name,string Description,boolean IsPickList, Decimal shipped, Decimal Returned,Decimal UnitCost,Id MRId)
    {
         
         Material_Requisition_line_item__c  Item = new Material_Requisition_line_item__c();
         
         Item.Name = Name;
         Item.IsPicklist__c = IsPicklist;
         Item.Shipped__c = Shipped;
         Item.Returned__c = Returned;
         Item.Unit_Cost__c = UnitCost;
         Item.Description__c = Description;
         Item.Material_Requisition__c = MRId;
         
         Insert Item;
         return Item;
    }
    /// <OBJECTIVE>
    /// Insert a Office record 
    /// </OBJECTIVE>
    public static Office__c InsertOffice(string name,string address,string licenseno,string state,string region)
    {
        Office__c office = new Office__c();
        office.Name = name;
        office.Address__c = address;
        office.License_No__c = licenseno;
        office.State__c = state;
        office.Region__c = region;
        
        insert office;
        return office;
    }
    
    /// <OBJECTIVE>
    /// Insert a MRLocation record 
    /// </OBJECTIVE>
    public static MRLocation__c InsertMRLocation(string name,string officeId,string division,Boolean deflt,Id locCode)
    {
        MRLocation__c MRLoc = new MRLocation__c();
        //MRLoc.Name = name;
        MRLoc.Office__c = officeId;
        MRLoc.Division__c = division;
        MRLoc.IsDefault__c = deflt;
        MRLoc.Locationcode__c = locCode;
        
        insert MRLoc;
        return MRLoc;
    }
    
    /// <OBJECTIVE>
    /// Insert a Location code 
    /// </OBJECTIVE>
    public static Location_Code__c InsertLocationCode(string name,string Description)
    {
        Location_Code__c Loc = new Location_Code__c();
        Loc.Name = name;
        Loc.Description__c = Description;
        
        insert Loc;
        return Loc;
    }
    
    /// <OBJECTIVE>
    /// Fetches the Material Req Batch records 
    /// </OBJECTIVE>
    
    public static List<Material_Req_Batch__c> FetchMRBatch()
    {
         Return [select Id,Name 
                     FROM Material_Req_Batch__c];
    }
    
    /// <OBJECTIVE>
    /// Inserts Batch record 
    /// </OBJECTIVE>
    
    public static Batch__c InsertBatch(Boolean IsSend,String status,DateTime BatchSyncDate)
    {
        Batch__c batch = new Batch__c(Send__c = IsSend,Batch_Status__c = status, Batch_Sync_Date__c = BatchSyncDate);
        insert batch;
        return batch;
    }
    
    /// <OBJECTIVE>
    /// Updates a Batch record 
    /// </OBJECTIVE>
    
    public static Batch__c UpdateBatch(String status,Id batchId,DateTime BatchSyncDate)
    {
        Batch__c batch = new Batch__c(Id = batchId);
        batch.Batch_Status__c = status;
        batch.Batch_Sync_Date__c = BatchSyncDate;
        update batch;
        return batch;
    }
    
    /// <OBJECTIVE>
    /// Inserts Material Req Batch records 
    /// </OBJECTIVE>
    
    public static Material_Req_Batch__c InsertMRBatch(Batch__c batch, Id MRId)
    {
         Material_Req_Batch__c MRReq = new Material_Req_Batch__c(Batch__c = batch.Id,Material_Requisition__c = MRId);
         insert MRReq;
         return MRReq;
    }
    
    /// <OBJECTIVE>
    /// Fetches the Material Requisition records 
    /// </OBJECTIVE>
    
    public static List<Material_Requisition__c> FetchMR(Id MRId)
    {
         Return [select Id,Name,status__c,Batch_Date__c
                     FROM Material_Requisition__c
                 WHERE 
                     Id =:MRId];
    }
   
 }