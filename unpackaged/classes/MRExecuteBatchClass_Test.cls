/**
* @author           Manoj Kumar S
* @version          1.0
* @date             08-23-2017
* @status           Developed
* @Description      The purpose of this class is to Test the MRExecuteBatchClass class
**/
@isTest
private class MRExecuteBatchClass_Test
{  
      static testMethod void BatchRunTest()
      {
          string returnURL = MRExecuteBatchClass.executeBatchClass();
          
          string salesforceURL = URL.getSalesforceBaseUrl()+'/a44';
          
          System.assertEquals(salesforceURL,returnURL);
      }
}