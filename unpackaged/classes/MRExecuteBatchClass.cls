/**
* @author           Manoj Kumar S
* @version          1.0
* @date             08-23-2017
* @status           Developed
* @Description      The purpose of this class is to trigger the batch class in button click
**/
global with sharing class MRExecuteBatchClass{
   
    //Execute the Batch class
     WebService static string executeBatchClass() {
       
        SendMRBatch obj = new SendMRBatch();
        Database.executeBatch(obj,100);        
        
        //Redirect to the Batch list page
        return URL.getSalesforceBaseUrl()+'/a44';
    }
}