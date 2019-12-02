/**
* @author           kanitha Priya P
* @version          1.0
* @date             14-08-2017
* @status           Developed
* @Description      The purpose of this trigger is to update the MR status with 'Sync Successful' or 'Sync Failed' based on the successfull insert of icissue and icissuebtch records into Timberline.
**/
trigger UpdateMRStatus on Batch__c (after update) 
{
    Map<Id,Batch__c> BatchOld = new Map<Id,Batch__c>();
    List<Batch__c> BatchNew = new List<Batch__c>();
    Map<Id,Material_Requisition__c> MRMap = new Map<Id,Material_Requisition__c>();
    List<Material_Req_Batch__c> MRReq = new List<Material_Req_Batch__c>();
    List<Id> MRId = new List<Id>();
    Map<Id,List<Material_Req_Batch__c>> BatchWithMRReq = new Map<Id,List<Material_Req_Batch__c>>();
    Map<Id,Material_Requisition__c> MRReqWithMR = new Map<Id,Material_Requisition__c>();
    Map<Id,Material_Requisition__c> MRMapToUpdate = new Map<Id,Material_Requisition__c>();
    MRReq = PRLDE_DataUtility.fetchMRReqWithBatchList(Trigger.New);
    
    for(Material_Req_Batch__c MRBatch : MRReq)
    {
        if(BatchWithMRReq.get(MRBatch.Batch__c) != null && BatchWithMRReq.get(MRBatch.Batch__c).size() > 0)
        {
            // To create a Map with Batch Id as key and List of MRReq Batch as value
            BatchWithMRReq.get(MRBatch.Batch__c).add(MRBatch);
        }
        else
        {
            BatchWithMRReq.put(MRBatch.Batch__c,new List<Material_Req_Batch__c>{MRBatch});
        }
        
        if(MRBatch.Material_Requisition__c != null)
        {
            // To create a Map with MR Req batch Id as key and MR record as value
            MRReqWithMR.put(MRBatch.Id,new Material_Requisition__c(Id = MRBatch.Material_Requisition__c));
            MRId.add(MRBatch.Material_Requisition__c);
        }
        
    }
    
      for(Material_Requisition__c MR : PRLDE_DataUtility.fetchMRWithIdList(MRId))
      {
          MRMap.put(MR.Id,MR);
      }
   
    if(Trigger.isUpdate)
    {
        for(Batch__c batch_old : Trigger.Old)
        {
           BatchOld.put(batch_old.Id,batch_old); 
        }
        
        for(Batch__c batch : Trigger.New)
        {
            //If the batch status has been changed and if the new status is 'Sync Successful' or 'Sync Failed', the related MR status will be updated
            if((batch.Batch_Status__c == 'Sync Successful' || batch.Batch_Status__c == 'Sync Failed') && (batch.Batch_Status__c != BatchOld.get(batch.Id).Batch_Status__c))
            {
                if(BatchWithMRReq.get(batch.Id) != null)
                {
                    for(Material_Req_Batch__c MRB : BatchWithMRReq.get(batch.Id))
                    {
                        if(MRReqWithMR.get(MRB.Id) != null)
                        {
                            Material_Requisition__c MR = MRReqWithMR.get(MRB.Id);
                            
                            //If the MR status is 'Completed', MR status will be updated to 'Sync Successful' or 'Sync Failed'
                            if(MRMap.get(MR.Id) != null && MRMap.get(MR.Id).Status__c == 'Completed')
                            {
                                MR.Status__c = batch.Batch_Status__c;
                                MR.Batch_Date__c = batch.Batch_Sync_Date__c; 
                                MRMapToUpdate.put(MR.Id,MR); 
                            } 
                        }            
                    }
                }
            }
        }
    }
    
    
    if(MRMapToUpdate.size() > 0)
    {
        update MRMapToUpdate.values();
    }
}