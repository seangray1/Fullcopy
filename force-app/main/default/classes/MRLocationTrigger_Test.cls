/**
 * @author           Kirankumar
 * @version          1.0
 * @date             26-07-2017
 * @status           Developed
 * @Description      Test class for MRLocation Trigger
 **/
@isTest
public class MRLocationTrigger_Test
{
     public static TestMethod void insertLocation()
     {
         //Insert Office record
         Office__c office = PRLDE_TestDataUtility.InsertOffice('Los Angeles','Westhills Court','433454','California','Southern CA');  
         
         //Inserts Location code
         Location_Code__c testLocCode = PRLDE_TestDataUtility.InsertLocationCode('TESTCODE','TEST Description');
         
         //Insert MRLocation record
         MRLocation__c mrloc = PRLDE_TestDataUtility.InsertMRLocation('Test Record',office.Id,'Consulting',true,testLocCode.Id);
     }
     
     public static TestMethod void insertLocationWthDefultChecked()
     {
         //Insert Office record
         Office__c office = PRLDE_TestDataUtility.InsertOffice('Los Angeles','Westhills Court','433454','California','Southern CA');  
         
         //Inserts Location code
         Location_Code__c testLocCode = PRLDE_TestDataUtility.InsertLocationCode('TESTCODE','TEST Description');
         
         //Insert MRLocation record
         MRLocation__c mrloc = PRLDE_TestDataUtility.InsertMRLocation('Test Record',office.Id,'Consulting',true,testLocCode.Id);
         
         //Insert MRLocation record
         MRLocation__c mrloc2 = new MRLocation__c(Office__c=office.Id,Division__c='Consulting',IsDefault__c=true);
         
         Database.SaveResult result = Database.insert(mrloc2, false);
         
         System.assertEquals(result.getErrors().size(),1);

     }
     
     public static TestMethod void UpdateLocationWthDefultChecked()
     {
         //Insert Office record
         Office__c office = PRLDE_TestDataUtility.InsertOffice('Los Angeles','Westhills Court','433454','California','Southern CA');  
         
         //Inserts Location code
         Location_Code__c testLocCode = PRLDE_TestDataUtility.InsertLocationCode('TESTCODE','TEST Description');
         
         //Insert MRLocation record
         MRLocation__c mrloc = PRLDE_TestDataUtility.InsertMRLocation('Test Record',office.Id,'Consulting',true,testLocCode.Id);
         
         //Insert MRLocation record
         MRLocation__c mrloc2 = PRLDE_TestDataUtility.InsertMRLocation('Test Record2',office.Id,'Consulting',false,testLocCode.Id);
         
         //update MRLocation record
         mrloc2.IsDefault__c = True;
         Database.SaveResult result = Database.update(mrloc2, false);
         System.assertEquals(result.getErrors().size(),1);

     }
}