/**
* @author           Gangadhar R
* @version          1.0
* @date             07-07-2017
* @status           Developed
* @Description      The purpose of this batch class is to fetch the completed material req records
*                     and update them to trigger to jitterbit.
**/
global class SendMRBatch implements Database.Batchable<sObject>{

   
   global Database.QueryLocator start(Database.BatchableContext BC){
      
      //A dummy query to start the execute method. This query will not be used in the execute method. 
      //It is always one batch and all the material Req records will be related under the batch record.
      string query = 'SELECT Id,Status__c,Batch_Value__c,No_of_Entries__c FROM Material_Requisition__c WHERE Status__c = \'Completed\' Limit 1';
      System.debug('scopescope@@@@@'+query);
      return Database.getQueryLocator(query);
      
   }

   global void execute(Database.BatchableContext BC, List<Material_Requisition__c> scope){
       try
       {
            Batch__c batch =  PRLDE_DataUtility.insertBatch();
            List<Material_Requisition__c> MRList = PRLDE_DataUtility.FecthCompletedMRList();
            System.debug('scopeMRList@@@@@'+MRList);
            List<Material_Req_Batch__c> MaterialReqBatchLst = new List<Material_Req_Batch__c>();
            // Batch__c batch = PRLDE_DataUtility.insertBatch();
             for(Material_Requisition__c MaterialReq: MRList){             
                 
                     Material_Req_Batch__c MaterialReqBatch = new Material_Req_Batch__c();
                     
                     MaterialReqBatch.Material_Requisition__c = MaterialReq.Id;
                     MaterialReqBatch.Batch__c = batch.Id;
                     MaterialReqBatch.Batch_Value__c = MaterialReq.Batch_Value__c;
                     MaterialReqBatch.Number_of_Entries__c = MaterialReq.No_of_Entries__c;
                     
                     MaterialReqBatchLst.add(MaterialReqBatch);
             }
              Boolean isSuccessMrReqBatch = PRLDE_DataUtility.insertMaterialReqBatch(MaterialReqBatchLst);
              if(isSuccessMrReqBatch)
              {
                PRLDE_DataUtility.updateBatch(batch.Id);
              }
            
        }
        catch(Exception ex)
        {
            System.Debug('=====Execute batch========'+ex.getMessage());
        }
    }

   global void finish(Database.BatchableContext BC){
   }
}