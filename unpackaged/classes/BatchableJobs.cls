/**
 * @File Name          : BatchableJobs.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : sean.gray@atirestoration.com
 * @Last Modified On   : 11/5/2019, 10:32:47 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/5/2019   sean.gray@atirestoration.com     Initial Version
**/
public class BatchableJobs{
   public static void JobsToInsert(Integer numToInsert){
                                                        
                                                          List<ATI_Job__c> Jobs  = new List<ATI_Job__c >();
                                                          for( Integer i = 0; i < numToInsert; i++ ) {
                                                              ATI_Job__c  j = new ATI_Job__c(Name='Test ATI_Job__c '+String.valueOf(i)  );
                                                              j.Account__c = '0017000001PUFqGAAX';
                                                              // j.Name = 'semira';
                                                              j.Job_Name__c = 'test';
                                                              j.Project_Site_Contact_Name__c = '0037000001xsRDrAAM';
                                                              j.Project_Site_Contact_Account__c = '0017000001PUFqGAAX';
                                                              j.Project_Site_Address__c = 'Test Street';
                                                              j.Project_Site_City__c = 'Los Angeles';
                                                              j.Project_Site_state__c = 'CA';
                                                              j.Project_Site_zipcode__c ='90027';
                                                              //j.County__c = 'LA';
                                                              //j.City_of_LA__c = 'Yes';
                                                              j.Stage__c ='Qualification';
                                                              j.CloseDate__c = System.today().addDays(90);
                                                              j.office2__c = 'a1O0g000005BM2ZEAW';
                                                              j.Division__c = 'asbestos';
                                                                Jobs.add(j);
                                                              }
                                                               List<Database.SaveResult> conSaveResultList = Database.insert(Jobs);
                                                              
                                                          }  
                                                         
                                                      }