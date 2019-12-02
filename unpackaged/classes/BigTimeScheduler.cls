/**
 * @File Name          : BigTimeScheduler.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/10/2019, 3:56:54 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/7/2019   Sean Gray     Initial Version
**/
global class BigTimeScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      if(test.isRunningTest()){
         string test;
         string test1;
         string test2;
         string test3;
         string test5;
         string test6;
      }
      else{
       BigTime_Callout_Integration.resetCredentials();
      System.enqueueJob(new BigTime_Integration_Invoices());
      }
      
   }
}