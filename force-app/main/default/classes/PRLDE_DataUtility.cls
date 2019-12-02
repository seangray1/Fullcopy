/**
 * @author           Gangadhar R.
 * @version          1.0 
 * @date             7/8/2017
 * @Status           Developed
 * @description      Data Utility is a class for fetching data from objects and for performing DML operations in objects.
 */

global with sharing class PRLDE_DataUtility
{
    /// <OBJECTIVE>
    /// Fetch all the materials. 
    /// </OBJECTIVE>    
    
    public static List<Material__c> fetchAllMaterials()
    {
        return [SELECT Description__c,Id,IsPicklist__c,IsShow__c,Item_Code__c,Name,Unit_Cost__c,Unit_of_Measurement__c FROM Material__c ORDER BY Description__c ASC];
           
    }  
    
    /// <OBJECTIVE>
    /// Fetch PermissionSet. 
    /// </OBJECTIVE>    
    
    public static List<PermissionSet> fetchPermissionsetWithName(String perm_Name)
    {
        return [SELECT Id FROM PermissionSet WHERE Name =: perm_Name];
    }  
    
    /// <OBJECTIVE>
    /// Fetch PermissionSet Asignees. 
    /// </OBJECTIVE>    
    
    public static List<PermissionSetAssignment> fetchAllPermissionsetAssignees(String perm_Id)
    {
        return [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :perm_Id];
           
    }  
    
    /// <OBJECTIVE>
    /// Fetch the materials which in show status. 
    /// </OBJECTIVE>    
    
    public static List<Material__c> fetchShowMaterials()
    {
        return [SELECT Description__c,Id,IsPicklist__c,IsShow__c,Item_Code__c,Name,Unit_Cost__c,Unit_of_Measurement__c
                 FROM 
                     Material__c
                 WHERE
                     IsShow__c = True ORDER BY Description__c ASC];
           
    } 
    
    /// <OBJECTIVE>
    /// Fetch List of Opportunities. 
    /// </OBJECTIVE>    
    
    public static List<ATI_Job__c> fetchOpp(String strSearchString,Integer lim)
    {
        return [SELECT Id,Job_Name__c,Job_Number__c,Name 
                 FROM 
                     ATI_Job__c 
                 WHERE
                     Name LIKE :'%'+strSearchString+'%' ORDER BY Job_Name__c ASC NULLS FIRST limit :lim];
           
    }  
    
    /// <OBJECTIVE>
    /// Fetch ATI_Job__c with Job name. 
    /// </OBJECTIVE>    
    
    public static List<ATI_Job__c> fetchJobWithId(String JobId,Integer lim)
    {
        return [SELECT Id,Job_Name__c,Job_Number__c,Office2__c,Division__c 
                 FROM 
                     ATI_Job__c 
                 WHERE
                     Id =:JobId limit :lim];
           
    }

    /// <OBJECTIVE>
    /// Fetch the allowed list of locations from MRLocations with respect to Job's office and Division. 
    /// </OBJECTIVE>    
    
    public static List<MRLocation__c> fetchLocation(Id Off,String Division)
    {
        return [SELECT Id,Office__c,Office__r.Name,Locationcode__c,Locationcode__r.name,Locationcode__r.description__C,Name,Division__c,IsDefault__c 
                 FROM 
                     MRLocation__c
                 WHERE
                     Office__c =:Off and Division__c =:Division ORDER BY Name ASC NULLS FIRST];
           
    }
    
    /// <OBJECTIVE>
    /// Fetch the allowed list of locations from MRLocations with respect to List of Job office and Division. 
    /// </OBJECTIVE>    
    
    /* public static List<MRLocation__c> fetchLocationList(List<Id> Off,List<String> Division)
    {
        return [SELECT Id,Name,IsDefault__c,Office__c,Office__r.Id,Office__r.Name,Division__c,Locationcode__c,Locationcode__r.name,Locationcode__r.description__C 
                 FROM 
                     MRLocation__c
                 WHERE
                     Office__c IN:Off OR Division__c IN:Division ORDER BY Location_description__c ASC];
           
    }
    
    /// <OBJECTIVE>
    /// Update Material Requisition record with MR sequence Name
    /// </OBJECTIVE>
    
     public static Material_Requisition__c UpdateMR(Material_Requisition__c MRObj)
    {    
         Material_Requisition__c MR_obj = new Material_Requisition__c (Id=MRObj.Id);
         MR_obj.Name = 'MR'+'-'+MRObj.Job_Number__c+'-'+MRObj.MR_Auto_Number__c;
         Update MR_obj;
         return MR_obj;
    } */
    
    /// <OBJECTIVE>
    /// Upserts a Material Requisition record 
    /// </OBJECTIVE>
    
    public static Material_Requisition__c UpsertMR(Id JobId,String Status,String MRId,Id Location)
    {
         
         Material_Requisition__c MR = new Material_Requisition__c();
         
         String JobNumber = [SELECT Job_Number_No_Dashes__c FROM ATI_Job__c WHERE Id =: JobId].Job_Number_No_Dashes__c ;
                  
         Integer MRCount = PRLDE_DataUtility.FetchMRCount(JobId);
         
         String MRCountStr= String.valueOf(MRCount+1);
         
         if(MRCountStr.length() == 1)
         {
         MRCountStr = '00' + MRCountStr;
         }
         else if(MRCountStr.length() == 2)
         {
         MRCountStr = '0' + MRCountStr;
         }
         system.debug(Logginglevel.Info,'--MRCountStr'+MRCountStr);
         
         if(MRId != null && MRId != '')
         {
            MR = [select Id,ATI_Job__c,Status__c,LocationCode__c from Material_Requisition__c where Id=: MRId];
         }
         
         system.debug(Logginglevel.Info,'--MR.ATI_Job__c-JobId-'+MR.ATI_Job__c+' '+JobId);
         if(MR.ATI_Job__c != JobId)
         {
             MR.Name = 'MR' + '-' + JobNumber + '-' + MRCountStr;
         }
         MR.ATI_Job__c = JobId;
         MR.Status__c = Status;
         MR.LocationCode__c = Location;
         system.debug(Logginglevel.Info,'--MR.Name'+MR.Name);
         Upsert MR;
         return MR;
    }
    /// <OBJECTIVE>
    /// Fetch the count of Material Requisitions for a Job
    /// </OBJECTIVE>
    public static Integer FetchMRCount(Id JobId)
    {
        List<Material_Requisition__c> MRList = [SELECT Name
                FROM
                    Material_Requisition__c 
                WHERE
                    ATI_Job__c =: JobId];
                    
        Integer count = 0;
        
        if(MRList.size() > 0)
        {
            for(Material_Requisition__c mr_list : MRList)
            {
                if(mr_list.Name.contains('-'))
                {
                    List<string> mr_strlist = mr_list.Name.split('-');
                    string strAutoNumber = '';
                    if(mr_strlist.size() > 2)
                    {
                        strAutoNumber = mr_strlist[2];
                        system.debug(Logginglevel.Info,'--strAutoNumber '+strAutoNumber+ ' '+ count);
                        if(Integer.valueOf(strAutoNumber) > count)
                        {
                            count = Integer.valueOf(strAutoNumber);
                        }
                    }
                }
            }
        }
        return count;
       /* return [SELECT count()
                FROM
                    Material_Requisition__c 
                WHERE
                    Job__c =: JobId]; */
    }
    
    /// <OBJECTIVE>
    /// Upserts a Material Requisition Line Item record 
    /// </OBJECTIVE>
    
    public static List<Material_Requisition_line_item__c> UpsertMRLineItem(List<Material_Requisition_line_item__c> MRLst)
    {
         Upsert MRLst;
         return MRLst;
    }
        
    /// <OBJECTIVE>
    /// Fetch the Recently Viewed Items. 
    /// </OBJECTIVE>   
     
 /*   public static List<RecentlyViewed> fetchRecentItems(String Type,Integer LimitNum)
    {
        return [SELECT Id
                 FROM 
                     RecentlyViewed
                 WHERE
                     Type =: Type 
                 ORDER BY LastViewedDate DESC NULLS FIRST LIMIT :LimitNum];
           
    } */
    
    /// <OBJECTIVE>
    /// Fetch Material Requisition
    /// </OBJECTIVE>   
     
    public static Material_Requisition__c fetchMRWithId(String MR_Id)
    {
        return [SELECT Date_Ordered__c,Id,ATI_Job__c,ATI_Job__r.Job_Number__c,
                    ATI_Job__r.Job_Name__c,ATI_Job__r.Division__c,ATI_Job__r.Office2__c,Status__c,CreatedBy.FirstName,CreatedBy.LastName,MR_Auto_Number__c,LocationCode__c,LocationCode__r.Name,LocationCode__r.description__C,Location_code__c,Location_text__c,CreatedDate
                FROM 
                    Material_Requisition__c 
                WHERE 
                    Id =:MR_Id];
                    
     }
     
    /// <OBJECTIVE>
    /// Fetch Material Requisitions with the List of MR Ids
    /// </OBJECTIVE>   
     
    public static List<Material_Requisition__c> fetchMRWithIdList(List<Id> MRId)
    {
        return [SELECT Id,Name,Status__c,CreatedBy.FirstName,CreatedBy.LastName,Batch_Date__c
                FROM 
                    Material_Requisition__c 
                WHERE 
                    Id IN: MRId];
                    
     }
     
    /// <OBJECTIVE>
    /// Fetch Material Req Batches with the List of related Batches
    /// </OBJECTIVE>   
     
    public static List<Material_Req_Batch__c> fetchMRReqWithBatchList(List<Batch__c> batch)
    {
        return [SELECT Id,Batch__c,Material_Requisition__c
                FROM 
                    Material_Req_Batch__c 
                WHERE 
                    Batch__c IN: batch];
                    
     }
    
    /// <OBJECTIVE>
    /// Fetch Material Requisitions 
    /// </OBJECTIVE>   
       /******
    Took out these line:
      
                 AND 
                     CreatedById =: userId
    Line 292, 316
                             CreatedById =: userId
                     AND 
    Line 301
    
    ********/   
    public static List<Material_Requisition__c> fetchMR(List<Id> MRId, List<String> StatusList, Integer LimitNum, Id userId,String Status,String SearchText,Id MR_Id)
    {
        if(StatusList != null && LimitNum != null && userId != null)
        {
            return [SELECT Id,Name,Status__c,CreatedBy.FirstName,CreatedBy.LastName,LocationCode__c,LocationCode__r.Name,LocationCode__r.Description__C,Location_code__c,Location_text__c,ATI_Job__r.Division__c,CreatedDate,Job_Number__c
                     FROM 
                         Material_Requisition__c
                     WHERE
                         status__c IN: StatusList 
                     AND 
                         LastModifiedById =: userId ORDER BY LastModifiedDate DESC NULLS FIRST limit :LimitNum];
        }
        else if(userId != null && SearchText == null)
        {
            return [SELECT Id,Name,Status__c,CreatedBy.FirstName,CreatedBy.LastName,LocationCode__c,LocationCode__r.Name,LocationCode__r.Description__C,Location_code__c,Location_text__c,ATI_Job__r.Division__c,CreatedDate,Job_Number__c
                     FROM 
                         Material_Requisition__c
                     WHERE
                         status__c = : Status];
        
        }   
        else if(SearchText != null && userId != null )
        {
            return [SELECT Id,Name,Status__c,CreatedBy.FirstName,CreatedBy.LastName,LocationCode__c,LocationCode__r.Name,LocationCode__r.Description__C,Location_code__c,Location_text__c,ATI_Job__r.Division__c,CreatedDate,Job_Number__c
                 FROM 
                     Material_Requisition__c
                 WHERE
                     Name like :('%' + SearchText + '%')
                 AND 
                     status__c in :StatusList];
        
        }
        else if(SearchText != null)
        {
            return [SELECT Id,Name,Status__c,CreatedBy.FirstName,CreatedBy.LastName,LocationCode__c,LocationCode__r.Name,LocationCode__r.Description__C,Location_code__c,Location_text__c,ATI_Job__r.Division__c,CreatedDate,Job_Number__c
                 FROM 
                     Material_Requisition__c
                 WHERE
                     Name like :('%' + SearchText + '%') AND CreatedById =: userId
                 AND status__c in :StatusList];
        
        }
        else if(MR_Id != null && StatusList == null)
        {
            return [SELECT Date_Ordered__c,Id,ATI_Job__c,ATI_Job__r.Job_Number__c,
                    ATI_Job__r.Job_Name__c,ATI_Job__r.Division__c,ATI_Job__r.Office2__c,Status__c,CreatedBy.FirstName,CreatedBy.LastName,MR_Auto_Number__c,LocationCode__c,LocationCode__r.Name,LocationCode__r.Description__C,Location_code__c,Location_text__c,CreatedDate,Job_Number__c
                FROM 
                    Material_Requisition__c 
                WHERE 
                    Id =:MR_Id limit :LimitNum];
        }
        else if(MR_Id != null && StatusList != null)
        {
            return [SELECT Date_Ordered__c,Id,ATI_Job__c,ATI_Job__r.Job_Number__c,
                    ATI_Job__r.Job_Name__c,ATI_Job__r.Division__c,ATI_Job__r.Office2__c,Status__c,CreatedBy.FirstName,CreatedBy.LastName,MR_Auto_Number__c,LocationCode__c,LocationCode__r.Name,LocationCode__r.Description__C,Location_code__c,Location_text__c,CreatedDate,Job_Number__c
                FROM 
                    Material_Requisition__c 
                WHERE 
                    Id =:MR_Id 
                AND status__c =:StatusList limit :LimitNum];
        }
        else
        {
        return null;
        }
    }
    
    /// <OBJECTIVE>
    /// Fetch Material Requisition Line Items 
    /// </OBJECTIVE>
    
    public static List<Material_Requisition_line_item__c> fetchMRItem(String MR_id)
    {
        return [SELECT Extended_Cost__c,Id,Material_Requisition__c,Material__c,Name,Quantity__c,
                Returned__c,Shipped__c,Status__c,Description__c,IsPicklist__c,Unit_cost__c 
            FROM 
                    Material_Requisition_line_item__c 
            WHERE   
                    Material_Requisition__c =:MR_id ORDER BY Name ASC];
    
    } 
    /// <OBJECTIVE>
    /// Inserts a new Batch record 
    /// </OBJECTIVE>
    
    public static Batch__C insertBatch()
    {
         Batch__C batch = new Batch__C();
         //batch.Send__c = true;
         batch.Batch_Status__c ='New';
         batch.Batch_Date__c = Date.today();
         
         Insert batch;
         return batch;
    }
    
    /// <OBJECTIVE>
    /// Inserts a new Material req batch record 
    /// </OBJECTIVE>
    
    public static boolean insertMaterialReqBatch( List<Material_Req_Batch__c> materialReqBatchList)
    {
         try
         {
             Insert materialReqBatchList;
             return true;
         }
         catch(DMLException Ex)
         {
             system.debug('====Error in insertMaterialReqBatch Method DataUtility===='+Ex.getmessage());
             return false;
         }
    }
    
    /// <OBJECTIVE>
    /// Updates a MR record with 'send' set to true
    /// </OBJECTIVE>
    
  /*  public static void updateMaterialRequistion(List<Material_Requisition__c> mrList)
    {

         update mrList;
    }
    
    /// <OBJECTIVE>
    /// Fetch profile Id
    /// </OBJECTIVE>
    
     public static String fetchProfile(Id userId)
    {
        return [SELECT 
                    Profile.Name 
                FROM 
                    user 
                WHERE Id =:userId].Profile.Name;
    } */
    
    /// <OBJECTIVE>
    /// Deletes a list of MRItems
    /// </OBJECTIVE>
    
    public static void DeleteMRItem(Set<Material_Requisition_line_item__c> ItemSet)
    {
        List<Material_Requisition_line_item__c> MRList = new List<Material_Requisition_line_item__c>();
        MRList.addAll(ItemSet);
        Delete MRList;
    }
    /// <OBJECTIVE>
    /// Fetch MRlocations
    /// </OBJECTIVE>
    
    public static List<MRLocation__c> FetchMRLocations(Set<Id> OffIdSet,List<String> DivList)
    {
        return [select Id,Name,IsDefault__c,Office__c,Office__r.Id,Office__r.Name,Division__c,Locationcode__c,Locationcode__r.name,Locationcode__r.description__C from MRLocation__c where Office__c IN:OffIdSet OR Division__c IN: DivList];
    }
    /// <OBJECTIVE>
    /// Fetch all the Location Codes. 
    /// </OBJECTIVE>    
    
    public static List<Location_Code__c> fetchAllLocationCodes(string LocationCode)
    {
        return [SELECT Description__c,Id,Name FROM Location_Code__c where Description__c !=: LocationCode Order by Description__c];
           
    }  
    /// <OBJECTIVE>
    /// Inserts a new Batch record with fields
    /// </OBJECTIVE>
    
    public static void updateBatch(string batchId)
    {
         Batch__C batch = new Batch__C(id = batchId);
         batch.Send__c = true;
         
        
         update batch;
         
    }
    
    /// <OBJECTIVE>
    /// Fetch All Completed MR
    /// </OBJECTIVE>
    
    public static List<Material_Requisition__c> FecthCompletedMRList()
    {
         return [SELECT Id,Status__c,Batch_Value__c,No_of_Entries__c, createdbyID 
             FROM 
                 Material_Requisition__c 
             WHERE 
                 Status__c = 'Completed'];
         
    }
    
    
}